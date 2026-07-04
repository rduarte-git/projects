#!/bin/bash

echo "=== Teste de Pipes e Redirecionamentos ==="
echo ""

mkdir -p logs

rm -f pipe_cont pipe_runner_*
rm -f logs/teste_pipes_redir_*.log
rm -f /tmp/so_teste_out.txt
rm -f /tmp/so_teste_append.txt
rm -f /tmp/so_teste_input.txt
rm -f /tmp/so_teste_error.txt
rm -f /tmp/so_teste_error_append.txt
rm -f /tmp/so_teste_pipe.txt


echo "1. Iniciar controller FIFO com limite de 2 comandos..."
../controller 2 fifo > logs/teste_pipes_redir_controller.log 2>&1 &
CONTROLLER_PID=$!

sleep 2

if ! kill -0 $CONTROLLER_PID 2>/dev/null; then
    echo "ERRO: controller não iniciou corretamente."
    echo "Verificar logs/teste_pipes_redir_controller.log"
    exit 1
fi

echo "Controller iniciado com PID $CONTROLLER_PID"
echo ""

echo "3. Testar pipe simples:"
echo "   Comando: echo ola mundo | wc -w"

../runner -e 1 "echo ola mundo | wc -w" > logs/teste_pipes_redir_pipe_simple.log 2>&1

echo "Output:"
cat logs/teste_pipes_redir_pipe_simple.log
echo ""

echo "4. Testar pipe com ficheiro do sistema:"
echo "   Comando: grep /bin /etc/passwd | wc -l"

../runner -e 2 "grep /bin /etc/passwd | wc -l" > logs/teste_pipes_redir_pipe_grep.log 2>&1

echo "Output:"
cat logs/teste_pipes_redir_pipe_grep.log
echo ""

echo "5. Testar redirecionamento de output >"
echo "   Comando: echo teste_output > /tmp/so_teste_out.txt"

../runner -e 3 "echo teste_output > /tmp/so_teste_out.txt" > logs/teste_pipes_redir_output.log 2>&1

echo "Conteúdo esperado em /tmp/so_teste_out.txt:"
cat /tmp/so_teste_out.txt 2>/dev/null || echo "ERRO: ficheiro não foi criado"
echo ""

echo "6. Testar redirecionamento de append >>"
echo "   Comando: echo linha1 > /tmp/so_teste_append.txt"
echo "   Comando: echo linha2 >> /tmp/so_teste_append.txt"

../runner -e 4 "echo linha1 > /tmp/so_teste_append.txt" > logs/teste_pipes_redir_append_1.log 2>&1
../runner -e 4 "echo linha2 >> /tmp/so_teste_append.txt" > logs/teste_pipes_redir_append_2.log 2>&1

echo "Conteúdo esperado em /tmp/so_teste_append.txt:"
cat /tmp/so_teste_append.txt 2>/dev/null || echo "ERRO: ficheiro não foi criado"
echo ""

echo "7. Testar redirecionamento de input <"
echo "   A criar ficheiro /tmp/so_teste_input.txt"
echo "texto para teste input" > /tmp/so_teste_input.txt

echo "   Comando: wc -w < /tmp/so_teste_input.txt"

../runner -e 5 "wc -w < /tmp/so_teste_input.txt" > logs/teste_pipes_redir_input.log 2>&1

echo "Output:"
cat logs/teste_pipes_redir_input.log
echo ""

echo "8. Testar redirecionamento de erro 2>"
echo "   Comando: ls /diretorio_inexistente 2> /tmp/so_teste_error.txt"

../runner -e 6 "ls /diretorio_inexistente 2> /tmp/so_teste_error.txt" > logs/teste_pipes_redir_error.log 2>&1

echo "Conteúdo esperado em /tmp/so_teste_error.txt:"
cat /tmp/so_teste_error.txt 2>/dev/null || echo "ERRO: ficheiro de erro não foi criado"
echo ""

echo "9. Testar redirecionamento de erro com append 2>>"
echo "   Comando: ls /erro_um 2> /tmp/so_teste_error_append.txt"
echo "   Comando: ls /erro_dois 2>> /tmp/so_teste_error_append.txt"

../runner -e 7 "ls /erro_um 2> /tmp/so_teste_error_append.txt" > logs/teste_pipes_redir_error_append_1.log 2>&1
../runner -e 7 "ls /erro_dois 2>> /tmp/so_teste_error_append.txt" > logs/teste_pipes_redir_error_append_2.log 2>&1

echo "Conteúdo esperado em /tmp/so_teste_error_append.txt:"
cat /tmp/so_teste_error_append.txt 2>/dev/null || echo "ERRO: ficheiro de erro append não foi criado"
echo ""

echo "10. Testar pipe com redirecionamento final:"
echo "    Comando: grep root /etc/passwd | cut -d: -f1 > /tmp/so_teste_pipe.txt"

../runner -e 8 "grep root /etc/passwd | cut -d: -f1 > /tmp/so_teste_pipe.txt" > logs/teste_pipes_redir_pipe_output.log 2>&1

echo "Conteúdo esperado em /tmp/so_teste_pipe.txt:"
cat /tmp/so_teste_pipe.txt 2>/dev/null || echo "ERRO: ficheiro não foi criado"
echo ""

echo "11. Terminar controller..."
../runner -s > logs/teste_pipes_redir_shutdown.log 2>&1

sleep 1

if kill -0 $CONTROLLER_PID 2>/dev/null; then
    echo "Controller ainda ativo. A forçar terminação..."
    kill $CONTROLLER_PID 2>/dev/null
else
    echo "OK: controller terminou corretamente."
fi

echo ""
echo "Logs gerados:"
echo "logs/teste_pipes_redir_controller.log"
echo "logs/teste_pipes_redir_pipe_simple.log"
echo "logs/teste_pipes_redir_pipe_grep.log"
echo "logs/teste_pipes_redir_output.log"
echo "logs/teste_pipes_redir_append_1.log"
echo "logs/teste_pipes_redir_append_2.log"
echo "logs/teste_pipes_redir_input.log"
echo "logs/teste_pipes_redir_error.log"
echo "logs/teste_pipes_redir_error_append_1.log"
echo "logs/teste_pipes_redir_error_append_2.log"
echo "logs/teste_pipes_redir_pipe_output.log"
echo "logs/teste_pipes_redir_shutdown.log"

echo ""
echo "Ficheiros temporários usados:"
echo "/tmp/so_teste_out.txt"
echo "/tmp/so_teste_append.txt"
echo "/tmp/so_teste_input.txt"
echo "/tmp/so_teste_error.txt"
echo "/tmp/so_teste_error_append.txt"
echo "/tmp/so_teste_pipe.txt"

echo ""
echo "=== Teste de Pipes e Redirecionamentos Concluído ==="