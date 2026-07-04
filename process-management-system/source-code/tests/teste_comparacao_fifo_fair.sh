#!/usr/bin/env bash


echo "=== Teste Comparação FIFO vs FAIR ==="
echo ""

mkdir -p logs

rm -f pipe_cont pipe_runner_*
rm -f logs/comparacao_fifo_fair_*.log logs/comparacao_fifo_*.log logs/comparacao_fair_*.log

echo "Este teste executa o mesmo conjunto de comandos com:"
echo "- política FIFO, limite 1"
echo "- política FAIR, limite 1"
echo ""
echo "Objetivo:"
echo "- comparar a ordem de execução e os tempos de espera/resposta"
echo "- observar se FAIR distribui melhor as oportunidades entre utilizadores"
echo ""

echo "============================================================"
echo "TESTE 1: FIFO com limite de 1 comando em paralelo"
echo "============================================================"
echo ""

../controller 1 fifo > logs/comparacao_fifo_controller.log 2>&1 &
CONTROLLER_PID=$!

sleep 2

echo "A executar U1-A..."
../runner -e 1 sleep 3 > logs/comparacao_fifo_u1a.log 2>&1 &
PID_U1A=$!

sleep 0.2

echo "A executar U1-B..."
../runner -e 1 sleep 1 > logs/comparacao_fifo_u1b.log 2>&1 &
PID_U1B=$!

sleep 0.2

echo "A executar U1-C..."
../runner -e 1 sleep 1 > logs/comparacao_fifo_u1c.log 2>&1 &
PID_U1C=$!

sleep 0.2

echo "A executar U2..."
../runner -e 2 sleep 1 > logs/comparacao_fifo_u2.log 2>&1 &
PID_U2=$!

sleep 0.2

echo "A executar U3..."
../runner -e 3 sleep 1 > logs/comparacao_fifo_u3.log 2>&1 &
PID_U3=$!

echo ""
echo "A aguardar conclusão dos comandos FIFO..."
wait $PID_U1A
wait $PID_U1B
wait $PID_U1C
wait $PID_U2
wait $PID_U3

T0=$(grep -i "submitted" logs/comparacao_fifo_u1a.log | head -1 | awk '{print $1}')

echo ""
echo "Resultados FIFO:"
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"USER" "COMANDO" "SUBMIT(s)" "EXEC(s)" "FINISH(s)" "WAIT(s)" "EXEC_TIME(s)" "TURN(s)" "RESP(s)"
echo "--------------------------------------------------------------------------------------------------------------------------"

SUB=$(grep -i "submitted" logs/comparacao_fifo_u1a.log | head -1 | awk '{print $1}')
EXE=$(grep -i "executing" logs/comparacao_fifo_u1a.log | head -1 | awk '{print $1}')
FIN=$(grep -i "finished" logs/comparacao_fifo_u1a.log | head -1 | awk '{print $1}')
SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")
WAIT_TIME=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
RESP=$WAIT_TIME
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U1-A" "sleep 3" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT_TIME" "$EXEC_TIME" "$TURN" "$RESP"

SUB=$(grep -i "submitted" logs/comparacao_fifo_u1b.log | head -1 | awk '{print $1}')
EXE=$(grep -i "executing" logs/comparacao_fifo_u1b.log | head -1 | awk '{print $1}')
FIN=$(grep -i "finished" logs/comparacao_fifo_u1b.log | head -1 | awk '{print $1}')
SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")
WAIT_TIME=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
RESP=$WAIT_TIME
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U1-B" "sleep 1" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT_TIME" "$EXEC_TIME" "$TURN" "$RESP"

SUB=$(grep -i "submitted" logs/comparacao_fifo_u1c.log | head -1 | awk '{print $1}')
EXE=$(grep -i "executing" logs/comparacao_fifo_u1c.log | head -1 | awk '{print $1}')
FIN=$(grep -i "finished" logs/comparacao_fifo_u1c.log | head -1 | awk '{print $1}')
SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")
WAIT_TIME=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
RESP=$WAIT_TIME
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U1-C" "sleep 1" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT_TIME" "$EXEC_TIME" "$TURN" "$RESP"

SUB=$(grep -i "submitted" logs/comparacao_fifo_u2.log | head -1 | awk '{print $1}')
EXE=$(grep -i "executing" logs/comparacao_fifo_u2.log | head -1 | awk '{print $1}')
FIN=$(grep -i "finished" logs/comparacao_fifo_u2.log | head -1 | awk '{print $1}')
SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")
WAIT_TIME=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
RESP=$WAIT_TIME
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U2" "sleep 1" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT_TIME" "$EXEC_TIME" "$TURN" "$RESP"

SUB=$(grep -i "submitted" logs/comparacao_fifo_u3.log | head -1 | awk '{print $1}')
EXE=$(grep -i "executing" logs/comparacao_fifo_u3.log | head -1 | awk '{print $1}')
FIN=$(grep -i "finished" logs/comparacao_fifo_u3.log | head -1 | awk '{print $1}')
SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")
WAIT_TIME=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
RESP=$WAIT_TIME
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U3" "sleep 1" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT_TIME" "$EXEC_TIME" "$TURN" "$RESP"

