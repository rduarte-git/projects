#include "executor.h"
#include "common.h"

#include <ctype.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

typedef struct Stage {
    char *argv[MAX_ARGS];
    char *input_file;
    char *output_file;
    char *error_file;
    int output_append;
    int error_append;
} Stage;

static char *trim_text(char *text) {
    char *end;

    while (*text != '\0' && isspace((unsigned char)*text)) {
        text++;
    }

    end = text + strlen(text);
    while (end > text && isspace((unsigned char)end[-1])) {
        end--;
    }
    *end = '\0';

    return text;

}

static int parse_one_stage(char *stage_text, Stage *stage) {
    char *word;
    int argc = 0;

    memset(stage, 0, sizeof(Stage));

    word = strtok(stage_text, " \t\n");

    while (word != NULL) {
        if (strcmp(word, "<") == 0) {
            word = strtok(NULL, " \t\n");
            if (word == NULL) {
                return -1;
            }
            stage->input_file = word;
        } 
        else if (strcmp(word, ">") == 0 || strcmp(word, ">>") == 0) {
            int append = (strcmp(word, ">>") == 0);

            word = strtok(NULL, " \t\n");
            if (word == NULL) {
                return -1;
            }
            stage->output_file = word;
            stage->output_append = append;
        } 
        else if (strcmp(word, "2>") == 0 || strcmp(word, "2>>") == 0) {
            int append = (strcmp(word, "2>>") == 0);

            word = strtok(NULL, " \t\n");
            if (word == NULL) {
                return -1;
            }
            stage->error_file = word;
            stage->error_append = append;
        } 
        else {
            if (argc >= MAX_ARGS - 1) {
                return -1;
            }
            stage->argv[argc] = word;
            argc++;
        }

        word = strtok(NULL, " \t\n");
    }

    stage->argv[argc] = NULL;

    if (argc == 0) {
        return -1;
    }

    return 0;
}

static int parse_command(char *command_copy, Stage stages[], int *stage_count) {
    char *current;
    char *pipe_pos;
    int count = 0;

    current = command_copy;

    while (current != NULL && *current != '\0') {
        char *stage_text;

        if (count >= MAX_STAGES) {
            return -1;
        }

        pipe_pos = strchr(current, '|');

        if (pipe_pos != NULL) {
            *pipe_pos = '\0';
        }

        stage_text = trim_text(current);

        if (parse_one_stage(stage_text, &stages[count]) != 0) {
            return -1;
        }

        count++;

        if (pipe_pos == NULL) {
            break;
        }

        current = pipe_pos + 1;
    }

    *stage_count = count;

    if (count == 0) {
        return -1;
    }

    return 0;
}

static int redirect_to_file(const char *file, int target_fd, int flags) {
    int fd;

    fd = open(file, flags, 0644);
    if (fd == -1) {
        return -1;
    }

    if (dup2(fd, target_fd) == -1) {
        close(fd);
        return -1;
    }

    close(fd);
    return 0;
}


int execute_command_line(const char *command_line) {
    char command_copy[COMMAND_SIZE];
    Stage stages[MAX_STAGES];
    int stage_count;
    int pipes[MAX_STAGES - 1][2];
    pid_t pids[MAX_STAGES];
    int i;
    int final_status;

    strncpy(command_copy, command_line, COMMAND_SIZE - 1);
    command_copy[COMMAND_SIZE - 1] = '\0';

    if (parse_command(command_copy, stages, &stage_count) != 0) {
        fprintf(stderr, "Invalid command.\n");
        return 1;
    }

    for (i = 0; i < stage_count - 1; i++) {
        if (pipe(pipes[i]) == -1) {
            perror("pipe");
            return 1;
        }
    }

    for (i = 0; i < stage_count; i++) {
        pids[i] = fork();
        if (pids[i] == -1) {
            perror("fork");
            return 1;
        }

        if (pids[i] == 0) {
            int j;

            if (i > 0) {
                dup2(pipes[i - 1][0], STDIN_FILENO);
            }
            if (i < stage_count - 1) {
                dup2(pipes[i][1], STDOUT_FILENO);
            }

            for (j = 0; j < stage_count - 1; j++) {
                close(pipes[j][0]);
                close(pipes[j][1]);
            }

            if (stages[i].input_file != NULL) {
                if (redirect_to_file(stages[i].input_file, STDIN_FILENO, O_RDONLY) == -1) {
                    perror("input redirection");
                    _exit(1);
                }
            }
            if (stages[i].output_file != NULL) {
                int flags = O_WRONLY | O_CREAT;

                if (stages[i].output_append) {
                    flags |= O_APPEND;
                } else {
                    flags |= O_TRUNC;
                }

                if (redirect_to_file(stages[i].output_file, STDOUT_FILENO, flags) == -1) {
                    perror("output redirection");
                    _exit(1);
                }
            }
            if (stages[i].error_file != NULL) {
                int flags = O_WRONLY | O_CREAT;

                if (stages[i].error_append) {
                    flags |= O_APPEND;
                } else {
                    flags |= O_TRUNC;
                }

                if (redirect_to_file(stages[i].error_file, STDERR_FILENO, flags) == -1) {
                    perror("error redirection");
                    _exit(1);
                }
            }

            execvp(stages[i].argv[0], stages[i].argv);
            perror("execvp");
            _exit(127);
        }
    }

    for (i = 0; i < stage_count - 1; i++) {
        close(pipes[i][0]);
        close(pipes[i][1]);
    }

    final_status = 0;
    for (i = 0; i < stage_count; i++) {
        int status;

        status = 0;
        if (waitpid(pids[i], &status, 0) == -1) {
            perror("waitpid");
            final_status = 1;
        } else if (i == stage_count - 1) {
            if (WIFEXITED(status)) {
                final_status = WEXITSTATUS(status);
            } else {
                final_status = 1;
            }
        }
    }

    return final_status;
}
