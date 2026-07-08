using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using LockyApp.Data;
using LockyApp.Models;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ??
                       throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlite(connectionString));
builder.Services.AddDatabaseDeveloperPageExceptionFilter();

builder.Services.AddDefaultIdentity<UtilizadorApp>(options => options.SignIn.RequireConfirmedAccount = true)
    .AddRoles<IdentityRole>().AddEntityFrameworkStores<ApplicationDbContext>();
builder.Services.AddRazorPages();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseMigrationsEndPoint();
}
else
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();
app.MapRazorPages()
    .WithStaticAssets();

// Verificação de roles

using (var scope = app.Services.CreateScope())
{
    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
    var userManager = scope.ServiceProvider.GetRequiredService<UserManager<UtilizadorApp>>();

    string[] roles = { "Cliente", "Operador", "Administrador" };

    foreach (var role in roles)
    {
        if (!await roleManager.RoleExistsAsync(role))
        {
            await roleManager.CreateAsync(new IdentityRole(role));
        }
    }

    var emailAdmin = "admin@admin.com"; // pass: Admin123#
    var utilizador = await userManager.FindByEmailAsync(emailAdmin);

    if (utilizador != null && !await userManager.IsInRoleAsync(utilizador, "Administrador"))
    {
        await userManager.AddToRoleAsync(utilizador, "Administrador");
    }
    
    var emailOperador = "operador@operador.com"; // pass: Operador123#
    var operador = await userManager.FindByEmailAsync(emailOperador);

    if (operador != null && !await userManager.IsInRoleAsync(operador, "Operador"))
    {
        await userManager.AddToRoleAsync(operador, "Operador");
    }
}

app.Run();