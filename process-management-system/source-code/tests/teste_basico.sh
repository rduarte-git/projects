#!/bin/bash

echo "=== Teste Básico do Sistema ==="
echo ""

mkdir -p logs

rm -f pipe_cont pipe_runner_*
rm -f logs/teste_basico_controller.log
rm -f logs/teste_basico_runner_*.log

echo "1. Iniciar controller FIFO com limite de 1 comando..."
../controller 1 fifo > logs/teste_basico_controller.log 2>&1 &
CONTROLLER_PID=$!

sleep 2

if ! kill -0 $CONTROLLER_PID 2>/dev/null; then
    echo "ERRO: controller não iniciou corretamente."
    echo "Verificar logs/teste_basico_controller.log"
    exit 1
fi

echo "Controller iniciado com PID $CONTROLLER_PID"
echo ""

echo "2. Executar comando simples: echo"
../runner -e 1 echo "Ola Mundo" > logs/teste_basico_runner_echo.log 2>&1

if [ $? -eq 0 ]; then
    echo "OK: comando echo executado."
else
    echo "ERRO: comando echo falhou."
fi

echo ""
echo "Output do runner echo:"
cat logs/teste_basico_runner_echo.log
echo ""

echo "3. Executar comando demorado: sleep 5"
../runner -e 2 sleep 5 > logs/teste_basico_runner_sleep.log 2>&1 &
PID_SLEEP=$!

sleep 1

echo ""
echo "4. Consultar estado durante execução:"
../runner -c > logs/teste_basico_runner_status_1.log 2>&1
cat logs/teste_basico_runner_status_1.log
echo ""

echo "5. Submeter outro comando enquanto sleep está a executar: ls"
../runner -e 3 ls > logs/teste_basico_runner_ls.log 2>&1 &
PID_LS=$!

sleep 1

echo ""
echo "6. Consultar estado com um comando em execução e outro em espera:"
../runner -c > logs/teste_basico_runner_status_2.log 2>&1
cat logs/teste_basico_runner_status_2.log
echo ""

echo "7. Aguardar conclusão dos comandos..."
wait $PID_SLEEP
wait $PID_LS

echo "OK: comandos terminaram."
echo ""

echo "8. Consultar estado final:"
../runner -c > logs/teste_basico_runner_status_final.log 2>&1
cat logs/teste_basico_runner_status_final.log
echo ""

echo "9. Terminar controller..."
../runner -s > logs/teste_basico_runner_shutdown.log 2>&1

sleep 1

if kill -0 $CONTROLLER_PID 2>/dev/null; then
    echo "Controller ainda ativo. A forçar terminação..."
    kill $CONTROLLER_PID 2>/dev/null
else
    echo "OK: controller terminou corretamente."
fi

echo ""
echo "Logs gerados:"
echo "logs/teste_basico_controller.log"
echo "logs/teste_basico_runner_echo.log"
echo "logs/teste_basico_runner_sleep.log"
echo "logs/teste_basico_runner_ls.log"
echo "logs/teste_basico_runner_status_1.log"
echo "logs/teste_basico_runner_status_2.log"
echo "logs/teste_basico_runner_status_final.log"
echo "logs/teste_basico_runner_shutdown.log"

echo ""
echo "=== Teste Básico Concluído ==="