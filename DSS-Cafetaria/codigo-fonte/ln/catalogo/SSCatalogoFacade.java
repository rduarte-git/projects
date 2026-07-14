package ln.catalogo;

import dados.IProdutosDAO;
import dominio.Produto;
import dominio.Personalizacao;
import java.util.ArrayList;
import java.util.List;

public class SSCatalogoFacade implements IGestCatalogo {
    private IProdutosDAO produtosDAO;

    // recebe o DAO no construtor (depende da interface, nao da implementacao)
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
            // produto nao existe: devolve lista vazia
            return new ArrayList<>();
        }
        return produto.getPersonalizacoes();
    }
}
