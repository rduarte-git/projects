#!/bin/bash

echo "=== Teste FAIR com paralelismo: 5 Utilizadores ==="
echo ""

mkdir -p logs

rm -f pipe_cont pipe_runner_*
rm -f logs/runner_u*_fair_parallel.log
rm -f logs/controller_fair_parallel.log

echo "Comandos do teste:"
echo "U1: sleep 5"
echo "U2: sleep 5"
echo "U1: sleep 2"
echo "U3: sleep 2"
echo "U4: sleep 2"
echo "U5: sleep 2"
echo ""

echo "A iniciar controller FAIR com 2 comandos máximos..."
../controller 2 fair > logs/controller_fair_parallel.log 2>&1 &
CONTROLLER_PID=$!

sleep 2

echo ""
echo "A executar U1 - comando longo..."
../runner -e 1 sleep 5 > logs/runner_u1_a_fair_parallel.log 2>&1 &
PID_U1_A=$!

sleep 0.2

echo "A executar U2 - comando longo..."
../runner -e 2 sleep 5 > logs/runner_u2_fair_parallel.log 2>&1 &
PID_U2=$!

sleep 0.2

echo "A executar U1 - segundo comando..."
../runner -e 1 sleep 2 > logs/runner_u1_b_fair_parallel.log 2>&1 &
PID_U1_B=$!

sleep 0.2

echo "A executar U3..."
../runner -e 3 sleep 2 > logs/runner_u3_fair_parallel.log 2>&1 &
PID_U3=$!

sleep 0.2

echo "A executar U4..."
../runner -e 4 sleep 2 > logs/runner_u4_fair_parallel.log 2>&1 &
PID_U4=$!

sleep 0.2

echo "A executar U5..."
../runner -e 5 sleep 2 > logs/runner_u5_fair_parallel.log 2>&1 &
PID_U5=$!

echo ""
echo "A aguardar conclusão dos comandos..."

echo "À espera do U1 primeiro comando..."
wait $PID_U1_A
echo "U1 primeiro comando terminou"

echo "À espera do U2..."
wait $PID_U2
echo "U2 terminou"

echo "À espera do U1 segundo comando..."
wait $PID_U1_B
echo "U1 segundo comando terminou"

echo "À espera do U3..."
wait $PID_U3
echo "U3 terminou"

echo "À espera do U4..."
wait $PID_U4
echo "U4 terminou"

echo "À espera do U5..."
wait $PID_U5
echo "U5 terminou"

echo ""
echo "=== Resultados extraídos dos logs ==="
echo ""

# Primeiro timestamp do teste
T0=$(grep -i "submitted" logs/runner_u1_a_fair_parallel.log | head -1 | awk '{print $1}')

printf "%-8s %-20s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"USER" "COMANDO" "SUBMIT(s)" "EXEC(s)" "FINISH(s)" "WAIT(s)" "EXEC_TIME(s)" "TURN(s)" "RESP(s)"

echo "------------------------------------------------------------------------------------------------------------------------"

print_result() {
    USER=$1
    CMD=$2
    FILE=$3

    SUB=$(grep -i "submitted" "$FILE" | head -1 | awk '{print $1}')
    EXE=$(grep -i "executing" "$FILE" | head -1 | awk '{print $1}')
    FIN=$(grep -i "finished" "$FILE" | head -1 | awk '{print $1}')

    SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
    EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
    FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")

    WAIT=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
    EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
    TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
    RESP=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")

    printf "%-8s %-20s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
    "$USER" "$CMD" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT" "$EXEC_TIME" "$TURN" "$RESP"
}

print_result "U1-A" "sleep 5" "logs/runner_u1_a_fair_parallel.log"
print_result "U2"   "sleep 5" "logs/runner_u2_fair_parallel.log"
print_result "U1-B" "sleep 2" "logs/runner_u1_b_fair_parallel.log"
print_result "U3"   "sleep 2" "logs/runner_u3_fair_parallel.log"
print_result "U4"   "sleep 2" "logs/runner_u4_fair_parallel.log"
print_result "U5"   "sleep 2" "logs/runner_u5_fair_parallel.log"

echo ""
echo "Logs gerados:"
echo "logs/controller_fair_parallel.log"
echo "logs/runner_u1_a_fair_parallel.log"
echo "logs/runner_u2_fair_parallel.log"
echo "logs/runner_u1_b_fair_parallel.log"
echo "logs/runner_u3_fair_parallel.log"
echo "logs/runner_u4_fair_parallel.log"
echo "logs/runner_u5_fair_parallel.log"

echo ""
echo "A terminar controller..."
../runner -s > /dev/null 2>&1

sleep 1
kill $CONTROLLER_PID 2>/dev/null

echo ""
echo "=== Teste concluído ==="