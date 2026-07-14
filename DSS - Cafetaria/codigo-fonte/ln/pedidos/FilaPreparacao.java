package ln.pedidos;

import java.util.List;

public class FilaPreparacao {
    private List<ItemFila> itens;
    private int estimativa;

    public FilaPreparacao(List<ItemFila> itens, int estimativa) {
        this.itens = itens;
        this.estimativa = estimativa;
    }

    public List<ItemFila> getItens() {
        return itens;
    }

    public int getEstimativa() {
        return estimativa;
    }
}
