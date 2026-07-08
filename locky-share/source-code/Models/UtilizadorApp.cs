using Microsoft.AspNetCore.Identity;

namespace LockyApp.Models;

public class UtilizadorApp : IdentityUser
{
    public bool Ativo { get; set; } = true;
}