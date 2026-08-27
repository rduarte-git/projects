package ln;

import dominio.Produto;
import dominio.Personalizacao;
import dominio.Pedido;
import dominio.Ingrediente;
import dominio.EstadoPedido;
import ln.pedidos.FilaPreparacao;
import ln.pedidos.Indicadores;
import java.time.LocalDate;
import java.util.List;

public interface ICafetariaLN {
    int iniciarPedido();
    List<Produto> listarProdutos();
    List<Personalizacao> consultarPersonalizacoes(String codProduto);
    void adicionarItem(int numPedido, String codProduto, int quantidade, List<String> codigosOpcoes);
    Pedido confirmarPedido(int numPedido);
    void cancelarPedido(int numPedido);
    Pedido consultarPedido(int numPedido);
    List<Pedido> listarPedidosEmCurso();
    List<Pedido> listarPedidosProntos();
    Pedido entregarPedido(int numPedido);
    FilaPreparacao consultarFilaPreparacao();
    EstadoPedido marcarItemPronto(int numPedido, int numeroItem);
    Indicadores consultarIndicadores(LocalDate inicio, LocalDate fim);
    List<Ingrediente> consultarStock();
    List<Ingrediente> consultarStockSinalizado();
}
