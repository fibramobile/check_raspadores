import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/equipamento.dart';
import '../services/firebase_checklist_service.dart';
import 'package:pdf/widgets.dart' as pw;

class RelatorioView extends StatelessWidget {
  final String usina;
  final FirebaseChecklistService service = FirebaseChecklistService();

  RelatorioView({required this.usina});

  Future<void> _gerarPdf(List<Equipamento> equipamentos, String usina) async {
    final pdf = pw.Document();

    pw.Widget _statusDot(Color cor) {
      PdfColor pdfColor;
      if (cor == Colors.red) pdfColor = PdfColors.red;
      else if (cor == Colors.green) pdfColor = PdfColors.green;
      else if (cor == Colors.orange || cor == Colors.orangeAccent) pdfColor = PdfColors.orange;
      else if (cor == Colors.grey) pdfColor = PdfColors.grey;
      else pdfColor = PdfColors.black;

      return pw.Container(
        width: 12,
        height: 12,
        decoration: pw.BoxDecoration(
          color: pdfColor,
          shape: pw.BoxShape.circle,
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            "Relatório de Equipamentos - $usina",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ["Local/Área", "TAG", "Última Atualização", "R1", "R2", "R3"],
            data: equipamentos.map((eq) {
              return [
                eq.area, // 👈 nova coluna
                eq.tag,
                eq.updatedAt != null
                    ? "${eq.updatedAt!.day.toString().padLeft(2, '0')}/"
                    "${eq.updatedAt!.month.toString().padLeft(2, '0')}/"
                    "${eq.updatedAt!.year} "
                    "${eq.updatedAt!.hour.toString().padLeft(2, '0')}:"
                    "${eq.updatedAt!.minute.toString().padLeft(2, '0')}"
                    : "-",
                _statusDot(eq.statusPrimario),
                _statusDot(eq.statusSecundario),
                _statusDot(eq.statusTerceiro),
              ];
            }).toList(),
            cellAlignment: pw.Alignment.center,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 10),
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
          )

        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: "relatorio_$usina.pdf");
  }

  Future<void> gerarRelatorioMensalPDF(
      BuildContext context, String usina, int mes, int ano) async {
    final dados = await FirebaseChecklistService().carregarHistoricoMensal(usina, mes, ano);
    final pdf = pw.Document();

    final diasNoMes = List.generate(
      DateUtils.getDaysInMonth(ano, mes),
          (i) => (i + 1).toString().padLeft(2, "0"),
    );

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            "Relatório de Pressões - $usina (${mes.toString().padLeft(2, "0")}/$ano)",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
            columnWidths: {
              0: const pw.FixedColumnWidth(80),
              1: const pw.FixedColumnWidth(60),
            },
            children: [
              // Cabeçalho
              pw.TableRow(
                children: [
                  pw.Center(child: pw.Text("Área", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Center(child: pw.Text("TAG", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ...diasNoMes.map((d) =>
                      pw.Center(child: pw.Text(d, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)))),
                ],
              ),

              // Linhas de dados
              for (var area in dados.keys)
                for (var tag in dados[area]!.keys)
                  pw.TableRow(
                    children: [
                      pw.Text(area),
                      pw.Text(tag),
                      ...diasNoMes.map((d) {
                        final valores = dados[area]![tag]![d];
                        if (valores == null) return pw.Text("-");
                        return pw.Text(
                          "R1:${valores[0].toStringAsFixed(1)} "
                              "R2:${valores[1].toStringAsFixed(1)} "
                              "R3:${valores[2].toStringAsFixed(1)}",
                          style: const pw.TextStyle(fontSize: 8),
                        );
                      }),
                    ],
                  ),
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "relatorio_${usina}_${mes}_${ano}.pdf",
    );
  }


  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "-";
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // fundo cinza claro
      appBar: AppBar(
        title: Text("Relatório - $usina"),
        backgroundColor: const Color(0xFF007C6C), // verde Vale
        foregroundColor: Colors.white,
        actions: [
          /*
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
            tooltip: "Exportar PDF Mensal",
            onPressed: () async {
              final now = DateTime.now();
              await gerarRelatorioMensalPDF(context, usina, now.month, now.year);
            },
          ),
          */
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: "Exportar PDF",
            onPressed: () async {
              final equipamentos = await service.getEquipamentosPorUsinaOnce(usina);

              final criticos = equipamentos.where((e) =>
              e.statusPrimario == Colors.red || e.statusSecundario == Colors.red
                  || e.statusTerceiro == Colors.red
              ).toList();

              if (criticos.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Nenhum equipamento crítico."),
                    backgroundColor: Color(0xFF007C6C), // verde Vale
                  ),
                );
                return;
              }

              await _gerarPdf(criticos.isNotEmpty ? criticos : equipamentos, usina);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Equipamento>>(
        stream: service.getEquipamentosPorUsina(usina),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final equipamentosCriticos = snapshot.data!.where((eq) =>
          eq.statusPrimario == Colors.red || eq.statusSecundario == Colors.red
              || eq.statusTerceiro == Colors.red
          ).toList();

          if (equipamentosCriticos.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum equipamento em status crítico.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: equipamentosCriticos.length,
            itemBuilder: (context, index) {
              final eq = equipamentosCriticos[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    eq.tag,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007C6C), // verde Vale
                    ),
                  ),
                  subtitle: Text(
                    "Última atualização: ${_formatDateTime(eq.updatedAt)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("R1 ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.circle, size: 18, color: eq.statusPrimario),
                      const SizedBox(width: 12),
                      const Text("R2 ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.circle, size: 18, color: eq.statusSecundario),
                      const SizedBox(width: 12),
                      const Text("R3 ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.circle, size: 18, color: eq.statusTerceiro),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
