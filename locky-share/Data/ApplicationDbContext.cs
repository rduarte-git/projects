using LockyApp.Models;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace LockyApp.Data;

public class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : IdentityDbContext<UtilizadorApp>(options)
{
    public DbSet<Armario> Armarios { get; set; }
    public DbSet<Cacifo> Cacifos { get; set; }
    public DbSet<Deposito> Depositos { get; set; }
    public DbSet<Historico> Historicos { get; set; }
}