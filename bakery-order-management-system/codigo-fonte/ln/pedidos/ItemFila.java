package ln.pedidos;

import dominio.ItemPedido;

public class ItemFila {
    private int numeroPedido;
    private ItemPedido item;

    public ItemFila(int numeroPedido, ItemPedido item) {
        this.numeroPedido = numeroPedido;
        this.item = item;
    }

    public int getNumeroPedido() {
        return numeroPedido;
    }

    public ItemPedido getItem() {
        return item;
    }
}
