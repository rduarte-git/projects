CC = gcc
CFLAGS = -D_POSIX_C_SOURCE=200809L -Wall -Wextra -Wpedantic -std=c11 -g
SRC = src

all: controller runner

controller: $(SRC)/controller.o $(SRC)/common.o
	$(CC) $(CFLAGS) -o $@ $^

runner: $(SRC)/runner.o $(SRC)/common.o $(SRC)/executor.o
	$(CC) $(CFLAGS) -o $@ $^

$(SRC)/controller.o: $(SRC)/controller.c $(SRC)/common.h
	$(CC) $(CFLAGS) -c -o $@ $<

$(SRC)/runner.o: $(SRC)/runner.c $(SRC)/common.h $(SRC)/executor.h
	$(CC) $(CFLAGS) -c -o $@ $<

$(SRC)/executor.o: $(SRC)/executor.c $(SRC)/executor.h $(SRC)/common.h
	$(CC) $(CFLAGS) -c -o $@ $<

$(SRC)/common.o: $(SRC)/common.c $(SRC)/common.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f controller runner $(SRC)/*.o pipe_cont pipe_runner_* controller_metrics.log *.txt tests/*.out tests/*.err tests/*.log

.PHONY: all clean
