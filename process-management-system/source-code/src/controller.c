#include "common.h"
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static CommandInfo waiting_commands[MAX_COMMANDS];
static CommandInfo running_commands[MAX_COMMANDS];
static int waiting_count = 0;
static int running_count = 0;
static int max_parallel_commands = 1;
static int shutdown_requested = 0;
static char shutdown_pipe[PIPE_NAME_SIZE] = "";
static int shutdown_command_id = 0;
static SchedulingPolicy current_policy = POLICY_FIFO;
static int last_started_user = -1;
static volatile sig_atomic_t keep_running = 1;



static void controller_log(const char *message) {
    write(STDOUT_FILENO, message, strlen(message));
}

static void controller_log_command(const char *message, int command_id, int user_id) {
    printf("[controller] %s command_id=%d user=%d\n", message, command_id, user_id);
    fflush(stdout);
}

static void controller_log_command_text(const char *message, int command_id, int user_id, const char *command) {
    printf("[controller] %s command_id=%d user=%d command=\"%s\"\n",
           message, command_id, user_id, command);
    fflush(stdout);
}

static void controller_log_status(const char *message, int command_id) {
    printf("[controller] %s command_id=%d\n", message, command_id);
    fflush(stdout);
}


static void handle_signal(int sig) {
    (void)sig;
    keep_running = 0;
}

static void save_finished_command(CommandInfo *cmd) {
    FILE *f;
    long long duration;

    f = fopen(LOG_FILE, "a");
    if (f == NULL) {
        return;
    }

    duration = diff_millis(&cmd->submit_time, &cmd->end_time);
    fprintf(f, "%d;%d;%lld;%s\n", cmd->user_id, cmd->command_id, duration, cmd->command);
    fclose(f);
}

static void send_simple_reply(const char *pipe_name, ReplyType type, int command_id, const char *text) {
    ReplyMessage reply = {0};

    reply.type = type;
    reply.command_id = command_id;
    if (text != NULL) {
        strncpy(reply.reply, text, REPLY_SIZE - 1);
    }

    if (send_reply_to_pipe(pipe_name, &reply) != 0) {
        perror("send reply");
    }
}

static void add_to_waiting(CommandInfo *cmd) {
    if (waiting_count >= MAX_COMMANDS) {
        controller_log_command("waiting queue full.", cmd->command_id, cmd->user_id);
        send_simple_reply(cmd->pipe_name, ERROR_REPLY, cmd->command_id, "Waiting queue is full.");
        return;
    }

    waiting_commands[waiting_count] = *cmd;
    waiting_count++;
    controller_log_command("placed in WAITING.", cmd->command_id, cmd->user_id);
}

static void add_to_running(CommandInfo *cmd) {
    if (running_count >= MAX_COMMANDS) {
        controller_log_command("running queue full.", cmd->command_id, cmd->user_id);
        send_simple_reply(cmd->pipe_name, ERROR_REPLY, cmd->command_id, "Running queue is full.");
        return;
    }

    running_commands[running_count] = *cmd;
    running_count++;
}

static void remove_waiting_at(int index) {
    int i;

    for (i = index; i < waiting_count - 1; i++) {
        waiting_commands[i] = waiting_commands[i + 1];
    }
    waiting_count--;
}

static void remove_running_at(int index) {
    int i;

    for (i = index; i < running_count - 1; i++) {
        running_commands[i] = running_commands[i + 1];
    }
    running_count--;
}

static int choose_next_waiting_index(void) {
    int i;

    if (waiting_count <= 0) {
        return -1;
    }

    if (current_policy == POLICY_FIFO) {
        return 0;
    }

    for (i = 0; i < waiting_count; i++) {
        if (waiting_commands[i].user_id != last_started_user) {
            return i;
        }
    }

    return 0;
}


static void start_waiting_commands(void) {
    CommandInfo cmd;
    int index;

    while (running_count < max_parallel_commands && waiting_count > 0) {
        index = choose_next_waiting_index();
        if (index < 0) {
            return;
        }

        cmd = waiting_commands[index];
        remove_waiting_at(index);
        cmd.status = RUNNING;
        clock_now(&cmd.start_time);
        add_to_running(&cmd);
        last_started_user = cmd.user_id;
        controller_log_command("moved to RUNNING.", cmd.command_id, cmd.user_id);
        send_simple_reply(cmd.pipe_name, EXEC_ACK, cmd.command_id, "Can execute now.");
    }
}

static void finish_shutdown_if_possible(void) {
    if (shutdown_requested && waiting_count == 0 && running_count == 0 && shutdown_pipe[0] != '\0') {
        controller_log("[controller] shutdown completed. No waiting or running commands.\n");
        send_simple_reply(shutdown_pipe, SHUTDOWN_ACK, shutdown_command_id, "Controller finished.");
        keep_running = 0;
    }
}


