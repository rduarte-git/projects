package dominio;

public class Ingrediente {
    private String nome;
    private double quantidadeEmStock;
    private double nivelMinimo;
    private String unidade;

    public Ingrediente(String nome, double quantidadeEmStock, double nivelMinimo, String unidade) {
        this.nome = nome;
        this.quantidadeEmStock = quantidadeEmStock;
        this.nivelMinimo = nivelMinimo;
        this.unidade = unidade;
    }

    public String getNome() {
        return nome;
    }

    public double getQuantidadeEmStock() {
        return quantidadeEmStock;
    }

    public double getNivelMinimo() {
        return nivelMinimo;
    }

    public String getUnidade() {
        return unidade;
    }

    public void descontar(double quantidade) {
        this.quantidadeEmStock = this.quantidadeEmStock - quantidade;
    }

    public boolean noNivelMinimo() {
        return this.quantidadeEmStock <= this.nivelMinimo;
    }
}
