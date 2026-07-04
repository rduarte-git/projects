#include "common.h"
#include "executor.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>

static long long now_ms(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (long long)tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

static void build_command_text(int argc, char *argv[], int start, char *buffer, size_t size) {
    int i;

    buffer[0] = '\0';
    for (i = start; i < argc; i++) {
        if (strlen(buffer) + strlen(argv[i]) + 2 >= size) {
            break;
        }
        if (i > start) {
            strcat(buffer, " ");
        }
        strcat(buffer, argv[i]);
    }
}

static void fill_request(RequestMessage *msg, RequestType type, int user_id, int command_id, const char *command, const char *pipe_name) {
    *msg = (RequestMessage){0};
    msg->type = type;
    msg->user_id = user_id;
    msg->command_id = command_id;

    if (command != NULL) {
        strncpy(msg->command, command, COMMAND_SIZE - 1);
    }
    if (pipe_name != NULL) {
        strncpy(msg->pipe_name, pipe_name, PIPE_NAME_SIZE - 1);
    }
}



static int run_execute_mode(int argc, char *argv[]) {
    int user_id;
    int command_id;
    int exit_code;
    char command[COMMAND_SIZE];
    char pipe_name[PIPE_NAME_SIZE];
    RequestMessage req;
    ReplyMessage rep;

    if (argc < 4) {
        fprintf(stderr, "Usage: %s -e <user_id> <command...>\n", argv[0]);
        return 1;
    }

    user_id = atoi(argv[2]);
    command_id = generate_command_id();
    build_command_text(argc, argv, 3, command, sizeof(command));
    build_runner_pipe_name(pipe_name, sizeof(pipe_name), getpid());

    if (create_pipe_if_needed(pipe_name) != 0) {
        perror("mkfifo runner");
        return 1;
    }

    fill_request(&req, EXEC_REQUEST, user_id, command_id, command, pipe_name);
    if (send_request_to_controller(&req) != 0) {
        perror("send request");
        remove_pipe_if_exists(pipe_name);
        return 1;
    }

    printf("%lld [runner] command submitted: %d\n", now_ms(), command_id);
    fflush(stdout);

    if (receive_reply_from_pipe(pipe_name, &rep) != 0) {
        perror("receive reply");
        remove_pipe_if_exists(pipe_name);
        return 1;
    }

    if (rep.type == ERROR_REPLY) {
        fprintf(stderr, "[runner] %s\n", rep.reply);
        remove_pipe_if_exists(pipe_name);
        return 1;
    }

    printf("%lld [runner] command executing: %d\n", now_ms(), command_id);
    fflush(stdout);

    exit_code = execute_command_line(command);

    printf("%lld [runner] command finished: %d\n", now_ms(), command_id);
    fflush(stdout);

    fill_request(&req, EXEC_DONE, user_id, command_id, command, pipe_name);
    if (send_request_to_controller(&req) != 0) {
        perror("send EXEC_DONE");
        remove_pipe_if_exists(pipe_name);
        return 1;
    }

    remove_pipe_if_exists(pipe_name);
    return exit_code;
}

static int run_status_mode(void) {
    int command_id;
    char pipe_name[PIPE_NAME_SIZE];
    RequestMessage req;
    ReplyMessage rep;

    command_id = generate_command_id();
    build_runner_pipe_name(pipe_name, sizeof(pipe_name), getpid());

    if (create_pipe_if_needed(pipe_name) != 0) {
        perror("mkfifo status");
        return 1;
    }

    fill_request(&req, STATUS_REQUEST, 0, command_id, NULL, pipe_name);
    if (send_request_to_controller(&req) != 0) {
        perror("send status request");
        remove_pipe_if_exists(pipe_name);
        return 1;
    }

    if (receive_reply_from_pipe(pipe_name, &rep) != 0) {
        perror("receive status reply");
        remove_pipe_if_exists(pipe_name);
        return 1;
    }

    printf("%s", rep.reply);
    remove_pipe_if_exists(pipe_name);
    return 0;
}

static int run_shutdown_mode(void) {
    int command_id;
    char pipe_name[PIPE_NAME_SIZE];
    RequestMessage req;
    ReplyMessage rep;

    command_id = generate_command_id();
    build_runner_pipe_name(pipe_name, sizeof(pipe_name), getpid());

    if (create_pipe_if_needed(pipe_name) != 0) {
        perror("mkfifo shutdown");
        return 1;
    }

    fill_request(&req, SHUTDOWN_REQUEST, 0, command_id, NULL, pipe_name);
    if (send_request_to_controller(&req) != 0) {
        perror("send shutdown request");
        remove_pipe_if_exists(pipe_name);
        return 1;
    }

    printf("[runner] shutdown requested\n");
    fflush(stdout);

    if (receive_reply_from_pipe(pipe_name, &rep) != 0) {
        perror("receive shutdown reply");
        remove_pipe_if_exists(pipe_name);
        return 1;
    }

    printf("[runner] %s\n", rep.reply);
    remove_pipe_if_exists(pipe_name);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s -e <user_id> <command...> | -c | -s\n", argv[0]);
        return 1;
    }

    if (strcmp(argv[1], "-e") == 0) {
        return run_execute_mode(argc, argv);
    }

    if (strcmp(argv[1], "-c") == 0) {
        return run_status_mode();
    }

    if (strcmp(argv[1], "-s") == 0) {
        return run_shutdown_mode();
    }

    fprintf(stderr, "Unknown option.\n");
    return 1;
}
