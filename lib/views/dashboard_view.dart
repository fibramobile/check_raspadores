import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardView extends StatelessWidget {
  final String usina;
  const DashboardView({required this.usina, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text("Dashboard - $usina", style: TextStyle(color: Colors.white
        ),),
        backgroundColor: const Color(0xFF007C6C),
        elevation: 4,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collectionGroup("equipamentos").snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhum dado encontrado"));
          }

          final all = snap.data!.docs;

          bool belongsToUsina(DocumentReference ref) {
            final seg = ref.path.split('/');
            return seg.length >= 2 && seg[0] == 'usinas' && seg[1] == usina;
          }

          final docs = all.where((d) {
            if (!belongsToUsina(d.reference)) return false;
            final data = d.data() as Map<String, dynamic>;
            final tagField = (data['tag'] ?? '').toString().trim();
            return tagField.isNotEmpty || d.id.trim().isNotEmpty;
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text("Nenhum equipamento nesta usina"));
          }

          double asDouble(dynamic v) => v is num ? v.toDouble() : 0.0;

          int low = 0, ok = 0, high = 0, totalAtivos = 0;
          void acumula(bool ativo, double p) {
            if (!ativo) return;
            totalAtivos++;
            if (p < 0.5) {
              low++;
            } else if (p <= 1.0) {
              ok++;
            } else {
              high++;
            }
          }

          for (final d in docs) {
            final data = d.data() as Map<String, dynamic>;

            final r1NA = (data['raspadorPrimarioNA'] ?? false) as bool;
            final r2NA = (data['raspadorSecundarioNA'] ?? false) as bool;
            final r3NA = (data['raspadorTerceiroNA'] ?? false) as bool;

            acumula(r1NA, asDouble(data['raspadorPrimarioPressao']));
            acumula(r2NA, asDouble(data['raspadorSecundarioPressao']));
            acumula(r3NA, asDouble(data['raspadorTerceiroPressao']));
          }

          final denom = totalAtivos == 0 ? 1 : totalAtivos;
          final percBaixa = (low / denom * 100).toStringAsFixed(1);
          final percOk = (ok / denom * 100).toStringAsFixed(1);
          final percAlta = (high / denom * 100).toStringAsFixed(1);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🔹 Cards Resumo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildResumo("Baixa", "$percBaixa%", Colors.red, Icons.trending_down)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildResumo("OK", "$percOk%", Colors.green, Icons.check_circle)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildResumo("Alta", "$percAlta%", Colors.orange, Icons.trending_up)),
                  ],
                ),
                const SizedBox(height: 24),

                // 🔹 Gráfico Pizza
                const Text(
                  "Distribuição dos Raspadores",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: double.parse(percBaixa),
                          color: Colors.red,
                          title: "$percBaixa%",
                          radius: 60,
                          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: double.parse(percOk),
                          color: Colors.green,
                          title: "$percOk%",
                          radius: 60,
                          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: double.parse(percAlta),
                          color: Colors.orange,
                          title: "$percAlta%",
                          radius: 60,
                          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Equipamentos Ativos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 12),

                // 🔹 Grid de equipamentos responsiva
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280, // largura máxima de cada card
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (_, i) {
                    final d = docs[i];
                    final data = d.data() as Map<String, dynamic>;

                    final r1NA = (data['raspadorPrimarioNA'] ?? false) as bool;
                    final r2NA = (data['raspadorSecundarioNA'] ?? false) as bool;
                    final r3NA = (data['raspadorTerceiroNA'] ?? false) as bool;

                    final r1 = asDouble(data['raspadorPrimarioPressao']);
                    final r2 = asDouble(data['raspadorSecundarioPressao']);
                    final r3 = asDouble(data['raspadorTerceiroPressao']);

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.id,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF007C6C),
                                )),
                            const Divider(),
                            if (r1NA) _buildStatus("R1", r1),
                            if (r2NA) _buildStatus("R2", r2),
                            if (r3NA) _buildStatus("R3", r3),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Card resumo (KPI)
  Widget _buildResumo(String titulo, String valor, Color cor, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cor.withOpacity(0.15), cor.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: cor, size: 32),
          const SizedBox(height: 8),
          Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cor)),
          const SizedBox(height: 4),
          Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cor)),
        ],
      ),
    );
  }

  /// Status de pressão colorido
  Widget _buildStatus(String label, double p) {
    Color cor;
    String status;
    if (p < 0.5) {
      cor = Colors.red;
      status = "Baixa";
    } else if (p <= 1.0) {
      cor = Colors.green;
      status = "OK";
    } else {
      cor = Colors.orange;
      status = "Alta";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: cor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              "$label: $status (${p.toStringAsFixed(2)} kgf)",
              style: TextStyle(color: cor, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
