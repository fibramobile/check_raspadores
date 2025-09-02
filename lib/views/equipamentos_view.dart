import 'package:flutter/material.dart';
import '../models/equipamento.dart';
/*
class EquipamentosView extends StatefulWidget {
  final String usina;
  final String area;
  final ChecklistController controller;

  EquipamentosView({required this.usina,  required this.area,required this.controller});

  @override
  _EquipamentosViewState createState() => _EquipamentosViewState();
}

class _EquipamentosViewState extends State<EquipamentosView> {
  final Map<String, ExpansionTileController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final equipamentos =
    widget.controller.getEquipamentos(widget.usina, widget.area);
    for (var eq in equipamentos) {
      _controllers[eq.tag] = ExpansionTileController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipamentos =
    widget.controller.getEquipamentos(widget.usina, widget.area);

    return Scaffold(
      appBar: AppBar(title: Text(widget.usina)),
      body: ListView.builder(
        itemCount: equipamentos.length,
        itemBuilder: (context, index) {
          final eq = equipamentos[index];
          final controller = _controllers[eq.tag]!;
/*
          return Card(
            child: ExpansionTile(
              controller: controller,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(eq.tag, style: const TextStyle(fontWeight: FontWeight.bold)),

                  // Indicadores de status dos raspadores
                  Row(
                    children: [
                      Text("R1 "),
                      Icon(Icons.circle, size: 14, color: eq.statusPrimario),
                      const SizedBox(width: 12),
                      Text("R2 "),
                      Icon(Icons.circle, size: 14, color: eq.statusSecundario),
                    ],
                  ),
                ],
              ),
              children: [
                _buildChecklistOption(
                  "Raspador Primário",
                  eq.raspadorPrimarioNA,
                  eq.raspadorPrimarioPressao,
                  0.0, 2.0,
                      (val) => setState(() => eq.raspadorPrimarioNA = val),
                      (v) => setState(() => eq.raspadorPrimarioPressao = v),
                ),
                _buildChecklistOption(
                  "Raspador Secundário",
                  eq.raspadorSecundarioNA,
                  eq.raspadorSecundarioPressao,
                  0.0, 2.0,
                      (val) => setState(() => eq.raspadorSecundarioNA = val),
                      (v) => setState(() => eq.raspadorSecundarioPressao = v),
                ),
                _buildChecklistOption(
                  "Reservatório",
                  eq.reservatorioNA,
                  eq.reservatorioPressao,
                  0.0, 5.0,
                      (val) => setState(() => eq.reservatorioNA = val),
                      (v) => setState(() => eq.reservatorioPressao = v),
                ),
                ElevatedButton(
                  child: const Text("Salvar"),
                  onPressed: () {
                    widget.controller.salvarChecklist(widget.usina, eq);
                    controller.collapse();
                    setState(() {});
                  },
                ),
              ],
            ),
          );
          */
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ExpansionTile(
              controller: controller,
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    eq.tag,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      _buildStatusChip("R1", eq.statusPrimario),
                      const SizedBox(width: 8),
                      _buildStatusChip("R2", eq.statusSecundario),
                    ],
                  ),
                ],
              ),
              children: [
                _buildChecklistOption(
                  "Raspador Primário",
                  eq.raspadorPrimarioNA,
                  eq.raspadorPrimarioPressao,
                  0.0,
                  2.0,
                      (val) => setState(() => eq.raspadorPrimarioNA = val),
                      (v) => setState(() => eq.raspadorPrimarioPressao = v),
                ),
                _buildChecklistOption(
                  "Raspador Secundário",
                  eq.raspadorSecundarioNA,
                  eq.raspadorSecundarioPressao,
                  0.0,
                  2.0,
                      (val) => setState(() => eq.raspadorSecundarioNA = val),
                      (v) => setState(() => eq.raspadorSecundarioPressao = v),
                ),
                _buildChecklistOption(
                  "Reservatório",
                  eq.reservatorioNA,
                  eq.reservatorioPressao,
                  0.0,
                  5.0,
                      (val) => setState(() => eq.reservatorioNA = val),
                      (v) => setState(() => eq.reservatorioPressao = v),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(Icons.save, color: Colors.white, size: 18),
                    label: const Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      widget.controller.salvarChecklist(widget.usina, widget.area, eq);
                      controller.collapse();
                      setState(() {});
                    },

                  ),
                ),
              ],
            ),
          );


        },
      ),
    );
  }


  Widget _buildChecklistOption(
      String label,
      bool isNA,
      double pressao,
      double min,
      double max,
      Function(bool) onNAChanged,
      Function(double) onPressaoChanged) {

    // Define cor com base no valor da pressão
    Color getCorPressao() {
      if (isNA) return Colors.grey;
      if (pressao < min) return Colors.red;       // abaixo do limite
      if (pressao > max) return Colors.yellow;    // acima do limite
      return Colors.blue;                         // dentro do limite
    }

    final cor = getCorPressao();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Row(
          children: [
            Checkbox(
              value: isNA,
              onChanged: (val) => onNAChanged(val ?? false),
            ),
            const Text("N/A"),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: cor,        // 🔹 barra ativa
                  inactiveTrackColor: cor.withOpacity(0.3), // barra inativa
                  thumbColor: cor,              // 🔹 bolinha
                  overlayColor: cor.withOpacity(0.2), // efeito de toque
                ),
                child: Slider(
                  min: min,
                  max: max,
                  divisions: ((max - min) * 10).toInt(),
                  value: pressao.clamp(min, max),
                  onChanged: isNA ? null : (v) => onPressaoChanged(v),
                ),
              ),
            ),
            Text(
              "${pressao.toStringAsFixed(1)} kgf",
              style: TextStyle(color: cor, fontWeight: FontWeight.bold), // 🔹 texto acompanha a cor
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor, width: 1.5),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: cor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.circle, size: 10, color: cor),
        ],
      ),
    );
  }



}
*/
import 'package:flutter/material.dart';
import '../models/equipamento.dart';
import '../services/firebase_checklist_service.dart';

