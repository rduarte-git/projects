using LockyApp.Data;
using LockyApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace LockyApp.Pages.Depositos;

[Authorize]
public class IndexModel : PageModel
{
    private readonly ApplicationDbContext _context;

    public IndexModel(ApplicationDbContext context)
    {
        _context = context;
    }

    public IList<Deposito> Depositos { get; set; } = new List<Deposito>();

    public async Task OnGetAsync()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

        Depositos = await _context.Depositos
            .Where(d => d.ClienteId == userId)
            .Include(d => d.Cacifo)
            .ThenInclude(c => c.Armario)
            .OrderByDescending(d => d.DataDeposito)
            .ToListAsync();
    }
}