static void handle_exec_request(RequestMessage *msg) {
    CommandInfo cmd = {0};

    cmd.user_id = msg->user_id;
    cmd.command_id = msg->command_id;
    strncpy(cmd.command, msg->command, COMMAND_SIZE - 1);
    strncpy(cmd.pipe_name, msg->pipe_name, PIPE_NAME_SIZE - 1);
    cmd.status = WAITING;
    clock_now(&cmd.submit_time);

    controller_log_command_text("received EXEC request.", cmd.command_id, cmd.user_id, cmd.command);

    if (shutdown_requested) {
        controller_log_status("rejected because shutdown is active.", cmd.command_id);
        send_simple_reply(msg->pipe_name, ERROR_REPLY, msg->command_id, "Controller is shutting down.");
        return;
    }

    if (running_count < max_parallel_commands) {
        cmd.status = RUNNING;
        clock_now(&cmd.start_time);
        add_to_running(&cmd);
        last_started_user = cmd.user_id;
        controller_log_command("moved to RUNNING.", cmd.command_id, cmd.user_id);
        send_simple_reply(cmd.pipe_name, EXEC_ACK, cmd.command_id, "Can execute now.");
    } else {
        add_to_waiting(&cmd);
    }
}


static void handle_status_request(RequestMessage *msg) {
    ReplyMessage reply = {0};
    int i;
    size_t used;

    controller_log_status("received STATUS request.", msg->command_id);

    reply.type = STATUS_REPLY;
    reply.command_id = msg->command_id;

    used = 0;
    used += snprintf(reply.reply + used, REPLY_SIZE - used, "---\nExecuting\n");
    for (i = 0; i < running_count && used < REPLY_SIZE; i++) {
        used += snprintf(reply.reply + used, REPLY_SIZE - used,
                         "user-id %d - command-id %d - %s\n",
                         running_commands[i].user_id,
                         running_commands[i].command_id,
                         running_commands[i].command);
    }

    if (used < REPLY_SIZE) {
        used += snprintf(reply.reply + used, REPLY_SIZE - used, "---\nScheduled\n");
    }
    for (i = 0; i < waiting_count && used < REPLY_SIZE; i++) {
        used += snprintf(reply.reply + used, REPLY_SIZE - used,
                         "user-id %d - command-id %d - %s\n",
                         waiting_commands[i].user_id,
                         waiting_commands[i].command_id,
                         waiting_commands[i].command);
    }

    if (send_reply_to_pipe(msg->pipe_name, &reply) != 0) {
        perror("status reply");
    }
}

static void handle_shutdown_request(RequestMessage *msg) {
    controller_log_status("received SHUTDOWN request.", msg->command_id);
    shutdown_requested = 1;
    strncpy(shutdown_pipe, msg->pipe_name, PIPE_NAME_SIZE - 1);
    shutdown_command_id = msg->command_id;
    finish_shutdown_if_possible();
}


static void handle_exec_done(RequestMessage *msg) {
    int i;

    controller_log_status("received EXEC_DONE.", msg->command_id);

    for (i = 0; i < running_count; i++) {
        if (running_commands[i].command_id == msg->command_id) {
            running_commands[i].status = FINISHED;
            clock_now(&running_commands[i].end_time);
            save_finished_command(&running_commands[i]);
            controller_log_status("finished and saved to log.", running_commands[i].command_id);
            remove_running_at(i);
            start_waiting_commands();
            finish_shutdown_if_possible();
            return;
        }
    }
}

int main(int argc, char *argv[]) {
    int fd;

    if (argc >= 2) {
        max_parallel_commands = atoi(argv[1]);
        if (max_parallel_commands <= 0) {
            fprintf(stderr, "Usage: %s <max_parallel_commands> [fifo|fair]\n", argv[0]);
            return 1;
        }
    }

    if (argc >= 3) {
        if (strcmp(argv[2], "fifo") != 0 && strcmp(argv[2], "fair") != 0) {
            fprintf(stderr, "Unknown policy. Use fifo or fair.\n");
            return 1;
        }
        current_policy = parse_policy(argv[2]);
    }

    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    if (create_pipe_if_needed(CONTROLLER_PIPE) != 0) {
        perror("mkfifo");
        return 1;
    }

    fd = open(CONTROLLER_PIPE, O_RDWR);
    if (fd == -1) {
        perror("open pipe_cont");
        remove_pipe_if_exists(CONTROLLER_PIPE);
        return 1;
    }

    printf("[controller] started with max_parallel_commands=%d policy=%s\n",
           max_parallel_commands, policy_to_string(current_policy));
    fflush(stdout);

    while (keep_running) {
        RequestMessage msg;
        ssize_t n;

        n = read(fd, &msg, sizeof(RequestMessage));
        if (n == 0) {
            continue;
        }
        if (n == -1) {
            if (errno == EINTR) {
                continue;
            }
            perror("read");
            break;
        }
        if (n != (ssize_t)sizeof(RequestMessage)) {
            continue;
        }

        if (msg.type == EXEC_REQUEST) {
            handle_exec_request(&msg);
        } else if (msg.type == STATUS_REQUEST) {
            handle_status_request(&msg);
        } else if (msg.type == SHUTDOWN_REQUEST) {
            handle_shutdown_request(&msg);
        } else if (msg.type == EXEC_DONE) {
            handle_exec_done(&msg);
        } else {
            controller_log_status("received unknown request type.", msg.command_id);
        }
    }

    controller_log("[controller] closing controller.\n");
    close(fd);
    remove_pipe_if_exists(CONTROLLER_PIPE);
    return 0;
}
