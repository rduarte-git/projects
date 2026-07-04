#!/usr/bin/env bash


echo "=== Teste FAIR com diferentes limites de paralelismo ==="
echo ""

mkdir -p logs

rm -f pipe_cont pipe_runner_*
rm -f logs/config_fair_*.log

echo "Este teste executa o mesmo conjunto de comandos com:"
echo "- limite 1"
echo "- limite 2"
echo "- limite 4"
echo ""
echo "Cenário usado: 4 utilizadores, 2 comandos por utilizador."
echo ""

LIMITS=(1 2 4)

for LIMIT in "${LIMITS[@]}"; do
    echo "============================================================"
    echo "TESTE: FAIR com limite de $LIMIT comando(s) em paralelo"
    echo "============================================================"
    echo ""

    rm -f pipe_cont pipe_runner_*

    ../controller "$LIMIT" fair > "logs/config_fair_${LIMIT}_controller.log" 2>&1 &
    CONTROLLER_PID=$!

    sleep 2

    USERS=(1 2 3 4 1 2 3 4)
    LABELS=("U1-A" "U2-A" "U3-A" "U4-A" "U1-B" "U2-B" "U3-B" "U4-B")
    COMMANDS=("sleep 4" "sleep 4" "sleep 2" "sleep 2" "sleep 2" "sleep 2" "sleep 1" "sleep 1")
    LOGS=(
        "logs/config_fair_${LIMIT}_u1_a.log"
        "logs/config_fair_${LIMIT}_u2_a.log"
        "logs/config_fair_${LIMIT}_u3_a.log"
        "logs/config_fair_${LIMIT}_u4_a.log"
        "logs/config_fair_${LIMIT}_u1_b.log"
        "logs/config_fair_${LIMIT}_u2_b.log"
        "logs/config_fair_${LIMIT}_u3_b.log"
        "logs/config_fair_${LIMIT}_u4_b.log"
    )

    PIDS=()

    for i in "${!USERS[@]}"; do
        echo "A executar ${LABELS[$i]}: ${COMMANDS[$i]}"
        ../runner -e "${USERS[$i]}" ${COMMANDS[$i]} > "${LOGS[$i]}" 2>&1 &
        PIDS[$i]=$!
        sleep 0.2
    done

    echo ""
    echo "A aguardar conclusão dos comandos..."
    for PID in "${PIDS[@]}"; do
        wait "$PID"
    done

    T0=$(grep -i "submitted" "${LOGS[0]}" | head -1 | awk '{print $1}')

    echo ""
    echo "Resultados FAIR limite $LIMIT:"
    printf "%-7s %-10s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
    "USER" "COMANDO" "SUBMIT(s)" "EXEC(s)" "FINISH(s)" "WAIT(s)" "EXEC_TIME(s)" "TURN(s)" "RESP(s)"
    echo "------------------------------------------------------------------------------------------------------------------------"

    TOTAL_WAIT=0
    TOTAL_TURN=0
    TOTAL_RESP=0
    COUNT=0

    for i in "${!USERS[@]}"; do
        SUB=$(grep -i "submitted" "${LOGS[$i]}" | head -1 | awk '{print $1}')
        EXE=$(grep -i "executing" "${LOGS[$i]}" | head -1 | awk '{print $1}')
        FIN=$(grep -i "finished" "${LOGS[$i]}" | head -1 | awk '{print $1}')

        SUB_REL=$(awk "BEGIN { printf \"%.3f\", ($SUB - $T0) / 1000 }")
        EXE_REL=$(awk "BEGIN { printf \"%.3f\", ($EXE - $T0) / 1000 }")
        FIN_REL=$(awk "BEGIN { printf \"%.3f\", ($FIN - $T0) / 1000 }")
        WAIT_TIME=$(awk "BEGIN { printf \"%.3f\", ($EXE - $SUB) / 1000 }")
        EXEC_TIME=$(awk "BEGIN { printf \"%.3f\", ($FIN - $EXE) / 1000 }")
        TURN=$(awk "BEGIN { printf \"%.3f\", ($FIN - $SUB) / 1000 }")
        RESP=$WAIT_TIME

        printf "%-7s %-10s %-12s %-12s %-12s %-12s %-14s %-12s %-12s\n" \
        "${LABELS[$i]}" "${COMMANDS[$i]}" "$SUB_REL" "$EXE_REL" "$FIN_REL" "$WAIT_TIME" "$EXEC_TIME" "$TURN" "$RESP"

        TOTAL_WAIT=$(awk "BEGIN { printf \"%.3f\", $TOTAL_WAIT + $WAIT_TIME }")
        TOTAL_TURN=$(awk "BEGIN { printf \"%.3f\", $TOTAL_TURN + $TURN }")
        TOTAL_RESP=$(awk "BEGIN { printf \"%.3f\", $TOTAL_RESP + $RESP }")
        COUNT=$((COUNT + 1))
    done

    AVG_WAIT=$(awk "BEGIN { printf \"%.3f\", $TOTAL_WAIT / $COUNT }")
    AVG_TURN=$(awk "BEGIN { printf \"%.3f\", $TOTAL_TURN / $COUNT }")
    AVG_RESP=$(awk "BEGIN { printf \"%.3f\", $TOTAL_RESP / $COUNT }")

    echo ""
    echo "Médias FAIR limite $LIMIT:"
    echo "waiting_time médio    = ${AVG_WAIT}s"
    echo "response_time médio   = ${AVG_RESP}s"
    echo "turnaround_time médio = ${AVG_TURN}s"

    echo ""
    echo "A terminar controller do teste limite $LIMIT..."
    ../runner -s > "logs/config_fair_${LIMIT}_shutdown.log" 2>&1
    sleep 1
    kill "$CONTROLLER_PID" 2>/dev/null

    sleep 2
    echo ""
done

echo "Fórmulas usadas:"
echo "waiting_time    = executing - submitted"
echo "response_time   = executing - submitted"
echo "execution_time  = finished - executing"
echo "turnaround_time = finished - submitted"

echo ""
echo "Logs gerados:"
echo "logs/config_fair_1_*.log"
echo "logs/config_fair_2_*.log"
echo "logs/config_fair_4_*.log"

echo ""
echo "=== Teste FAIR com configurações concluído ==="
