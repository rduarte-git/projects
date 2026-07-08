using LockyApp.Enums;

namespace LockyApp.Models;

public class Historico
{
    public int Id { get; set; }
    
    public int? CacifoId { get; set; }
    
    public int? DepositoId { get; set; }
    
    public string? UtilizadorId { get; set; }
    
    public TipoEvento TipoEvento { get; set; }
    
    public DateTime DataEvento { get; set; }
    
    public string Descricao { get; set; } = string.Empty;

    public Cacifo? Cacifo { get; set; }
    
    public Deposito? Deposito { get; set; }
    
}