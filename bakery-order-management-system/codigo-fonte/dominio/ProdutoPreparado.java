package dominio;

public class ProdutoPreparado extends Produto {
    private int tempoEstimadoPreparacao;

    public ProdutoPreparado(String codProduto, String nome, double preco, int tempoEstimadoPreparacao) {
        super(codProduto, nome, preco);
        this.tempoEstimadoPreparacao = tempoEstimadoPreparacao;
    }

    public int getTempoEstimadoPreparacao() {
        return tempoEstimadoPreparacao;
    }

    @Override
    public boolean necessitaPreparacao() {
        return true;
    }
}
