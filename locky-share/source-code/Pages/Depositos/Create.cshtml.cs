using LockyApp.Data;
using LockyApp.Enums;
using LockyApp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Microsoft.AspNetCore.Identity;

namespace LockyApp.Pages.Depositos;

public class CreateModel : PageModel
{
    private readonly ApplicationDbContext _context;
    
    private readonly UserManager<UtilizadorApp> _userManager;
    public Cacifo Cacifo { get; set; } = null!;

    public string CodigoGerado { get; set; } = string.Empty;
    
    public bool DepositoCriado { get; set; } 

    public CreateModel(ApplicationDbContext context, UserManager<UtilizadorApp> userManager)
    {
        _context = context;
        _userManager = userManager;
    }
    
    public async Task<IActionResult> OnGetAsync(int? cacifoId)
    {
        if (cacifoId == null)
        {
            return NotFound();
        }

        Cacifo = await _context.Cacifos
            .Include(c => c.Armario)
            .FirstOrDefaultAsync(c => c.Id == cacifoId.Value);

        if (Cacifo == null)
        {
            return NotFound();
        }

        if (Cacifo.Armario == null)
        {
            return NotFound();
        }

        if (!User.IsInRole("Administrador"))
        {
            var utilizadorId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (Cacifo.Armario.IdOperador != utilizadorId)
            {
                return Forbid();
            }
        }

        if (Cacifo.Estado != EstadoCacifo.Livre)
        {
            return BadRequest("O cacifo não está livre.");
        }

        return Page();
    }

    public async Task<IActionResult> OnPostAsync(int? cacifoId)
    {
        if (cacifoId == null)
        {
            return NotFound();
        }

        var cacifo = await _context.Cacifos
            .Include(c => c.Armario)
            .FirstOrDefaultAsync(c => c.Id == cacifoId.Value);

        if (cacifo == null)
        {
            return NotFound();
        }

        if (!User.IsInRole("Administrador"))
        {
            var utilizadorId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (cacifo.Armario.IdOperador != utilizadorId)
            {
                return Forbid();
            }
        }

        if (cacifo.Estado != EstadoCacifo.Livre)
        {
            return BadRequest("O cacifo não está livre.");
        }

        var random = new Random();
        var codigo = random.Next(1000, 10000).ToString();

        var deposito = new Deposito
        {
            CacifoId = cacifo.Id,
            CodigoLevantamento = codigo,
            DataDeposito = DateTime.Now,
            ClienteId = "TEMP",
            Levantado = false
        };

        _context.Depositos.Add(deposito);

        cacifo.Estado = EstadoCacifo.Ocupado;

        await _context.SaveChangesAsync();

        CodigoGerado = codigo;
        DepositoCriado = true;
        Cacifo = cacifo;

        //return RedirectToPage("/Armarios/Detalhes", new { id = cacifo.ArmarioId });
        return Page();

    }
}