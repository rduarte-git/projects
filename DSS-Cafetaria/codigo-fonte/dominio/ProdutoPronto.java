package dominio;

public class ProdutoPronto extends Produto {

    public ProdutoPronto(String codProduto, String nome, double preco) {
        super(codProduto, nome, preco);
    }

    @Override
    public boolean necessitaPreparacao() {
        return false;
    }
}
