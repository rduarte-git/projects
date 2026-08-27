package dados;

import dominio.Pedido;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class PedidosDAO implements IPedidosDAO {
    private Map<Integer, Pedido> pedidos;

    public PedidosDAO() {
        this.pedidos = new LinkedHashMap<>();
    }

    @Override
    public void guardar(Pedido pedido) {
        pedidos.put(pedido.getNumero(), pedido);
    }

    @Override
    public Pedido obter(int numero) {
        return pedidos.get(numero);
    }

    @Override
    public List<Pedido> obterTodos() {
        return new ArrayList<>(pedidos.values());
    }

    @Override
    public void remove(int numero) {
        pedidos.remove(numero);
    }

    @Override
    public boolean existe(int numero) {
        return pedidos.containsKey(numero);
    }

    @Override
    public List<Pedido> obterPorPeriodo(LocalDate inicio, LocalDate fim) {
        List<Pedido> resultado = new ArrayList<>();
        for (Pedido pedido : pedidos.values()) {
            LocalDate data = pedido.getDataHora().toLocalDate();
            if (!data.isBefore(inicio) && !data.isAfter(fim)) {
                resultado.add(pedido);
            }
        }
        return resultado;
    }
}
