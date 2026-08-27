package ln;

import dominio.EstadoPedido;
import dominio.Ingrediente;
import dominio.OpcaoPersonalizacao;
import dominio.Pedido;
import dominio.Personalizacao;
import dominio.Produto;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import ln.catalogo.IGestCatalogo;
import ln.pedidos.FilaPreparacao;
import ln.pedidos.IGestPedidos;
import ln.pedidos.Indicadores;
import ln.stock.IGestStock;

public class CafetariaFacade implements ICafetariaLN {
    private IGestPedidos ssPedidos;
    private IGestCatalogo ssCatalogo;
    private IGestStock ssStock;

    public CafetariaFacade(IGestPedidos ssPedidos, IGestCatalogo ssCatalogo, IGestStock ssStock) {
        this.ssPedidos = ssPedidos;
        this.ssCatalogo = ssCatalogo;
        this.ssStock = ssStock;
    }

  

    @Override
    public int iniciarPedido() {
        return ssPedidos.iniciarPedido();
    }

    @Override
    public List<Produto> listarProdutos() {
        return ssCatalogo.listarProdutos();
    }

    @Override
    public List<Personalizacao> consultarPersonalizacoes(String codProduto) {
        return ssCatalogo.consultarPersonalizacoes(codProduto);
    }

    @Override
    public void cancelarPedido(int numPedido) {
        ssPedidos.cancelarPedido(numPedido);
    }

    @Override
    public Pedido consultarPedido(int numPedido) {
        return ssPedidos.consultarPedido(numPedido);
    }

    @Override
    public List<Pedido> listarPedidosEmCurso() {
        return ssPedidos.listarPedidosEmCurso();
    }

    @Override
    public List<Pedido> listarPedidosProntos() {
        return ssPedidos.listarPedidosProntos();
    }

    @Override
    public Pedido entregarPedido(int numPedido) {
        return ssPedidos.entregarPedido(numPedido);
    }

    @Override
    public FilaPreparacao consultarFilaPreparacao() {
        return ssPedidos.consultarFilaPreparacao();
    }

    @Override
    public EstadoPedido marcarItemPronto(int numPedido, int numeroItem) {
        return ssPedidos.marcarItemPronto(numPedido, numeroItem);
    }

    @Override
    public Indicadores consultarIndicadores(LocalDate inicio, LocalDate fim) {
        return ssPedidos.consultarIndicadores(inicio, fim);
    }

    @Override
    public List<Ingrediente> consultarStock() {
        return ssStock.consultarStock();
    }

    @Override
    public List<Ingrediente> consultarStockSinalizado() {
        return ssStock.consultarStockSinalizado();
    }


    @Override
    public void adicionarItem(int numPedido, String codProduto, int quantidade, List<String> codigosOpcoes) {
        Produto produto = ssCatalogo.getProduto(codProduto);
        if (produto != null) {
            List<OpcaoPersonalizacao> opcoes = resolverOpcoes(produto, codigosOpcoes);
            ssPedidos.adicionarItem(numPedido, produto, quantidade, opcoes);
        }
    }

    @Override
    public Pedido confirmarPedido(int numPedido) {
        Map<String, Double> consumo = ssPedidos.calcularConsumoPedido(numPedido);
        ssStock.descontarStock(consumo);
        return ssPedidos.confirmarPedido(numPedido);
    }


    private List<OpcaoPersonalizacao> resolverOpcoes(Produto produto, List<String> codigos) {
        List<OpcaoPersonalizacao> opcoes = new ArrayList<>();
        for (String codigo : codigos) {
            OpcaoPersonalizacao opcao = procurarOpcao(produto, codigo);
            if (opcao != null) {
                opcoes.add(opcao);
            }
        }
        return opcoes;
    }

    private OpcaoPersonalizacao procurarOpcao(Produto produto, String codigo) {
        for (Personalizacao personalizacao : produto.getPersonalizacoes()) {
            for (OpcaoPersonalizacao opcao : personalizacao.getOpcoes()) {
                if (opcao.getCodigo().equals(codigo)) {
                    return opcao;
                }
            }
        }
        return null;
    }
}
