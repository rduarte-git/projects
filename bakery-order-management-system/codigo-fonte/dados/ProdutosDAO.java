package dados;

import dominio.Produto;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProdutosDAO implements IProdutosDAO {
    private Map<String, Produto> produtos;

    public ProdutosDAO() {
        this.produtos = new HashMap<>();
    }

    @Override
    public void guardar(Produto produto) {
        produtos.put(produto.getCodProduto(), produto);
    }

    @Override
    public Produto obter(String codProduto) {
        return produtos.get(codProduto);
    }

    @Override
    public List<Produto> obterTodos() {
        return new ArrayList<>(produtos.values());
    }

    @Override
    public void remove(String codProduto) {
        produtos.remove(codProduto);
    }

    @Override
    public boolean existe(String codProduto) {
        return produtos.containsKey(codProduto);
    }
}
