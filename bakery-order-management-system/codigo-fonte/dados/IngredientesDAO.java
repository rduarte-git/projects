package dados;

import dominio.Ingrediente;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class IngredientesDAO implements IIngredientesDAO {
    private Map<String, Ingrediente> ingredientes;

    public IngredientesDAO() {
        this.ingredientes = new HashMap<>();
    }

    @Override
    public void guardar(Ingrediente ingrediente) {
        ingredientes.put(ingrediente.getNome(), ingrediente);
    }

    @Override
    public Ingrediente obter(String nome) {
        return ingredientes.get(nome);
    }

    @Override
    public List<Ingrediente> obterTodos() {
        return new ArrayList<>(ingredientes.values());
    }

    @Override
    public void remove(String nome) {
        ingredientes.remove(nome);
    }

    @Override
    public boolean existe(String nome) {
        return ingredientes.containsKey(nome);
    }
}
