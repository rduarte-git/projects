package ui;

import dominio.EstadoPedido;
import dominio.Ingrediente;
import dominio.ItemPedido;
import dominio.OpcaoPersonalizacao;
import dominio.Pedido;
import dominio.Personalizacao;
import dominio.Produto;
import ln.ICafetariaLN;
import ln.pedidos.FilaPreparacao;
import ln.pedidos.Indicadores;
import ln.pedidos.ItemFila;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

public class CafetariaUI {
    private ICafetariaLN cafetaria;
    private Scanner scanner;

    public CafetariaUI(ICafetariaLN cafetaria) {
        this.cafetaria = cafetaria;
        this.scanner = new Scanner(System.in);
    }

    public void run() {
        int opcao = -1;
        while (opcao != 0) {
            mostrarMenu();
            opcao = lerInteiro("Opcao: ");
            executar(opcao);
        }
        System.out.println("A sair.");
    }

    private void mostrarMenu() {
        System.out.println();
        System.out.println("===== CAFETARIA =====");
        System.out.println("1 - Registar pedido");
        System.out.println("2 - Consultar estado de pedido");
        System.out.println("3 - Entregar pedido");
        System.out.println("4 - Zona de preparacao");
        System.out.println("5 - Area de gestao");
        System.out.println("0 - Sair");
    }

    private void executar(int opcao) {
        if (opcao == 1) {
            registarPedido();
        } else if (opcao == 2) {
            consultarEstado();
        } else if (opcao == 3) {
            entregarPedido();
        } else if (opcao == 4) {
            menuPreparacao();
        } else if (opcao == 5) {
            menuGestao();
        } else if (opcao != 0) {
            System.out.println("Opcao invalida.");
        }
    }

    // ---- submenus por area ----

    private void menuPreparacao() {
        int opcao = -1;
        while (opcao != 0) {
            System.out.println();
            System.out.println("--- Zona de preparacao ---");
            System.out.println("1 - Consultar fila de preparacao");
            System.out.println("2 - Marcar item como pronto");
            System.out.println("0 - Voltar");
            opcao = lerInteiro("Opcao: ");
            if (opcao == 1) {
                consultarFila();
            } else if (opcao == 2) {
                marcarItemPronto();
            } else if (opcao != 0) {
                System.out.println("Opcao invalida.");
            }
        }
    }

    private void menuGestao() {
        int opcao = -1;
        while (opcao != 0) {
            System.out.println();
            System.out.println("--- Area de gestao ---");
            System.out.println("1 - Consultar indicadores de gestao");
            System.out.println("2 - Consultar stock de ingredientes");
            System.out.println("0 - Voltar");
            opcao = lerInteiro("Opcao: ");
            if (opcao == 1) {
                consultarIndicadores();
            } else if (opcao == 2) {
                consultarStock();
            } else if (opcao != 0) {
                System.out.println("Opcao invalida.");
            }
        }
    }

    // ---- opcoes do menu ----

    private void registarPedido() {
        int numero = cafetaria.iniciarPedido();
        System.out.println("Novo pedido numero " + numero);
        mostrarProdutos();
        boolean adicionouAlgum = false;
        boolean continuar = true;
        while (continuar) {
            String cod = lerTexto("Codigo do produto (ou 'fim'): ");
            if (cod.equals("fim")) {
                continuar = false;
            } else {
                adicionarProduto(numero, cod);
                adicionouAlgum = true;
            }
        }
        if (!adicionouAlgum) {
            cafetaria.cancelarPedido(numero);
            System.out.println("Pedido sem itens - cancelado.");
            return;
        }
        Pedido pedido = cafetaria.confirmarPedido(numero);
        System.out.println("Pedido " + pedido.getNumero() + " registado. Total: " + pedido.getTotal()
                + " EUR. Estado: " + pedido.getEstado());
    }

    private void adicionarProduto(int numero, String cod) {
        int qtd = lerInteiro("Quantidade: ");
        List<String> opcoes = lerOpcoes(cod);
        cafetaria.adicionarItem(numero, cod, qtd, opcoes);
    }

