#include "common.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>

int create_pipe_if_needed(const char *pipe_name) {
    if (mkfifo(pipe_name, 0666) == -1) {
        if (errno == EEXIST) {
            return 0;
        }
        return -1;
    }
    return 0;
}

int remove_pipe_if_exists(const char *pipe_name) {
    if (unlink(pipe_name) == -1) {
        if (errno == ENOENT) {
            return 0;
        }
        return -1;
    }
    return 0;
}

void build_runner_pipe_name(char *buffer, size_t size, pid_t pid) {
    snprintf(buffer, size, "pipe_runner_%d", (int)pid);
}

int send_request_to_controller(const RequestMessage *msg) {
    int fd;
    ssize_t n;

    fd = open(CONTROLLER_PIPE, O_WRONLY);
    if (fd == -1) {
        return -1;
    }

    n = write(fd, msg, sizeof(RequestMessage));
    close(fd);

    if (n != (ssize_t)sizeof(RequestMessage)) {
        return -1;
    }

    return 0;
}

int send_reply_to_pipe(const char *pipe_name, const ReplyMessage *reply) {
    int fd;
    ssize_t n;

    fd = open(pipe_name, O_WRONLY);
    if (fd == -1) {
        return -1;
    }

    n = write(fd, reply, sizeof(ReplyMessage));
    close(fd);

    if (n != (ssize_t)sizeof(ReplyMessage)) {
        return -1;
    }

    return 0;
}

int receive_reply_from_pipe(const char *pipe_name, ReplyMessage *reply) {
    int fd;
    ssize_t n;

    fd = open(pipe_name, O_RDONLY);
    if (fd == -1) {
        return -1;
    }

    n = read(fd, reply, sizeof(ReplyMessage));
    close(fd);

    if (n != (ssize_t)sizeof(ReplyMessage)) {
        return -1;
    }

    return 0;
}

int generate_command_id(void) {
    struct timeval tv;
    long long id;

    gettimeofday(&tv, NULL);
    id = (long long)getpid() + tv.tv_sec + tv.tv_usec;

    return (int)(id % 2000000000);
}

long long diff_millis(const struct timespec *start, const struct timespec *end) {
    long long sec;
    long long nsec;

    sec = (long long)end->tv_sec - (long long)start->tv_sec;
    nsec = (long long)end->tv_nsec - (long long)start->tv_nsec;

    return sec * 1000LL + nsec / 1000000LL;
}

int clock_now(struct timespec *ts) {
    return clock_gettime(CLOCK_MONOTONIC, ts);
}

SchedulingPolicy parse_policy(const char *text) {
    if (text == NULL) {
        return POLICY_FIFO;
    }
    if (strcmp(text, "fair") == 0) {
        return POLICY_FAIR;
    }
    return POLICY_FIFO;
}

const char *policy_to_string(SchedulingPolicy policy) {
    if (policy == POLICY_FAIR) {
        return "fair";
    }
    return "fifo";
}
