package dados;

import dominio.Pedido;
import java.time.LocalDate;
import java.util.List;

public interface IPedidosDAO {
    void guardar(Pedido pedido);
    Pedido obter(int numero);
    List<Pedido> obterTodos();
    void remove(int numero);
    boolean existe(int numero);
    List<Pedido> obterPorPeriodo(LocalDate inicio, LocalDate fim);
}
