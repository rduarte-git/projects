using System.Security.Claims;
using System.Text.Json;
using LockyApp.Data;
using LockyApp.Enums;
using LockyApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace LockyApp.Pages.Armarios;

[Authorize(Roles = "Operador,Administrador")]
public class ImportarModel : PageModel
{
    private readonly ApplicationDbContext _context;
    private readonly UserManager<UtilizadorApp> _userManager;

    public ImportarModel(ApplicationDbContext context, UserManager<UtilizadorApp> userManager)
    {
        _context = context;
        _userManager = userManager;
    }

    [BindProperty]
    public IFormFile? FicheiroJson { get; set; }

    public string Mensagem { get; set; } = string.Empty;

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

        if (FicheiroJson == null || FicheiroJson.Length == 0)
        {
            Mensagem = "Selecione um ficheiro JSON.";
            return Page();
        }

        ImportarArmarioJson? dados;

        using (var stream = FicheiroJson.OpenReadStream())
        {
            dados = await JsonSerializer.DeserializeAsync<ImportarArmarioJson>(
                stream,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }

        if (dados == null)
        {
            Mensagem = "Não foi possível ler o ficheiro JSON.";
            return Page();
        }

        var armario = new Armario
        {
            Nome = dados.Nome,
            Localizacao = dados.Localizacao,
            Altura = dados.Altura,
            Largura = dados.Largura,
            IdOperador = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty,
            Activo = true
        };

        _context.Armarios.Add(armario);
        await _context.SaveChangesAsync();

        for (int linha = 1; linha <= armario.Altura; linha++)
        {
            for (int coluna = 1; coluna <= armario.Largura; coluna++)
            {
                var cacifo = new Cacifo
                {
                    ArmarioId = armario.Id,
                    Linha = linha,
                    Coluna = coluna,
                    Estado = EstadoCacifo.Livre
                };

                _context.Cacifos.Add(cacifo);
            }
        }

        await _context.SaveChangesAsync();

        return RedirectToPage("./Detalhes", new { id = armario.Id });
    }
}