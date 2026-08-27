package ui;

import dados.IngredientesDAO;
import dados.PedidosDAO;
import dados.ProdutosDAO;
import dominio.ComposicaoProduto;
import dominio.Ingrediente;
import dominio.OpcaoPersonalizacao;
import dominio.Personalizacao;
import dominio.Produto;
import dominio.ProdutoPreparado;
import dominio.ProdutoPronto;
import ln.CafetariaFacade;
import ln.ICafetariaLN;
import ln.catalogo.SSCatalogoFacade;
import ln.pedidos.SSPedidosFacade;
import ln.stock.SSStockFacade;

public class Main {

    public static void main(String[] args) {
        ProdutosDAO produtosDAO = new ProdutosDAO();
        IngredientesDAO ingredientesDAO = new IngredientesDAO();
        PedidosDAO pedidosDAO = new PedidosDAO();

        popularIngredientes(ingredientesDAO);
        popularCatalogo(produtosDAO, ingredientesDAO);

        SSPedidosFacade ssPedidos = new SSPedidosFacade(pedidosDAO);
        SSCatalogoFacade ssCatalogo = new SSCatalogoFacade(produtosDAO);
        SSStockFacade ssStock = new SSStockFacade(ingredientesDAO);

        ICafetariaLN cafetaria = new CafetariaFacade(ssPedidos, ssCatalogo, ssStock);

        CafetariaUI ui = new CafetariaUI(cafetaria);
        ui.run();
    }

    private static void popularIngredientes(IngredientesDAO dao) {
        dao.guardar(new Ingrediente("Cafe", 5, 3, "g"));
        dao.guardar(new Ingrediente("Pao", 5, 3, "un"));
        dao.guardar(new Ingrediente("Manteiga", 5, 3, "g"));
        dao.guardar(new Ingrediente("Agua", 5, 3, "un"));
    }

    private static void popularCatalogo(ProdutosDAO dao, IngredientesDAO ingDao) {
        dao.guardar(criarPao(ingDao));
        dao.guardar(criarAgua(ingDao));
        dao.guardar(criarCafe(ingDao));
        dao.guardar(criarTorrada(ingDao));
    }

    private static Produto criarPao(IngredientesDAO ingDao) {
        ProdutoPronto pao = new ProdutoPronto("P1", "Pao", 0.60);
        pao.adicionarComposicao(new ComposicaoProduto(ingDao.obter("Pao"), 1));
        return pao;
    }

    private static Produto criarAgua(IngredientesDAO ingDao) {
        ProdutoPronto agua = new ProdutoPronto("A1", "Garrafa de agua", 0.80);
        agua.adicionarComposicao(new ComposicaoProduto(ingDao.obter("Agua"), 1));
        return agua;
    }

    private static Produto criarCafe(IngredientesDAO ingDao) {
        ProdutoPreparado cafe = new ProdutoPreparado("C1", "Cafe", 0.70, 2);
        cafe.adicionarComposicao(new ComposicaoProduto(ingDao.obter("Cafe"), 1));
        Personalizacao intensidade = new Personalizacao("Intensidade");
        intensidade.adicionarOpcao(new OpcaoPersonalizacao("normal", "Normal"));
        intensidade.adicionarOpcao(new OpcaoPersonalizacao("cheio", "Cheio"));
        intensidade.adicionarOpcao(new OpcaoPersonalizacao("curto", "Curto"));
        cafe.adicionarPersonalizacao(intensidade);
        return cafe;
    }

    private static Produto criarTorrada(IngredientesDAO ingDao) {
        ProdutoPreparado torrada = new ProdutoPreparado("T1", "Torrada", 1.20, 4);
        torrada.adicionarComposicao(new ComposicaoProduto(ingDao.obter("Pao"), 1));
        torrada.adicionarComposicao(new ComposicaoProduto(ingDao.obter("Manteiga"), 1));
        Personalizacao tipoPao = new Personalizacao("Tipo de pao");
        tipoPao.adicionarOpcao(new OpcaoPersonalizacao("branco", "Pao branco"));
        tipoPao.adicionarOpcao(new OpcaoPersonalizacao("integral", "Pao integral"));
        torrada.adicionarPersonalizacao(tipoPao);
        return torrada;
    }
}
