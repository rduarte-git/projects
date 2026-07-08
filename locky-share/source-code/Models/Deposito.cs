namespace LockyApp.Models;

public class Deposito
{
    public int Id { get; set; }
    
    public int CacifoId { get; set; }
    
    public string CodigoLevantamento { get; set; } = string.Empty;
    
    public DateTime DataDeposito { get; set; }
    
    public DateTime? DataLevantamento { get; set; }
    
    public string ClienteId { get; set; } = string.Empty;
    
    public bool Levantado { get; set; }

    public Cacifo Cacifo { get; set; } = null!;

}