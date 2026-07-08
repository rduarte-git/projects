using LockyApp.Data;
using LockyApp.Models;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace LockyApp.Pages.Historicos;

[Authorize(Roles = "Operador,Administrador")]
public class IndexModel : PageModel
{
    private readonly ApplicationDbContext _context;
    
    private readonly UserManager<UtilizadorApp> _userManager;
    public IList<Historico> Historicos { get; set; } = new List<Historico>();

    public IndexModel(ApplicationDbContext context, UserManager<UtilizadorApp> userManager)
    {
        _context = context;
        _userManager = userManager;
    }

    public async Task<IActionResult> OnGetAsync()
    {
        var query = _context.Historicos
            .Include(h => h.Cacifo)
            .ThenInclude(c => c.Armario)
            .Include(h => h.Deposito)
            .OrderByDescending(h => h.DataEvento)
            .AsQueryable();

        if (!User.IsInRole("Administrador"))
        {
            var utilizadorId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            query = query.Where(h => h.Cacifo != null && h.Cacifo.Armario.IdOperador == utilizadorId)
                .OrderByDescending(h => h.DataEvento);
        }

        Historicos = await query.ToListAsync();

        return Page();
    }
}