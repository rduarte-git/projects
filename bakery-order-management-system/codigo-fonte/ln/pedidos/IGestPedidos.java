package ln.pedidos;

import dominio.Pedido;
import dominio.Produto;
import dominio.OpcaoPersonalizacao;
import dominio.EstadoPedido;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface IGestPedidos {
    int iniciarPedido();
    void adicionarItem(int numPedido, Produto produto, int quantidade, List<OpcaoPersonalizacao> opcoes);
    Pedido confirmarPedido(int numPedido);
    void cancelarPedido(int numPedido);
    Pedido consultarPedido(int numPedido);
    List<Pedido> listarPedidosEmCurso();
    List<Pedido> listarPedidosProntos();
    Pedido entregarPedido(int numPedido);
    FilaPreparacao consultarFilaPreparacao();
    EstadoPedido marcarItemPronto(int numPedido, int numeroItem);
    Indicadores consultarIndicadores(LocalDate inicio, LocalDate fim);
    Map<String, Double> calcularConsumoPedido(int numPedido);
}
