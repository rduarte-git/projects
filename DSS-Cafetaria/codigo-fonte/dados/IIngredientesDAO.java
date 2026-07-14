package dados;

import dominio.Ingrediente;
import java.util.List;

public interface IIngredientesDAO {
    void guardar(Ingrediente ingrediente);
    Ingrediente obter(String nome);
    List<Ingrediente> obterTodos();
    void remove(String nome);
    boolean existe(String nome);
}
