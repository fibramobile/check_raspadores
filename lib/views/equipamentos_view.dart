import 'package:flutter/material.dart';
import '../models/equipamento.dart';
import '../services/firebase_checklist_service.dart';


class EquipamentosView extends StatelessWidget {
  final String usina;
  final String area;
  final FirebaseChecklistService service;

  EquipamentosView({
    required this.usina,
    required this.area,
    required this.service,
  });

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return "--/-- --:--";
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("$usina - $area"),
        backgroundColor: const Color(0xFF007C6C),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: StreamBuilder<List<Equipamento>>(
        stream: service.getEquipamentos(usina, area),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final equipamentos = snapshot.data!;
          if (equipamentos.isEmpty) {
            return const Center(child: Text("Nenhum equipamento cadastrado."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: equipamentos.length,
            itemBuilder: (context, index) {
              return EquipamentoTile(
                equipamento: equipamentos[index],
                usina: usina,
                area: area,
                service: service,
                formatDate: _formatDateTime,
              );
            },
          );
        },
      ),
    );
  }
}

class EquipamentoTile extends StatefulWidget {
  final Equipamento equipamento;
  final String usina;
  final String area;
  final FirebaseChecklistService service;
  final String Function(DateTime?) formatDate;


  const EquipamentoTile({
    super.key,
    required this.equipamento,
    required this.usina,
    required this.area,
    required this.service,
    required this.formatDate,
  });

  @override
  State<EquipamentoTile> createState() => _EquipamentoTileState();
}

class _EquipamentoTileState extends State<EquipamentoTile> {
  late bool primarioNA;
  late double primarioPressao;
  late bool secundarioNA;
  late double secundarioPressao;
  late bool terceiroNA;
  late double terceiroPressao;
  late bool reservatorioNA;
  late double reservatorioPressao;
  late final ExpansionTileController _expansionController;


  @override
  void initState() {
    super.initState();
    primarioNA = widget.equipamento.raspadorPrimarioNA;
    primarioPressao = widget.equipamento.raspadorPrimarioPressao;
    secundarioNA = widget.equipamento.raspadorSecundarioNA;
    secundarioPressao = widget.equipamento.raspadorSecundarioPressao;
    terceiroNA = widget.equipamento.raspadorTerceiroNA;
    terceiroPressao = widget.equipamento.raspadorTerceiroPressao;
    reservatorioNA = widget.equipamento.reservatorioNA;
    reservatorioPressao = widget.equipamento.reservatorioPressao;
    _expansionController = ExpansionTileController();
  }

  @override
  Widget build(BuildContext context) {
    final eq = widget.equipamento;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ExpansionTile(
        controller: _expansionController,
        iconColor: const Color(0xFF007C6C),
        collapsedIconColor: Colors.grey[600],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              eq.tag,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF007C6C),
              ),
            ),
            Expanded(
              child: Text(
                "Atualizado\n ${widget.formatDate(eq.updatedAt)}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic, // 👈 deixa diferenciado
                ),
              ),
            ),

            Row(
              children: [
                const Text("R1 "),
                Icon(Icons.circle, size: 18, color: eq.statusPrimario),
                const SizedBox(width: 8),
                const Text("R2 "),
                Icon(Icons.circle, size: 18, color: eq.statusSecundario),
                const SizedBox(width: 8),
                const Text("R3 "),
                Icon(Icons.circle, size: 18, color: eq.statusTerceiro),
              ],
            ),
          ],
        ),
        children: [
          _buildChecklistOption(
            "Raspador Primário",
            primarioNA,
            primarioPressao,
            0.0,
            2.0,
                (val) => setState(() => primarioNA = val),
                (v) => setState(() => primarioPressao = v),
          ),
          _buildChecklistOption(
            "Raspador Secundário",
            secundarioNA,
            secundarioPressao,
            0.0,
            2.0,
                (val) => setState(() => secundarioNA = val),
                (v) => setState(() => secundarioPressao = v),
          ),
          _buildChecklistOption(
            "Raspador Terceiro",
            terceiroNA,
            terceiroPressao,
            0.0,
            2.0,
                (val) => setState(() => terceiroNA = val),
                (v) => setState(() => terceiroPressao = v),
          ),
          _buildChecklistOption(
            "Reservatório",
            true,
            reservatorioPressao,
            0.0,
            6.0,
                //(val) => setState(() => reservatorioNA = val),
                (val) => setState(() => reservatorioNA = val),
                (v) => setState(() => reservatorioPressao = v),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12), // espaço extra no rodapé
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3A712),//const Color(0xFF007C6C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                icon: const Icon(Icons.save, color: Colors.white, size: 18),
                label: const Text(
                  "Salvar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  eq.raspadorPrimarioNA = primarioNA;
                  eq.raspadorPrimarioPressao = primarioPressao;
                  eq.raspadorSecundarioNA = secundarioNA;
                  eq.raspadorSecundarioPressao = secundarioPressao;
                  eq.raspadorTerceiroNA = terceiroNA;
                  eq.raspadorTerceiroPressao = terceiroPressao;
                  eq.reservatorioNA = reservatorioNA;
                  eq.reservatorioPressao = reservatorioPressao;
                  eq.updatedAt = DateTime.now();

                  widget.service.salvarChecklist(widget.usina, widget.area, eq);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Checklist salvo!")),
                  );
                  // 🔹 Fecha o expansivo após salvar
                  _expansionController.collapse();
                },
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildChecklistOption(
      String label,
      bool isAtivo, // true = habilitado
      double pressao,
      double min,
      double max,
      Function(bool) onAtivoChanged,
      Function(double) onPressaoChanged,
      ) {
    Color getCorPressao() {
      if (!isAtivo) return Colors.grey; // se desmarcado, fica cinza
      if (label.contains("Reservatório")) {
        if (pressao < 1.0) return Colors.red;
      //  if (pressao > 4.0) return Colors.orangeAccent;
        return Colors.green;
      } else {
        if (pressao < 0.5) return Colors.red;
        if (pressao > 1.0) return Colors.orangeAccent;
        return Colors.green;
      }
    }

    final cor = getCorPressao();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 🔹 Checkbox habilita/desabilita
              if (!label.contains("Reservatório"))
              Checkbox(
                value: isAtivo,
                onChanged: (val) => onAtivoChanged(val ?? true),
              ),

              // 🔹 Nome do item
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              // 🔹 Botão de diminuir
              IconButton(
                icon: const Icon(Icons.remove_circle),
                color: cor,
                onPressed: !isAtivo || pressao <= min
                    ? null
                    : () => onPressaoChanged(
                  (pressao - 0.1).clamp(min, max),
                ),
              ),

              // 🔹 Valor atual
              Text(
                "${pressao.toStringAsFixed(1)} kgf",
                style: TextStyle(
                  color: cor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              // 🔹 Botão de aumentar
              IconButton(
                icon: const Icon(Icons.add_circle),
                color: cor,
                onPressed: !isAtivo || pressao >= max
                    ? null
                    : () => onPressaoChanged(
                  (pressao + 0.1).clamp(min, max),
                ),
              ),
            ],
          ),

          // 🔹 Slider opcional abaixo
          if (isAtivo)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: cor,
                inactiveTrackColor: cor.withOpacity(0.3),
                thumbColor: cor,
                overlayColor: cor.withOpacity(0.2),
              ),
              child: Slider(
                min: min,
                max: max,
                divisions: ((max - min) * 10).toInt(),
                value: pressao.clamp(min, max),
                onChanged: (v) => onPressaoChanged(v),
              ),
            ),
        ],
      ),
    );
  }
}
