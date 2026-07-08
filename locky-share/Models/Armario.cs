namespace LockyApp.Models;

public class Armario
{
    public int Id { get; set; }

    public string Nome { get; set; } = string.Empty;

    public string Localizacao { get; set; } = string.Empty;
    
    public int Altura { get; set; }
    
    public int Largura { get; set; }

    public string IdOperador { get; set; } = string.Empty;
    
    public bool Activo { get; set; }
    
    public List<Cacifo> Cacifos { get; set; } = new();

}