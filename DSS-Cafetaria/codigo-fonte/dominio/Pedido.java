package dominio;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Pedido {
    private int numero;
    private LocalDateTime dataHora;
    private EstadoPedido estado;
    private List<ItemPedido> itens;

    public Pedido(int numero, LocalDateTime dataHora) {
        this.numero = numero;
        this.dataHora = dataHora;
        this.estado = EstadoPedido.EM_REGISTO;
        this.itens = new ArrayList<>();
    }

    public int getNumero() {
        return numero;
    }

    public LocalDateTime getDataHora() {
        return dataHora;
    }

    public EstadoPedido getEstado() {
        return estado;
    }

    public List<ItemPedido> getItens() {
        return itens;
    }

    public void adicionarItem(Produto produto, int quantidade, List<OpcaoPersonalizacao> opcoes) {
        int numeroItem = itens.size() + 1;
        ItemPedido item = new ItemPedido(numeroItem, produto, quantidade, opcoes);
        itens.add(item);
    }

    public double getTotal() {
        double total = 0;
        for (ItemPedido item : itens) {
            total = total + item.subtotal();
        }
        return total;
    }

    // usado na confirmacao do registo: fica PRONTO se todos os itens ja estao prontos, senao EM_PREPARACAO
    public void confirmar() {
        if (estaPronto()) {
            estado = EstadoPedido.PRONTO;
        } else {
            estado = EstadoPedido.EM_PREPARACAO;
        }
    }

    public EstadoPedido marcarItemPronto(int numeroItem) {
        ItemPedido item = getItem(numeroItem);
        if (item != null) {
            item.marcarPronto();
            atualizarEstadoAposPreparacao();
        }
        return estado;
    }

    public void entregar() {
        estado = EstadoPedido.ENTREGUE;
    }

    public List<ItemPedido> itensPorPreparar() {
        List<ItemPedido> pendentes = new ArrayList<>();
        for (ItemPedido item : itens) {
            if (!item.isPronto()) {
                pendentes.add(item);
            }
        }
        return pendentes;
    }

    // ---- metodos auxiliares (privados) ----

    private ItemPedido getItem(int numeroItem) {
        for (ItemPedido item : itens) {
            if (item.getNumeroItem() == numeroItem) {
                return item;
            }
        }
        return null;
    }

    private boolean estaPronto() {
        for (ItemPedido item : itens) {
            if (!item.isPronto()) {
                return false;
            }
        }
        return true;
    }

    private void atualizarEstadoAposPreparacao() {
        if (estaPronto()) {
            estado = EstadoPedido.PRONTO;
        }
    }
}
