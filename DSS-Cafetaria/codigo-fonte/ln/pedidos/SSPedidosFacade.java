package ln.pedidos;

import dados.IPedidosDAO;
import dominio.Pedido;
import dominio.ItemPedido;
import dominio.Produto;
import dominio.ProdutoPreparado;
import dominio.ComposicaoProduto;
import dominio.OpcaoPersonalizacao;
import dominio.EstadoPedido;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SSPedidosFacade implements IGestPedidos {
    private IPedidosDAO pedidosDAO;
    private int proximoNumero;

    public SSPedidosFacade(IPedidosDAO pedidosDAO) {
        this.pedidosDAO = pedidosDAO;
        this.proximoNumero = 1;
    }

    @Override
    public int iniciarPedido() {
        int numero = proximoNumero;
        proximoNumero = proximoNumero + 1;
        Pedido pedido = new Pedido(numero, LocalDateTime.now());
        pedidosDAO.guardar(pedido);
        return numero;
    }

    @Override
    public void adicionarItem(int numPedido, Produto produto, int quantidade, List<OpcaoPersonalizacao> opcoes) {
        Pedido pedido = pedidosDAO.obter(numPedido);
        if (pedido != null) {
            pedido.adicionarItem(produto, quantidade, opcoes);
            pedidosDAO.guardar(pedido);
        }
    }

    @Override
    public Pedido confirmarPedido(int numPedido) {
        Pedido pedido = pedidosDAO.obter(numPedido);
        if (pedido != null) {
            pedido.confirmar();
            pedidosDAO.guardar(pedido);
        }
        return pedido;
    }

    @Override
    public void cancelarPedido(int numPedido) {
        pedidosDAO.remove(numPedido);
    }

    @Override
    public Pedido consultarPedido(int numPedido) {
        return pedidosDAO.obter(numPedido);
    }

    @Override
    public List<Pedido> listarPedidosEmCurso() {
        List<Pedido> emCurso = new ArrayList<>();
        for (Pedido pedido : pedidosDAO.obterTodos()) {
            if (pedido.getEstado() != EstadoPedido.ENTREGUE) {
                emCurso.add(pedido);
            }
        }
        return emCurso;
    }

    @Override
    public List<Pedido> listarPedidosProntos() {
        List<Pedido> prontos = new ArrayList<>();
        for (Pedido pedido : pedidosDAO.obterTodos()) {
            if (pedido.getEstado() == EstadoPedido.PRONTO) {
                prontos.add(pedido);
            }
        }
        return prontos;
    }

    @Override
    public Pedido entregarPedido(int numPedido) {
        Pedido pedido = pedidosDAO.obter(numPedido);
        if (pedido != null) {
            pedido.entregar();
            pedidosDAO.guardar(pedido);
        }
        return pedido;
    }

    @Override
    public EstadoPedido marcarItemPronto(int numPedido, int numeroItem) {
        Pedido pedido = pedidosDAO.obter(numPedido);
        if (pedido == null) {
            return null;
        }
        EstadoPedido estado = pedido.marcarItemPronto(numeroItem);
        pedidosDAO.guardar(pedido);
        return estado;
    }

    @Override
    public FilaPreparacao consultarFilaPreparacao() {
        List<ItemFila> itens = new ArrayList<>();
        int estimativa = 0;
        for (Pedido pedido : pedidosDAO.obterTodos()) {
            if (pedido.getEstado() == EstadoPedido.EM_PREPARACAO) {
                for (ItemPedido item : pedido.itensPorPreparar()) {
                    // junta o item ao numero do pedido a que pertence
                    itens.add(new ItemFila(pedido.getNumero(), item));
                    estimativa = estimativa + tempoDoItem(item);
                }
            }
        }
        return new FilaPreparacao(itens, estimativa);
    }

    @Override
    public Indicadores consultarIndicadores(LocalDate inicio, LocalDate fim) {
        if (inicio.isAfter(fim)) {
            // periodo invalido
            return null;
        }
        List<Pedido> doPeriodo = pedidosDAO.obterPorPeriodo(inicio, fim);
        int numPedidos = doPeriodo.size();
        double valorTotal = calcularValorTotal(doPeriodo);
        Map<String, Integer> maisVendidos = calcularMaisVendidos(doPeriodo);
        return new Indicadores(numPedidos, valorTotal, maisVendidos);
    }

    @Override
    public Map<String, Double> calcularConsumoPedido(int numPedido) {
        Map<String, Double> consumo = new HashMap<>();
        Pedido pedido = pedidosDAO.obter(numPedido);
        if (pedido == null) {
            return consumo;
        }
        for (ItemPedido item : pedido.getItens()) {
            for (ComposicaoProduto linha : item.getProduto().getComposicao()) {
                String ingrediente = linha.getIngrediente().getNome();
                double quantidade = item.getQuantidade() * linha.getQuantidade();
                somarConsumo(consumo, ingrediente, quantidade);
            }
        }
        return consumo;
    }

    // ---- metodos auxiliares (privados) ----

    private int tempoDoItem(ItemPedido item) {
        // so os produtos que precisam de preparacao tem tempo estimado
        Produto produto = item.getProduto();
        if (produto instanceof ProdutoPreparado) {
            ProdutoPreparado preparado = (ProdutoPreparado) produto;
            return preparado.getTempoEstimadoPreparacao() * item.getQuantidade();
        }
        return 0;
    }

    private double calcularValorTotal(List<Pedido> pedidos) {
        double total = 0;
        for (Pedido pedido : pedidos) {
            total = total + pedido.getTotal();
        }
        return total;
    }

    private Map<String, Integer> calcularMaisVendidos(List<Pedido> pedidos) {
        Map<String, Integer> vendas = new HashMap<>();
        for (Pedido pedido : pedidos) {
            for (ItemPedido item : pedido.getItens()) {
                String nomeProduto = item.getProduto().getNome();
                somarVenda(vendas, nomeProduto, item.getQuantidade());
            }
        }
        return vendas;
    }

    private void somarConsumo(Map<String, Double> consumo, String ingrediente, double quantidade) {
        if (consumo.containsKey(ingrediente)) {
            consumo.put(ingrediente, consumo.get(ingrediente) + quantidade);
        } else {
            consumo.put(ingrediente, quantidade);
        }
    }

    private void somarVenda(Map<String, Integer> vendas, String produto, int quantidade) {
        if (vendas.containsKey(produto)) {
            vendas.put(produto, vendas.get(produto) + quantidade);
        } else {
            vendas.put(produto, quantidade);
        }
    }
}