    private List<String> lerOpcoes(String cod) {
        List<String> escolhidas = new ArrayList<>();
        List<Personalizacao> personalizacoes = cafetaria.consultarPersonalizacoes(cod);
        if (personalizacoes.isEmpty()) {
            return escolhidas;
        }
        mostrarPersonalizacoes(personalizacoes);
        String linha = lerTexto("Codigos de opcao (separados por espaco, ou vazio): ");
        if (!linha.isEmpty()) {
            String[] codigos = linha.split(" ");
            for (String c : codigos) {
                escolhidas.add(c);
            }
        }
        return escolhidas;
    }

    private void consultarEstado() {
        int numPedido = lerInteiroOuVazio("Numero do pedido (Enter para listar todos): ");
        if (numPedido == -1) {
            if (!mostrarPedidosEmCurso()) {
                return;
            }
            numPedido = lerInteiroOuVazio("Numero do pedido: ");
            if (numPedido == -1) {
                return;
            }
        }
        Pedido pedido = cafetaria.consultarPedido(numPedido);
        if (pedido == null) {
            System.out.println("Pedido nao encontrado.");
            return;
        }
        mostrarDetalhePedido(pedido);
    }

    private void entregarPedido() {
        List<Pedido> prontos = cafetaria.listarPedidosProntos();
        if (prontos.isEmpty()) {
            System.out.println("Nao ha pedidos prontos para entregar.");
            return;
        }
        System.out.println("Pedidos prontos:");
        for (Pedido p : prontos) {
            System.out.println("  Pedido " + p.getNumero());
        }
        int numPedido = lerInteiroOuVazio("Numero do pedido a entregar: ");
        if (numPedido == -1) {
            System.out.println("Entrega cancelada.");
            return;
        }
        Pedido pedido = cafetaria.entregarPedido(numPedido);
        if (pedido == null) {
            System.out.println("Pedido nao encontrado.");
        } else {
            System.out.println("Pedido " + pedido.getNumero() + " entregue.");
        }
    }

    private void consultarFila() {
        FilaPreparacao fila = cafetaria.consultarFilaPreparacao();
        System.out.println("--- Fila de preparacao (estimativa: " + fila.getEstimativa() + " min) ---");
        if (fila.getItens().isEmpty()) {
            System.out.println("(vazia)");
            return;
        }
        for (ItemFila linha : fila.getItens()) {
            ItemPedido item = linha.getItem();
            System.out.println("Pedido " + linha.getNumeroPedido()
                    + " - Item " + item.getNumeroItem() + ": "
                    + item.getProduto().getNome() + " x" + item.getQuantidade()
                    + formatarOpcoes(item.getOpcoes()));
        }
    }

    private String formatarOpcoes(List<OpcaoPersonalizacao> opcoes) {
        if (opcoes == null || opcoes.isEmpty()) {
            return "";
        }
        String texto = "";
        for (OpcaoPersonalizacao op : opcoes) {
            if (!texto.isEmpty()) {
                texto = texto + ", ";
            }
            texto = texto + op.getDescricao();
        }
        return " [" + texto + "]";
    }

    private void marcarItemPronto() {
        int numPedido = lerInteiro("Numero do pedido: ");
        int numItem = lerInteiro("Numero do item: ");
        EstadoPedido estado = cafetaria.marcarItemPronto(numPedido, numItem);
        if (estado == null) {
            System.out.println("Pedido nao encontrado.");
        } else {
            System.out.println("Item marcado. Estado do pedido: " + estado);
        }
    }

