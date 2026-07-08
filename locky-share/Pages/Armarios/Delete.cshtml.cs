using System.Security.Claims;
using LockyApp.Data;
using LockyApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;

namespace LockyApp.Pages.Armarios;

[Authorize(Roles = "Operador,Administrador")]
public class DeleteModel : PageModel
{
    private readonly ApplicationDbContext _context;
    
    private readonly UserManager<UtilizadorApp> _userManager;
    
    [BindProperty]
    public Armario Armario { get; set; } = null!;

    public DeleteModel(ApplicationDbContext context, UserManager<UtilizadorApp> userManager)
    {
        _context = context;
        _userManager = userManager;
    }
    
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
            .FirstOrDefaultAsync(a => a.Id == id.Value);

        if (Armario == null)
        {
            return NotFound();
        }

        return Page();
    }

    public async Task<IActionResult> OnPostAsync(int? id)
    {
        if (!User.IsInRole("Administrador"))
        {
            var utilizador = await _userManager.GetUserAsync(User);

            if (utilizador == null || !utilizador.Ativo)
            {
                return Forbid();
            }
        }
        if (id == null)
        {
            return NotFound();
        }

        var armario = await _context.Armarios
            .Include(a => a.Cacifos)
            .FirstOrDefaultAsync(a => a.Id == id.Value);

        if (armario == null)
        {
            return NotFound();
        }

        if (!User.IsInRole("Administrador"))
        {
            var utilizadorId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (armario.IdOperador != utilizadorId)
            {
                return Forbid();
            }
        }

        _context.Cacifos.RemoveRange(armario.Cacifos);
        _context.Armarios.Remove(armario);

        await _context.SaveChangesAsync();

        return RedirectToPage("./Index");
    }
}