package dominio;

public class ComposicaoProduto {
    private Ingrediente ingrediente;
    private double quantidade;

    public ComposicaoProduto(Ingrediente ingrediente, double quantidade) {
        this.ingrediente = ingrediente;
        this.quantidade = quantidade;
    }

    public Ingrediente getIngrediente() {
        return ingrediente;
    }

    public double getQuantidade() {
        return quantidade;
    }
}