import 'package:flutter/material.dart';
import '../models/equipamento.dart';
import '../services/firebase_checklist_service.dart';
/*
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
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$usina - $area")),
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
            padding: const EdgeInsets.all(8),
            itemCount: equipamentos.length,
            itemBuilder: (context, index) {
              final eq = equipamentos[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tag do equipamento
                      Text(eq.tag,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),

                      // Data/Hora da última atualização
                      Expanded(
                        child: Text(
                          _formatDateTime(eq.updatedAt),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                      // Indicadores R1 e R2
                      Row(
                        children: [
                          Text("R1 "),
                          Icon(Icons.circle,
                              size: 14, color: eq.statusPrimario),
                          const SizedBox(width: 12),
                          Text("R2 "),
                          Icon(Icons.circle,
                              size: 14, color: eq.statusSecundario),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    _buildChecklistOption(
                      context,
                      "Raspador Primário",
                      eq.raspadorPrimarioNA,
                      eq.raspadorPrimarioPressao,
                      0.0,
                      2.0,
                          (val) {
                        eq.raspadorPrimarioNA = val;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                          (v) {
                        eq.raspadorPrimarioPressao = v;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                    ),
                    _buildChecklistOption(
                      context,
                      "Raspador Secundário",
                      eq.raspadorSecundarioNA,
                      eq.raspadorSecundarioPressao,
                      0.0,
                      2.0,
                          (val) {
                        eq.raspadorSecundarioNA = val;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                          (v) {
                        eq.raspadorSecundarioPressao = v;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                    ),
                    _buildChecklistOption(
                      context,
                      "Reservatório",
                      eq.reservatorioNA,
                      eq.reservatorioPressao,
                      1.0,
                      4.0,
                          (val) {
                        eq.reservatorioNA = val;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                          (v) {
                        eq.reservatorioPressao = v;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // fundo cinza claro
      appBar: AppBar(
        title: Text("$usina - $area"),
        backgroundColor: const Color(0xFF007C6C), // verde Vale
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
              final eq = equipamentos[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: ExpansionTile(
                  iconColor: const Color(0xFF007C6C), // verde Vale
                  collapsedIconColor: Colors.grey[600],
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // TAG
                      Text(
                        eq.tag,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF007C6C), // verde Vale
                        ),
                      ),

                      // Data/Hora última atualização
                      Expanded(
                        child: Text(
                          _formatDateTime(eq.updatedAt),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                      // Status R1 e R2
                      Row(
                        children: [
                          const Text("R1 "),
                          Icon(Icons.circle, size: 14, color: eq.statusPrimario),
                          const SizedBox(width: 12),
                          const Text("R2 "),
                          Icon(Icons.circle, size: 14, color: eq.statusSecundario),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    _buildChecklistOption(
                      context,
                      "Raspador Primário",
                      eq.raspadorPrimarioNA,
                      eq.raspadorPrimarioPressao,
                      0.0,
                      2.0,
                          (val) {
                        eq.raspadorPrimarioNA = val;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                          (v) {
                        eq.raspadorPrimarioPressao = v;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                    ),
                    _buildChecklistOption(
                      context,
                      "Raspador Secundário",
                      eq.raspadorSecundarioNA,
                      eq.raspadorSecundarioPressao,
                      0.0,
                      2.0,
                          (val) {
                        eq.raspadorSecundarioNA = val;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                          (v) {
                        eq.raspadorSecundarioPressao = v;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                    ),
                    _buildChecklistOption(
                      context,
                      "Reservatório",
                      eq.reservatorioNA,
                      eq.reservatorioPressao,
                      1.0,
                      4.0,
                          (val) {
                        eq.reservatorioNA = val;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                          (v) {
                        eq.reservatorioPressao = v;
                        eq.updatedAt = DateTime.now();
                        service.salvarChecklist(usina, area, eq);
                      },
                    ),
                  ],





                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChecklistOption(
      BuildContext context,
      String label,
      bool isNA,
      double pressao,
      double min,
      double max,
      Function(bool) onNAChanged,
      Function(double) onPressaoChanged,
      ) {
    Color getCorPressao() {
      if (isNA) return Colors.grey;
      if (pressao < min) return Colors.red;
      if (pressao > max) return Colors.orangeAccent;
      return Colors.green;
    }

    final cor = getCorPressao();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Checkbox(
            value: isNA,
            onChanged: (val) => onNAChanged(val ?? false),
          ),
          const Text("N/A"),
          Expanded(
            child: SliderTheme(
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
                onChanged: isNA ? null : (v) => onPressaoChanged(v),
              ),
            ),
          ),
          Text(
            "${pressao.toStringAsFixed(1)} kgf",
            style: TextStyle(color: cor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
*/

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
                "Última atualização\n ${widget.formatDate(eq.updatedAt)}",
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
                const SizedBox(width: 12),
                const Text("R2 "),
                Icon(Icons.circle, size: 18, color: eq.statusSecundario),
                const SizedBox(width: 12),
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
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007C6C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.save, color: Colors.white, size: 18),
              label: const Text(
                "Salvar",
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          SizedBox(width: 16),
        ],
      ),
    );
  }
