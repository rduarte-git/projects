#ifndef COMMON_H
#define COMMON_H

#include <stddef.h>
#include <sys/types.h>
#include <time.h>

#define CONTROLLER_PIPE "pipe_cont"
#define PIPE_NAME_SIZE 32
#define COMMAND_SIZE 256
#define REPLY_SIZE 512
#define MAX_COMMANDS 1024
#define MAX_STAGES 16
#define MAX_ARGS 32
#define LOG_FILE "controller_metrics.log"

typedef enum {
    EXEC_REQUEST,
    STATUS_REQUEST,
    SHUTDOWN_REQUEST,
    EXEC_DONE
} RequestType;

typedef enum {
    EXEC_ACK,
    STATUS_REPLY,
    SHUTDOWN_ACK,
    ERROR_REPLY
} ReplyType;

typedef enum {
    WAITING,
    RUNNING,
    FINISHED
} CommandStatus;

typedef struct RequestMessage {
    RequestType type;
    int user_id;
    char command[COMMAND_SIZE];
    int command_id;
    char pipe_name[PIPE_NAME_SIZE];
} RequestMessage;

typedef struct ReplyMessage {
    ReplyType type;
    int command_id;
    char reply[REPLY_SIZE];
} ReplyMessage;

typedef enum {
    POLICY_FIFO,
    POLICY_FAIR
} SchedulingPolicy;

typedef struct CommandInfo {
    int user_id;
    int command_id;
    char command[COMMAND_SIZE];
    char pipe_name[PIPE_NAME_SIZE];
    CommandStatus status;
    struct timespec submit_time;
    struct timespec start_time;
    struct timespec end_time;
} CommandInfo;

int create_pipe_if_needed(const char *pipe_name);
int remove_pipe_if_exists(const char *pipe_name);
void build_runner_pipe_name(char *buffer, size_t size, pid_t pid);
int send_request_to_controller(const RequestMessage *msg);
int send_reply_to_pipe(const char *pipe_name, const ReplyMessage *reply);
int receive_reply_from_pipe(const char *pipe_name, ReplyMessage *reply);
int generate_command_id(void);
long long diff_millis(const struct timespec *start, const struct timespec *end);
int clock_now(struct timespec *ts);
SchedulingPolicy parse_policy(const char *text);
const char *policy_to_string(SchedulingPolicy policy);

#endif