echo ""
echo "A terminar controller FIFO..."
../runner -s > logs/comparacao_fifo_shutdown.log 2>&1
sleep 1
kill $CONTROLLER_PID 2>/dev/null

sleep 2

echo ""
echo "============================================================"
echo "TESTE 2: FAIR com limite de 1 comando em paralelo"
echo "============================================================"
echo ""

rm -f pipe_cont pipe_runner_*

../controller 1 fair > logs/comparacao_fair_controller.log 2>&1 &
CONTROLLER_PID=$!

sleep 2

echo "A executar U1-A..."
../runner -e 1 sleep 3 > logs/comparacao_fair_u1a.log 2>&1 &
PID_U1A=$!

sleep 0.2

echo "A executar U1-B..."
../runner -e 1 sleep 1 > logs/comparacao_fair_u1b.log 2>&1 &
PID_U1B=$!

sleep 0.2

echo "A executar U1-C..."
../runner -e 1 sleep 1 > logs/comparacao_fair_u1c.log 2>&1 &
PID_U1C=$!

sleep 0.2

echo "A executar U2..."
../runner -e 2 sleep 1 > logs/comparacao_fair_u2.log 2>&1 &
PID_U2=$!

sleep 0.2

echo "A executar U3..."
../runner -e 3 sleep 1 > logs/comparacao_fair_u3.log 2>&1 &
PID_U3=$!

echo ""
echo "A aguardar conclusão dos comandos FAIR..."
wait $PID_U1A
wait $PID_U1B
wait $PID_U1C
wait $PID_U2
wait $PID_U3

T0=$(grep -i "submitted" logs/comparacao_fair_u1a.log | head -1 | awk '{print $1}')

echo ""
echo "Resultados FAIR:"
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"USER" "COMANDO" "SUBMIT(s)" "EXEC(s)" "FINISH(s)" "WAIT(s)" "EXEC_TIME(s)" "TURN(s)" "RESP(s)"
echo "--------------------------------------------------------------------------------------------------------------------------"

SUB=$(grep -i "submitted" logs/comparacao_fair_u1a.log | head -1 | awk '{print $1}')
EXE=$(grep -i "executing" logs/comparacao_fair_u1a.log | head -1 | awk '{print $1}')
FIN=$(grep -i "finished" logs/comparacao_fair_u1a.log | head -1 | awk '{print $1}')
SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")
WAIT_TIME=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
RESP=$WAIT_TIME
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U1-A" "sleep 3" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT_TIME" "$EXEC_TIME" "$TURN" "$RESP"

SUB=$(grep -i "submitted" logs/comparacao_fair_u1b.log | head -1 | awk '{print $1}')
EXE=$(grep -i "executing" logs/comparacao_fair_u1b.log | head -1 | awk '{print $1}')
FIN=$(grep -i "finished" logs/comparacao_fair_u1b.log | head -1 | awk '{print $1}')
SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")
WAIT_TIME=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
RESP=$WAIT_TIME
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U1-B" "sleep 1" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT_TIME" "$EXEC_TIME" "$TURN" "$RESP"

SUB=$(grep -i "submitted" logs/comparacao_fair_u1c.log | head -1 | awk '{print $1}')
EXE=$(grep -i "executing" logs/comparacao_fair_u1c.log | head -1 | awk '{print $1}')
FIN=$(grep -i "finished" logs/comparacao_fair_u1c.log | head -1 | awk '{print $1}')
SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")
WAIT_TIME=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
RESP=$WAIT_TIME
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U1-C" "sleep 1" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT_TIME" "$EXEC_TIME" "$TURN" "$RESP"

SUB=$(grep -i "submitted" logs/comparacao_fair_u2.log | head -1 | awk '{print $1}')
EXE=$(grep -i "executing" logs/comparacao_fair_u2.log | head -1 | awk '{print $1}')
FIN=$(grep -i "finished" logs/comparacao_fair_u2.log | head -1 | awk '{print $1}')
SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")
WAIT_TIME=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
RESP=$WAIT_TIME
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U2" "sleep 1" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT_TIME" "$EXEC_TIME" "$TURN" "$RESP"

SUB=$(grep -i "submitted" logs/comparacao_fair_u3.log | head -1 | awk '{print $1}')
EXE=$(grep -i "executing" logs/comparacao_fair_u3.log | head -1 | awk '{print $1}')
FIN=$(grep -i "finished" logs/comparacao_fair_u3.log | head -1 | awk '{print $1}')
SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")
WAIT_TIME=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
RESP=$WAIT_TIME
printf "%-8s %-12s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
"U3" "sleep 1" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT_TIME" "$EXEC_TIME" "$TURN" "$RESP"

echo ""
echo "A terminar controller FAIR..."
../runner -s > logs/comparacao_fair_shutdown.log 2>&1
sleep 1
kill $CONTROLLER_PID 2>/dev/null

echo ""
echo "Fórmulas usadas:"
echo "waiting_time    = executing - submitted"
echo "response_time   = executing - submitted"
echo "execution_time  = finished - executing"
echo "turnaround_time = finished - submitted"

echo ""
echo "Logs gerados:"
echo "logs/comparacao_fifo_*.log"
echo "logs/comparacao_fair_*.log"

echo ""
echo "=== Teste Comparação FIFO vs FAIR Concluído ==="
