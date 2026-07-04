#!/bin/bash

echo "=== Teste de Escalonamento FIFO: 5 Utilizadores ==="
echo ""

mkdir -p logs
rm -f pipe_cont pipe_runner_*
rm -f logs/runner_u*_fifo.log
rm -f logs/controller_fifo_5_users.log

now_ms() {
    perl -MTime::HiRes=time -e 'printf "%.0f\n", time * 1000'
}

echo "Comandos do teste:"
echo 'U1: sleep 5'
echo 'U2: grep -v "^#" /etc/passwd | wc -l'
echo 'U3: ls -la'
echo 'U4: grep "/bin" /etc/passwd | cut -d: -f1'
echo 'U5: echo "teste de escalonamento" > /tmp/so_teste_output.txt'
echo ""

echo "A iniciar controller FIFO com 1 comando máximo..."
../controller 1 fifo > logs/controller_fifo_5_users.log 2>&1 &
CONTROLLER_PID=$!
sleep 5

echo ""
echo "A executar U1..."
SUB_U1=$(now_ms)
../runner -e 1 sleep 5 > logs/runner_u1_fifo.log 2>&1 &
PID_U1=$! 

sleep 0.2

echo "A executar U2..."
SUB_U2=$(now_ms)
../runner -e 2 'grep -v ^# /etc/passwd | wc -l' > logs/runner_u2_fifo.log 2>&1 &
PID_U2=$!

sleep 0.2

echo "A executar U3..."
SUB_U3=$(now_ms)
../runner -e 3 ls -la > logs/runner_u3_fifo.log 2>&1 &
PID_U3=$!

sleep 0.2

echo "A executar U4..."
SUB_U4=$(now_ms)
../runner -e 4 'grep /bin /etc/passwd | cut -d: -f1' > logs/runner_u4_fifo.log 2>&1 &
PID_U4=$!

sleep 0.2

echo "A executar U5..."
SUB_U5=$(now_ms)
../runner -e 5 "echo teste_escalonamento" > logs/runner_u5_fifo.log 2>&1 &
PID_U5=$!

echo ""
echo "A aguardar conclusão dos comandos..."

wait $PID_U1
FIN_U1=$(now_ms)

wait $PID_U2
FIN_U2=$(now_ms)

wait $PID_U3
FIN_U3=$(now_ms)

wait $PID_U4
FIN_U4=$(now_ms)

wait $PID_U5
FIN_U5=$(now_ms)

echo ""
echo "Resultados:"
echo ""

T0=$(grep -i "submitted" logs/runner_u1_fifo.log | head -1 | awk '{print $1}')

printf "%-6s %-45s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"USER" "COMANDO" "SUBMIT(s)" "EXEC(s)" "FINISH(s)" "WAIT(s)" "EXEC_TIME(s)" "TURN(s)" "RESP(s)"

echo "--------------------------------------------------------------------------------------------------------------------------------"

SUB_U1=$(grep -i "submitted" logs/runner_u1_fifo.log | head -1 | awk '{print $1}')
EXE_U1=$(grep -i "executing" logs/runner_u1_fifo.log | head -1 | awk '{print $1}')
FIN_U1=$(grep -i "finished" logs/runner_u1_fifo.log | head -1 | awk '{print $1}')

SUB_REL_U1=$(awk "BEGIN { printf \"%.3f\", ($SUB_U1 - $T0) / 1000 }")
EXE_REL_U1=$(awk "BEGIN { printf \"%.3f\", ($EXE_U1 - $T0) / 1000 }")
FIN_REL_U1=$(awk "BEGIN { printf \"%.3f\", ($FIN_U1 - $T0) / 1000 }")

WAIT_U1=$(awk "BEGIN { printf \"%.3f\", ($EXE_U1 - $SUB_U1) / 1000 }")
EXEC_U1=$(awk "BEGIN { printf \"%.3f\", ($FIN_U1 - $EXE_U1) / 1000 }")
TURN_U1=$(awk "BEGIN { printf \"%.3f\", ($FIN_U1 - $SUB_U1) / 1000 }")
RESP_U1=$WAIT_U1

printf "%-6s %-45s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U1" "sleep 5" "$SUB_REL_U1" "$EXE_REL_U1" "$FIN_REL_U1" "$WAIT_U1" "$EXEC_U1" "$TURN_U1" "$RESP_U1"


SUB_U2=$(grep -i "submitted" logs/runner_u2_fifo.log | head -1 | awk '{print $1}')
EXE_U2=$(grep -i "executing" logs/runner_u2_fifo.log | head -1 | awk '{print $1}')
FIN_U2=$(grep -i "finished" logs/runner_u2_fifo.log | head -1 | awk '{print $1}')

SUB_REL_U2=$(awk "BEGIN { printf \"%.3f\", ($SUB_U2 - $T0) / 1000 }")
EXE_REL_U2=$(awk "BEGIN { printf \"%.3f\", ($EXE_U2 - $T0) / 1000 }")
FIN_REL_U2=$(awk "BEGIN { printf \"%.3f\", ($FIN_U2 - $T0) / 1000 }")

WAIT_U2=$(awk "BEGIN { printf \"%.3f\", ($EXE_U2 - $SUB_U2) / 1000 }")
EXEC_U2=$(awk "BEGIN { printf \"%.3f\", ($FIN_U2 - $EXE_U2) / 1000 }")
TURN_U2=$(awk "BEGIN { printf \"%.3f\", ($FIN_U2 - $SUB_U2) / 1000 }")
RESP_U2=$WAIT_U2

