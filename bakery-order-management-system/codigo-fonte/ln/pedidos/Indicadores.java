package ln.pedidos;

import java.util.Map;

public class Indicadores {
    private int numPedidos;
    private double valorTotal;
    private Map<String, Integer> maisVendidos;

    public Indicadores(int numPedidos, double valorTotal, Map<String, Integer> maisVendidos) {
        this.numPedidos = numPedidos;
        this.valorTotal = valorTotal;
        this.maisVendidos = maisVendidos;
    }

    public int getNumPedidos() {
        return numPedidos;
    }

    public double getValorTotal() {
        return valorTotal;
    }

    public Map<String, Integer> getMaisVendidos() {
        return maisVendidos;
    }
}
