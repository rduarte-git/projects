using LockyApp.Enums;

namespace LockyApp.Models;

public class Cacifo
{
    public int Id { get; set; }
    
    public int ArmarioId { get; set; }
    
    public int Linha { get; set; }
    
    public int Coluna { get; set; }
    
    public EstadoCacifo Estado { get; set; }

    public Armario Armario { get; set; } = null!;
    
    public List<Deposito> Depositos { get; set; } = new();
    
    public List<Historico> Historicos { get; set; } = new();
}