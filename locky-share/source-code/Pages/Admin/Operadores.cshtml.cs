using LockyApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace LockyApp.Pages.Admin;

[Authorize(Roles = "Administrador")]
public class OperadoresModel : PageModel
{
    private readonly UserManager<UtilizadorApp> _userManager;

    public OperadoresModel(UserManager<UtilizadorApp> userManager)
    {
        _userManager = userManager;
    }

    public List<UtilizadorApp> Operadores { get; set; } = new();

    public async Task OnGetAsync()
    {
        var utilizadores = _userManager.Users.ToList();

        foreach (var utilizador in utilizadores)
        {
            if (await _userManager.IsInRoleAsync(utilizador, "Operador"))
            {
                Operadores.Add(utilizador);
            }
        }
    }

    public async Task<IActionResult> OnPostToggleAtivoAsync(string id)
    {
        var utilizador = await _userManager.FindByIdAsync(id);

        if (utilizador == null)
        {
            return NotFound();
        }

        if (!await _userManager.IsInRoleAsync(utilizador, "Operador"))
        {
            return Forbid();
        }

        utilizador.Ativo = !utilizador.Ativo;
        await _userManager.UpdateAsync(utilizador);

        return RedirectToPage();
    }
}