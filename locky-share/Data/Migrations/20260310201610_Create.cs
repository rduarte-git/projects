using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LockyApp.Data.Migrations
{
    /// <inheritdoc />
    public partial class Create : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Armarios",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Nome = table.Column<string>(type: "TEXT", nullable: false),
                    Localizacao = table.Column<string>(type: "TEXT", nullable: false),
                    Altura = table.Column<int>(type: "INTEGER", nullable: false),
                    Largura = table.Column<int>(type: "INTEGER", nullable: false),
                    IdOperador = table.Column<string>(type: "TEXT", nullable: false),
                    Activo = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Armarios", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Cacifos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    ArmarioId = table.Column<int>(type: "INTEGER", nullable: false),
                    Linha = table.Column<int>(type: "INTEGER", nullable: false),
                    Coluna = table.Column<int>(type: "INTEGER", nullable: false),
                    Estado = table.Column<int>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cacifos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Cacifos_Armarios_ArmarioId",
                        column: x => x.ArmarioId,
                        principalTable: "Armarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Depositos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    CacifoId = table.Column<int>(type: "INTEGER", nullable: false),
                    CodigoLevantamento = table.Column<string>(type: "TEXT", nullable: false),
                    DataDeposito = table.Column<DateTime>(type: "TEXT", nullable: false),
                    DataLevantamento = table.Column<DateTime>(type: "TEXT", nullable: true),
                    ClienteId = table.Column<string>(type: "TEXT", nullable: false),
                    Levantado = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Depositos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Depositos_Cacifos_CacifoId",
                        column: x => x.CacifoId,
                        principalTable: "Cacifos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Historicos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    CacifoId = table.Column<int>(type: "INTEGER", nullable: true),
                    DepositoId = table.Column<int>(type: "INTEGER", nullable: true),
                    UtilizadorId = table.Column<string>(type: "TEXT", nullable: true),
                    TipoEvento = table.Column<int>(type: "INTEGER", nullable: false),
                    DataEvento = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Descricao = table.Column<string>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Historicos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Historicos_Cacifos_CacifoId",
                        column: x => x.CacifoId,
                        principalTable: "Cacifos",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Historicos_Depositos_DepositoId",
                        column: x => x.DepositoId,
                        principalTable: "Depositos",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Cacifos_ArmarioId",
                table: "Cacifos",
                column: "ArmarioId");

            migrationBuilder.CreateIndex(
                name: "IX_Depositos_CacifoId",
                table: "Depositos",
                column: "CacifoId");

            migrationBuilder.CreateIndex(
                name: "IX_Historicos_CacifoId",
                table: "Historicos",
                column: "CacifoId");

            migrationBuilder.CreateIndex(
                name: "IX_Historicos_DepositoId",
                table: "Historicos",
                column: "DepositoId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Historicos");

            migrationBuilder.DropTable(
                name: "Depositos");

            migrationBuilder.DropTable(
                name: "Cacifos");

            migrationBuilder.DropTable(
                name: "Armarios");
        }
    }
}
