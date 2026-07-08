using LockyApp.Data;
using LockyApp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.AspNetCore.Identity;

namespace LockyApp.Pages.Armarios;

[Authorize(Roles = "Operador,Administrador")]
public class Detalhes : PageModel
{
    private readonly ApplicationDbContext _context;

    private readonly UserManager<UtilizadorApp> _userManager;
    
    public Detalhes(ApplicationDbContext context, UserManager<UtilizadorApp> userManager)
    {
        _context = context;
        _userManager = userManager;
    }

    public Armario Armario { get; set; } = null!;

    public async Task<IActionResult> OnGetAsync(int? id)
    {
        if (!User.IsInRole("Administrador"))
        {
            var utilizadorId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (Armario.IdOperador != utilizadorId)
            {
                return Forbid();
            }
        }
        
        if (id == null)
        {
            return NotFound();
        }

        Armario = await _context.Armarios
            .Include(a => a.Cacifos)
            .FirstOrDefaultAsync(a => a.Id == id.Value);

        if (Armario == null)
        {
            return NotFound();
        }

        return Page();
    }
}