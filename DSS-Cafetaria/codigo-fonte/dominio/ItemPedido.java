package dominio;

import java.util.List;

public class ItemPedido {
    private int numeroItem;
    private Produto produto;
    private int quantidade;
    private boolean pronto;
    private List<OpcaoPersonalizacao> opcoes;

    public ItemPedido(int numeroItem, Produto produto, int quantidade, List<OpcaoPersonalizacao> opcoes) {
        this.numeroItem = numeroItem;
        this.produto = produto;
        this.quantidade = quantidade;
        this.opcoes = opcoes;
        this.pronto = !produto.necessitaPreparacao();
    }

    public int getNumeroItem() {
        return numeroItem;
    }

    public Produto getProduto() {
        return produto;
    }

    public int getQuantidade() {
        return quantidade;
    }

    public boolean isPronto() {
        return pronto;
    }

    public List<OpcaoPersonalizacao> getOpcoes() {
        return opcoes;
    }

    public double subtotal() {
        return produto.getPreco() * quantidade;
    }

    public void marcarPronto() {
        this.pronto = true;
    }
}
