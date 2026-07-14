package ln.catalogo;

import dados.IProdutosDAO;
import dominio.Personalizacao;
import dominio.Produto;
import java.util.ArrayList;
import java.util.List;

public class SSCatalogoFacade implements IGestCatalogo {
    private IProdutosDAO produtosDAO;

    public SSCatalogoFacade(IProdutosDAO produtosDAO) {
        this.produtosDAO = produtosDAO;
    }

    @Override
    public List<Produto> listarProdutos() {
        return produtosDAO.obterTodos();
    }

    @Override
    public Produto getProduto(String codProduto) {
        return produtosDAO.obter(codProduto);
    }

    @Override
    public List<Personalizacao> consultarPersonalizacoes(String codProduto) {
        Produto produto = produtosDAO.obter(codProduto);
        if (produto == null) {
            return new ArrayList<>();
        }
        return produto.getPersonalizacoes();
    }
}