printf "%-6s %-45s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U2" "grep -v ^# /etc/passwd | wc -l" "$SUB_REL_U2" "$EXE_REL_U2" "$FIN_REL_U2" "$WAIT_U2" "$EXEC_U2" "$TURN_U2" "$RESP_U2"


SUB_U3=$(grep -i "submitted" logs/runner_u3_fifo.log | head -1 | awk '{print $1}')
EXE_U3=$(grep -i "executing" logs/runner_u3_fifo.log | head -1 | awk '{print $1}')
FIN_U3=$(grep -i "finished" logs/runner_u3_fifo.log | head -1 | awk '{print $1}')

SUB_REL_U3=$(awk "BEGIN { printf \"%.3f\", ($SUB_U3 - $T0) / 1000 }")
EXE_REL_U3=$(awk "BEGIN { printf \"%.3f\", ($EXE_U3 - $T0) / 1000 }")
FIN_REL_U3=$(awk "BEGIN { printf \"%.3f\", ($FIN_U3 - $T0) / 1000 }")

WAIT_U3=$(awk "BEGIN { printf \"%.3f\", ($EXE_U3 - $SUB_U3) / 1000 }")
EXEC_U3=$(awk "BEGIN { printf \"%.3f\", ($FIN_U3 - $EXE_U3) / 1000 }")
TURN_U3=$(awk "BEGIN { printf \"%.3f\", ($FIN_U3 - $SUB_U3) / 1000 }")
RESP_U3=$WAIT_U3

printf "%-6s %-45s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U3" "ls -la" "$SUB_REL_U3" "$EXE_REL_U3" "$FIN_REL_U3" "$WAIT_U3" "$EXEC_U3" "$TURN_U3" "$RESP_U3"


SUB_U4=$(grep -i "submitted" logs/runner_u4_fifo.log | head -1 | awk '{print $1}')
EXE_U4=$(grep -i "executing" logs/runner_u4_fifo.log | head -1 | awk '{print $1}')
FIN_U4=$(grep -i "finished" logs/runner_u4_fifo.log | head -1 | awk '{print $1}')

SUB_REL_U4=$(awk "BEGIN { printf \"%.3f\", ($SUB_U4 - $T0) / 1000 }")
EXE_REL_U4=$(awk "BEGIN { printf \"%.3f\", ($EXE_U4 - $T0) / 1000 }")
FIN_REL_U4=$(awk "BEGIN { printf \"%.3f\", ($FIN_U4 - $T0) / 1000 }")

WAIT_U4=$(awk "BEGIN { printf \"%.3f\", ($EXE_U4 - $SUB_U4) / 1000 }")
EXEC_U4=$(awk "BEGIN { printf \"%.3f\", ($FIN_U4 - $EXE_U4) / 1000 }")
TURN_U4=$(awk "BEGIN { printf \"%.3f\", ($FIN_U4 - $SUB_U4) / 1000 }")
RESP_U4=$WAIT_U4

printf "%-6s %-45s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U4" "grep /bin /etc/passwd | cut -d: -f1" "$SUB_REL_U4" "$EXE_REL_U4" "$FIN_REL_U4" "$WAIT_U4" "$EXEC_U4" "$TURN_U4" "$RESP_U4"


SUB_U5=$(grep -i "submitted" logs/runner_u5_fifo.log | head -1 | awk '{print $1}')
EXE_U5=$(grep -i "executing" logs/runner_u5_fifo.log | head -1 | awk '{print $1}')
FIN_U5=$(grep -i "finished" logs/runner_u5_fifo.log | head -1 | awk '{print $1}')

SUB_REL_U5=$(awk "BEGIN { printf \"%.3f\", ($SUB_U5 - $T0) / 1000 }")
EXE_REL_U5=$(awk "BEGIN { printf \"%.3f\", ($EXE_U5 - $T0) / 1000 }")
FIN_REL_U5=$(awk "BEGIN { printf \"%.3f\", ($FIN_U5 - $T0) / 1000 }")

WAIT_U5=$(awk "BEGIN { printf \"%.3f\", ($EXE_U5 - $SUB_U5) / 1000 }")
EXEC_U5=$(awk "BEGIN { printf \"%.3f\", ($FIN_U5 - $EXE_U5) / 1000 }")
TURN_U5=$(awk "BEGIN { printf \"%.3f\", ($FIN_U5 - $SUB_U5) / 1000 }")
RESP_U5=$WAIT_U5

printf "%-6s %-45s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U5" "echo teste > /tmp/so_teste_output.txt" "$SUB_REL_U5" "$EXE_REL_U5" "$FIN_REL_U5" "$WAIT_U5" "$EXEC_U5" "$TURN_U5" "$RESP_U5"

echo ""
echo "Fórmulas usadas:"
echo "waiting_time    = executing - submitted"
echo "execution_time  = finished - executing"
echo "turnaround_time = finished - submitted"
echo "response_time   = executing - submitted"

echo ""
echo "Logs gerados:"
echo "logs/controller_fifo_5_users.log"
echo "logs/runner_u1_fifo.log"
echo "logs/runner_u2_fifo.log"
echo "logs/runner_u3_fifo.log"
echo "logs/runner_u4_fifo.log"
echo "logs/runner_u5_fifo.log"

echo ""
echo "A terminar controller..."
../runner -s > /dev/null 2>&1
sleep 1
kill $CONTROLLER_PID 2>/dev/null

echo ""
echo "=== Teste concluído ==="