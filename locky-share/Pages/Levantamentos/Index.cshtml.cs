using LockyApp.Data;
using LockyApp.Enums;
using LockyApp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;

namespace LockyApp.Pages.Levantamentos;

public class IndexModel : PageModel
{
    private readonly ApplicationDbContext _context;
    
    [BindProperty]
    public string Codigo { get; set; } = string.Empty;

    public string Mensagem { get; set; } = string.Empty;

    public bool LevantamentoConcluido { get; set; }

    public IndexModel(ApplicationDbContext context)
    {
        _context = context;
    }
    
    public async Task OnGetAsync()
    {
    }

    public async Task<IActionResult> OnPostAsync()
    {
        if (string.IsNullOrWhiteSpace(Codigo))
        {
            Mensagem = "Introduza um código.";
            return Page();
        }

        var deposito = await _context.Depositos
            .Include(d => d.Cacifo)
            .ThenInclude(c => c.Armario)
            .FirstOrDefaultAsync(d => d.CodigoLevantamento == Codigo);

        if (deposito == null)
        {
            Mensagem = "Código inválido.";
            return Page();
        }

        if (deposito.Levantado)
        {
            Mensagem = "Este depósito já foi levantado.";
            return Page();
        }

        deposito.Levantado = true;
        deposito.DataLevantamento = DateTime.Now;
        deposito.Cacifo.Estado = EstadoCacifo.Livre;

        var historico = new Historico
        {
            CacifoId = deposito.CacifoId,
            DepositoId = deposito.Id,
            UtilizadorId = null,
            TipoEvento = TipoEvento.Levantamento,
            DataEvento = DateTime.Now,
            Descricao = $"Levantamento efetuado com o código {deposito.CodigoLevantamento}."
        };

        _context.Historicos.Add(historico);

        await _context.SaveChangesAsync();

        Mensagem = $"Levantamento concluído com sucesso. Armário: {deposito.Cacifo.Armario.Nome}, Cacifo: {deposito.Cacifo.Linha},{deposito.Cacifo.Coluna}";
        LevantamentoConcluido = true;

        return Page();
    }
}