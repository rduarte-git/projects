package ln.stock;

import dados.IIngredientesDAO;
import dominio.Ingrediente;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class SSStockFacade implements IGestStock {
    private IIngredientesDAO ingredientesDAO;

    public SSStockFacade(IIngredientesDAO ingredientesDAO) {
        this.ingredientesDAO = ingredientesDAO;
    }

    @Override
    public List<Ingrediente> consultarStock() {
        return ingredientesDAO.obterTodos();
    }

    @Override
    public List<Ingrediente> consultarStockSinalizado() {
        List<Ingrediente> sinalizados = new ArrayList<>();
        for (Ingrediente ingrediente : ingredientesDAO.obterTodos()) {
            if (ingrediente.noNivelMinimo()) {
                sinalizados.add(ingrediente);
            }
        }
        return sinalizados;
    }

    @Override
    public void descontarStock(Map<String, Double> consumo) {
        for (String nome : consumo.keySet()) {
            double quantidade = consumo.get(nome);
            Ingrediente ingrediente = ingredientesDAO.obter(nome);
            if (ingrediente != null) {
                ingrediente.descontar(quantidade);
                ingredientesDAO.guardar(ingrediente);
            }
        }
    }
}
