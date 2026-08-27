package dominio;

import java.util.ArrayList;
import java.util.List;

public abstract class Produto {
    private String codProduto;
    private String nome;
    private double preco;
    private List<Personalizacao> personalizacoes;
    private List<ComposicaoProduto> composicao;

    public Produto(String codProduto, String nome, double preco) {
        this.codProduto = codProduto;
        this.nome = nome;
        this.preco = preco;
        this.personalizacoes = new ArrayList<>();
        this.composicao = new ArrayList<>();
    }

    public String getCodProduto() {
        return codProduto;
    }

    public String getNome() {
        return nome;
    }

    public double getPreco() {
        return preco;
    }

    public List<Personalizacao> getPersonalizacoes() {
        return personalizacoes;
    }

    public List<ComposicaoProduto> getComposicao() {
        return composicao;
    }

    public void adicionarPersonalizacao(Personalizacao personalizacao) {
        personalizacoes.add(personalizacao);
    }

    public void adicionarComposicao(ComposicaoProduto linha) {
        composicao.add(linha);
    }

    public abstract boolean necessitaPreparacao();
}
