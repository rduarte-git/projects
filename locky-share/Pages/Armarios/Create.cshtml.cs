using LockyApp.Data;
using LockyApp.Enums;
using LockyApp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.AspNetCore.Identity;

namespace LockyApp.Pages.Armarios;

[Authorize(Roles = "Operador,Administrador")]
public class CreateModel : PageModel
{
    private readonly ApplicationDbContext _context;
    
    private readonly UserManager<UtilizadorApp> _userManager;
    
    [BindProperty]
    public Armario Armario { get; set; } = new();

    public CreateModel(ApplicationDbContext context, UserManager<UtilizadorApp> userManager)
    {
        _context = context;
        _userManager = userManager;
    }

    public async Task<IActionResult> OnGetAsync()
    {
        if (!User.IsInRole("Administrador"))
        {
            var utilizador = await _userManager.GetUserAsync(User);

            if (utilizador == null || !utilizador.Ativo)
            {
                return Forbid();
            }
        }

        return Page();
    }
    
    public async Task<IActionResult> OnPostAsync()
    {
        if (!User.IsInRole("Administrador"))
        {
            var utilizador = await _userManager.GetUserAsync(User);

            if (utilizador == null || !utilizador.Ativo)
            {
                return Forbid();
            }
        }
        
        if (!ModelState.IsValid)
        {
            return Page();
        }

        Armario.IdOperador = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;
        
        _context.Armarios.Add(Armario);
        await _context.SaveChangesAsync();

        for (int linha = 1; linha <= Armario.Altura; linha++)
        {
            for (int coluna = 1; coluna <= Armario.Largura; coluna++)
            {
                var cacifo = new Cacifo
                {
                    ArmarioId = Armario.Id,
                    Linha = linha,
                    Coluna = coluna,
                    Estado = EstadoCacifo.Livre
                };

                _context.Cacifos.Add(cacifo);
            }
        }

        await _context.SaveChangesAsync();

        return RedirectToPage("./Index");
    }
}