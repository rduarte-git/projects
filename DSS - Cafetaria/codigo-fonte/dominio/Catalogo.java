package dominio;

import java.util.ArrayList;
import java.util.List;

public class Catalogo {
    private List<Produto> produtos;

    public Catalogo() {
        this.produtos = new ArrayList<>();
    }

    public void adicionarProduto(Produto produto) {
        produtos.add(produto);
    }

    public List<Produto> listarProdutos() {
        return produtos;
    }

    public Produto getProduto(String codProduto) {
        for (Produto p : produtos) {
            if (p.getCodProduto().equals(codProduto)) {
                return p;
            }
        }
        return null;
    }
}