    private void consultarIndicadores() {
        LocalDate inicio = lerData("Data de inicio (aaaa-mm-dd): ");
        LocalDate fim = lerData("Data de fim (aaaa-mm-dd): ");
        Indicadores indicadores = cafetaria.consultarIndicadores(inicio, fim);
        if (indicadores == null) {
            System.out.println("Periodo invalido.");
            return;
        }
        System.out.println("Numero de pedidos: " + indicadores.getNumPedidos());
        System.out.println("Valor total vendido: " + indicadores.getValorTotal() + " EUR");
        System.out.println("Mais vendidos:");
        Map<String, Integer> maisVendidos = indicadores.getMaisVendidos();
        for (String produto : maisVendidos.keySet()) {
            System.out.println("  " + produto + ": " + maisVendidos.get(produto));
        }
    }

    private void consultarStock() {
        System.out.println("--- Stock de ingredientes ---");
        for (Ingrediente ing : cafetaria.consultarStock()) {
            String aviso = "";
            if (ing.noNivelMinimo()) {
                aviso = "  ** NIVEL MINIMO **";
            }
            System.out.println(ing.getNome() + ": " + ing.getQuantidadeEmStock() + " " + ing.getUnidade()
                    + " (minimo: " + ing.getNivelMinimo() + " " + ing.getUnidade() + ")" + aviso);
        }
    }


    private void mostrarProdutos() {
        System.out.println("--- Produtos ---");
        for (Produto p : cafetaria.listarProdutos()) {
            System.out.println(p.getCodProduto() + " - " + p.getNome() + " (" + p.getPreco() + " EUR)");
        }
    }

    private void mostrarPersonalizacoes(List<Personalizacao> personalizacoes) {
        System.out.println("Personalizacoes:");
        for (Personalizacao pers : personalizacoes) {
            System.out.print("  " + pers.getNome() + ": ");
            for (OpcaoPersonalizacao op : pers.getOpcoes()) {
                System.out.print(op.getCodigo() + "=" + op.getDescricao() + "  ");
            }
            System.out.println();
        }
    }

    private boolean mostrarPedidosEmCurso() {
        List<Pedido> emCurso = cafetaria.listarPedidosEmCurso();
        if (emCurso.isEmpty()) {
            System.out.println("Nao ha pedidos em curso.");
            return false;
        }
        System.out.println("Pedidos em curso:");
        for (Pedido p : emCurso) {
            System.out.println("  Pedido " + p.getNumero() + " - " + p.getEstado());
        }
        return true;
    }

    private void mostrarDetalhePedido(Pedido pedido) {
        System.out.println("Pedido " + pedido.getNumero() + " - Estado: " + pedido.getEstado());
        for (ItemPedido item : pedido.getItens()) {
            String estadoItem = "por preparar";
            if (item.isPronto()) {
                estadoItem = "pronto";
            }
            System.out.println("  Item " + item.getNumeroItem() + ": " + item.getProduto().getNome() + " (" + estadoItem + ")");
        }
    }


    private int lerInteiro(String mensagem) {
        boolean valido = false;
        int valor = 0;
        while (!valido) {
            System.out.print(mensagem);
            String linha = scanner.nextLine().trim();
            try {
                valor = Integer.parseInt(linha);
                valido = true;
            } catch (NumberFormatException e) {
                System.out.println("Valor invalido. Escreva um numero.");
            }
        }
        return valor;
    }

    private int lerInteiroOuVazio(String mensagem) {
        System.out.print(mensagem);
        String linha = scanner.nextLine().trim();
        if (linha.isEmpty()) {
            return -1;
        }
        try {
            return Integer.parseInt(linha);
        } catch (NumberFormatException e) {
            System.out.println("Valor invalido.");
            return -1;
        }
    }

    private String lerTexto(String mensagem) {
        System.out.print(mensagem);
        return scanner.nextLine().trim();
    }

    private LocalDate lerData(String mensagem) {
        boolean valida = false;
        LocalDate data = null;
        while (!valida) {
            String linha = lerTexto(mensagem);
            try {
                data = LocalDate.parse(linha);
                valida = true;
            } catch (DateTimeParseException e) {
                System.out.println("Data invalida. Use o formato aaaa-mm-dd.");
            }
        }
        return data;
    }
}
