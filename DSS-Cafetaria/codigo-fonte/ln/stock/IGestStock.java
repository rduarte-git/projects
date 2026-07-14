package ln.stock;

import dominio.Ingrediente;
import java.util.List;
import java.util.Map;

public interface IGestStock {
    List<Ingrediente> consultarStock();
    List<Ingrediente> consultarStockSinalizado();
    void descontarStock(Map<String, Double> consumo);
}
