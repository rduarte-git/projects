using LockyApp.Data;
using LockyApp.Models;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.AspNetCore.Identity;

namespace LockyApp.Pages.Armarios;

[Authorize(Roles = "Operador,Administrador")]
public class IndexModel : PageModel
{
    private readonly ApplicationDbContext _context;
    
    private readonly UserManager<UtilizadorApp> _userManager;
    public IList<Armario> Armarios { get; set; } = new List<Armario>();

    public IndexModel(ApplicationDbContext context, UserManager<UtilizadorApp> userManager)
    {
        _context = context;
        _userManager = userManager;
    }

    public async Task OnGetAsync()
    {
        if (!User.IsInRole("Administrador"))
        {
            var utilizador = await _userManager.GetUserAsync(User);

            if (utilizador == null || !utilizador.Ativo)
            {
                Armarios = new List<Armario>();
                return;
            }
        }
        
        if (User.IsInRole("Administrador"))
        {
            Armarios = await _context.Armarios.ToListAsync();
        }
        else
        {
            var utilizadorId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            Armarios = await _context.Armarios
                .Where(a => a.IdOperador == utilizadorId)
                .ToListAsync();
        }
    }
}