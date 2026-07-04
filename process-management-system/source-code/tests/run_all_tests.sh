#!/bin/bash


PASS=0
FAIL=0

run_test() {
    local name=$1
    local script=$2

    echo ""
    echo "########################################################"
    echo "# $name"
    echo "########################################################"

    bash "$script"
    local ret=$?

    rm -f ../pipe_cont ../pipe_runner_* 2>/dev/null
    sleep 1

    if [ $ret -eq 0 ]; then
        echo ""
        echo ">>> $name: OK"
        PASS=$((PASS + 1))
    else
        echo ""
        echo ">>> $name: FALHOU (exit $ret)"
        FAIL=$((FAIL + 1))
    fi
}

echo "========================================================"
echo "  Testes — Projeto SO"
echo "========================================================"

run_test "Teste Básico"                    teste_basico.sh
run_test "Escalonamento FIFO 5 utilizadores" teste_fifo_5_users.sh
run_test "FAIR com paralelismo"            teste_fair_paralelismo.sh
run_test "Comparação FIFO vs FAIR"         teste_comparacao_fifo_fair.sh
run_test "Pipes e redirecionamento"        teste_pipes_redirecionamento.sh
run_test "Configurações de paralelismo"    teste_fair_configuracoes.sh

echo ""
echo "========================================================"
echo "  Resultados finais"
echo "========================================================"
echo "  Passou:  $PASS"
echo "  Falhou:  $FAIL"
echo "  Total:   $((PASS + FAIL))"
echo "========================================================"

if [ $FAIL -eq 0 ]; then
    echo "  Todos os testes passaram."
    exit 0
else
    echo "  Alguns testes falharam. Ver output acima."
    exit 1
fi
