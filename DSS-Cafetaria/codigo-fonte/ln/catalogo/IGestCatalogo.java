package ln.catalogo;

import dominio.Produto;
import dominio.Personalizacao;
import java.util.List;

public interface IGestCatalogo {
    List<Produto> listarProdutos();
    Produto getProduto(String codProduto);
    List<Personalizacao> consultarPersonalizacoes(String codProduto);
}
