package dominio;

import java.util.ArrayList;
import java.util.List;

public class Personalizacao {
    private String nome;
    private List<OpcaoPersonalizacao> opcoes;

    public Personalizacao(String nome) {
        this.nome = nome;
        this.opcoes = new ArrayList<>();
    }

    public String getNome() {
        return nome;
    }

    public List<OpcaoPersonalizacao> getOpcoes() {
        return opcoes;
    }

    public void adicionarOpcao(OpcaoPersonalizacao opcao) {
        opcoes.add(opcao);
    }
}