/*
///original
  Widget _buildChecklistOption(
      String label,
      bool isNA,
      double pressao,
      double min,
      double max,
      Function(bool) onNAChanged,
      Function(double) onPressaoChanged,
      ) {
    Color getCorPressao() {
      if (isNA) return Colors.grey;
      if (label.contains("Reservatório")) {
        if (pressao < 1.0) return Colors.red;
        if (pressao > 4.0) return Colors.orangeAccent;
        return Colors.green;
      } else {
        if (pressao < 0.5) return Colors.red;
        if (pressao > 1.0) return Colors.orangeAccent;
        return Colors.green;
      }
    }

    final cor = getCorPressao();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Checkbox(
            value: isNA,
            onChanged: (val) => onNAChanged(val ?? false),
          ),
          const Text("N/A"),
          Expanded(
            child: SliderTheme(
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
                onChanged: isNA ? null : (v) => onPressaoChanged(v),
              ),
            ),
          ),
          Text(
            "${pressao.toStringAsFixed(1)} kgf",
            style: TextStyle(color: cor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  */
/*
  ///Graduado
  Widget _buildChecklistOption(
      String label,
      bool isNA,
      double pressao,
      double min,
      double max,
      Function(bool) onNAChanged,
      Function(double) onPressaoChanged,
      ) {
    Color getCorPressao() {
      if (isNA) return Colors.grey;
      if (label.contains("Reservatório")) {
        if (pressao < 1.0) return Colors.red;
        if (pressao > 4.0) return Colors.orangeAccent;
        return Colors.green;
      } else {
        if (pressao < 0.5) return Colors.red;
        if (pressao > 1.0) return Colors.orangeAccent;
        return Colors.green;
      }
    }

    final cor = getCorPressao();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Checkbox(
                value: isNA,
                onChanged: (val) => onNAChanged(val ?? false),
              ),
              const Text("N/A"),
              Expanded(
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: cor,
                        inactiveTrackColor: cor.withOpacity(0.3),
                        thumbColor: cor,
                        overlayColor: cor.withOpacity(0.2),
                        valueIndicatorColor: cor,
                        showValueIndicator: ShowValueIndicator.always,
                        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
                        activeTickMarkColor: cor,
                        inactiveTickMarkColor: cor.withOpacity(0.5),
                      ),
                      child: Slider(
                        min: min,
                        max: max,
                        divisions: ((max - min) * 2).toInt(), // 🔹 0.5 em 0.5
                        value: pressao.clamp(min, max),
                        label: "${pressao.toStringAsFixed(1)} kgf",
                        onChanged: isNA ? null : (v) => onPressaoChanged(v),
                      ),
                    ),
                    // escala com números
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        ((max - min) * 2).toInt() + 1,
                            (i) => Text(
                          (min + i * 0.5).toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  */
  /*

  Widget _buildChecklistOption(
      String label,
      bool isNA,
      double pressao,
      double min,
      double max,
      Function(bool) onNAChanged,
      Function(double) onPressaoChanged,
      ) {
    Color getCorPressao() {
      if (isNA) return Colors.grey;
      if (label.contains("Reservatório")) {
        if (pressao < 1.0) return Colors.red;
        if (pressao > 4.0) return Colors.orangeAccent;
        return Colors.green;
      } else {
        if (pressao < 0.5) return Colors.red;
        if (pressao > 1.0) return Colors.orangeAccent;
        return Colors.green;
      }
    }

    final cor = getCorPressao();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Checkbox(
            value: isNA,
            onChanged: (val) => onNAChanged(val ?? false),
          ),
          const Text("N/A"),

          const SizedBox(width: 12),

          // 🔹 Botão de diminuir
          IconButton(
            icon: const Icon(Icons.remove),
            color: cor,
            onPressed: isNA || pressao <= min
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
            icon: const Icon(Icons.add),
            color: cor,
            onPressed: isNA || pressao >= max
                ? null
                : () => onPressaoChanged(
              (pressao + 0.1).clamp(min, max),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistOption(
      String label,
      bool isNA,
      double pressao,
      double min,
      double max,
      Function(bool) onNAChanged,
      Function(double) onPressaoChanged,
      ) {
    Color getCorPressao() {
      if (isNA) return Colors.grey;
      if (label.contains("Reservatório")) {
        if (pressao < 1.0) return Colors.red;
        if (pressao > 4.0) return Colors.orangeAccent;
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
      child: Row(
        children: [
          // 🔹 Checkbox N/A
          Checkbox(
            value: isNA,
            onChanged: (val) => onNAChanged(val ?? false),
          ),

          // 🔹 Nome do item (Primário, Secundário, Reservatório)
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
            onPressed: isNA || pressao <= min
                ? null
                : () => onPressaoChanged(
              (pressao - 0.1).clamp(min, max),
            ),
          ),

          // 🔹 Valor atual no meio
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
            onPressed: isNA || pressao >= max
                ? null
                : () => onPressaoChanged(
              (pressao + 0.1).clamp(min, max),
            ),
          ),
        ],
      ),
    );
  }
  */

  /*
  Widget _buildChecklistOption(
      String label,
      bool isAtivo, // agora o nome reflete: true = habilitado
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
       // if (pressao > 4.0) return Colors.orangeAccent;
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
      child: Row(
        children: [
          // 🔹 Checkbox agora significa "ativo"
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
    );
  }
*/
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
