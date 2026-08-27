package dados;

import dominio.Produto;
import java.util.List;

public interface IProdutosDAO {
    void guardar(Produto produto);
    Produto obter(String codProduto);
    List<Produto> obterTodos();
    void remove(String codProduto);
    boolean existe(String codProduto);
}
