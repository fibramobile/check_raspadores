import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import '../models/equipamento.dart';
import '../services/firebase_checklist_service.dart';

class EquipamentosView extends StatelessWidget {
  final String usina;
  final String area;
  final FirebaseChecklistService service;

  const EquipamentosView({
    super.key,
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

  final TextEditingController _obsController = TextEditingController();
  String? fotoUrl;

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

    _obsController.text = widget.equipamento.observacao ?? "";
    fotoUrl = widget.equipamento.fotoUrl;
    _expansionController = ExpansionTileController();
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      print("📸 Iniciando seleção de imagem...");
      final picker = ImagePicker();
      XFile? picked;

      if (kIsWeb) {
        picked = await picker.pickImage(source: ImageSource.gallery);
        print("🌐 (Web) Imagem selecionada: ${picked?.name}");
      } else {
        picked = await picker.pickImage(source: ImageSource.camera);
        print("📱 (Mobile) Imagem capturada: ${picked?.path}");
      }

      if (picked == null) {
        print("⚠️ Nenhuma imagem selecionada.");
        return;
      }

      final storage = FirebaseStorage.instanceFor(bucket: "gs://check-raspadores");
      final fileName = "${widget.equipamento.tag}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = storage.ref().child("checklist_fotos/$fileName");

      final metadata = SettableMetadata(contentType: "image/jpeg");

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        print("🌐 (Web) Tamanho da imagem: ${bytes.lengthInBytes / 1024} KB");

        if (bytes.lengthInBytes > 2 * 1024 * 1024) {
          print("❌ Imagem muito grande (>2MB). Abortando upload.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Imagem muito grande, selecione outra.")),
          );
          return;
        }

        print("⬆️ (Web) Iniciando upload para Firebase Storage...");
        await ref.putData(bytes, metadata);
        print("✅ (Web) Upload concluído!");
      } else {
        final file = File(picked.path);
        print("📱 (Mobile) Tamanho original: ${await file.length() / 1024} KB");

        try {
          final compressed = await FlutterImageCompress.compressWithFile(
            file.absolute.path,
            minWidth: 1024,
            minHeight: 1024,
            quality: 70,
          );

          if (compressed != null) {
            print("📱 (Mobile) Tamanho comprimido: ${compressed.length / 1024} KB");
            print("⬆️ (Mobile) Iniciando upload (comprimido)...");
            await ref.putData(compressed, metadata);
            print("✅ (Mobile) Upload concluído!");
          } else {
            print("⚠️ Compressão falhou, usando arquivo original.");
            await ref.putFile(file, metadata);
            print("✅ (Mobile) Upload concluído com arquivo original.");
          }
        } catch (e) {
          print("❌ Erro ao comprimir: $e");
          await ref.putFile(file, metadata);
          print("✅ (Mobile) Upload concluído (sem compressão).");
        }
      }

      // ✅ Agora pega a URL válida
      final url = await ref.getDownloadURL();
      print("✅ URL obtida: $url");

      setState(() {
        fotoUrl = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Imagem enviada com sucesso!")),
      );
    } catch (e, s) {
      print("❌ Erro no processo de upload: $e");
      print(s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar imagem: $e")),
      );
    }
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
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Row(
              children: [
                const Text("R1"),
                Icon(Icons.circle, size: 18, color: eq.statusPrimario),
                const SizedBox(width: 8),
                const Text("R2"),
                Icon(Icons.circle, size: 18, color: eq.statusSecundario),
                const SizedBox(width: 8),
                const Text("R3"),
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
                (val) => setState(() => reservatorioNA = val),
                (v) => setState(() => reservatorioPressao = v),
          ),

          Row(
            children: [
              StreamBuilder<Map<String, dynamic>?>(
                stream: widget.service.getUltimaObservacao(widget.usina, widget.area, eq),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox();
                  final obs = snap.data!;
                  final texto = obs['texto'] ?? '';
                  final usuario = obs['usuarioNome'] ?? obs['usuarioEmail'] ?? obs['usuarioId'] ?? 'Desconhecido';
                  final createdAt = (obs['createdAt'] as Timestamp?)?.toDate();
                  final dataFormatada = createdAt != null
                      ? DateFormat("dd/MM/yy HH:mm").format(createdAt)
                      : "--";

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Última observação:",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          texto,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "por $usuario em $dataFormatada",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),





          // 🔹 Observações
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _obsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Observações",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

// 🔹 Botão Salvar
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3A712),
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
                onPressed: () async {
                  // 🔹 Atualiza pressões normalmente
                  eq.raspadorPrimarioNA = primarioNA;
                  eq.raspadorPrimarioPressao = primarioPressao;
                  eq.raspadorSecundarioNA = secundarioNA;
                  eq.raspadorSecundarioPressao = secundarioPressao;
                  eq.raspadorTerceiroNA = terceiroNA;
                  eq.raspadorTerceiroPressao = terceiroPressao;
                  eq.reservatorioNA = reservatorioNA;
                  eq.reservatorioPressao = reservatorioPressao;
                  eq.updatedAt = DateTime.now();

                  // 🔹 Salva checklist básico
                  widget.service.salvarChecklist(widget.usina, widget.area, eq);

                  // 🔹 Salva observação em subcoleção (se tiver texto ou foto)
                  if (_obsController.text.trim().isNotEmpty || fotoUrl != null) {
                    await widget.service.salvarObservacao(
                      widget.usina,
                      widget.area,
                      eq,
                      _obsController.text.trim(),
                      fotoUrl: fotoUrl,   // agora bate com o parâmetro nomeado
                    );
                    _obsController.clear();
                    setState(() => fotoUrl = null);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Checklist salvo!")),
                  );
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
      bool isAtivo,
      double pressao,
      double min,
      double max,
      Function(bool) onAtivoChanged,
      Function(double) onPressaoChanged,
      ) {
    Color getCorPressao() {
      if (!isAtivo) return Colors.grey;
      if (label.contains("Reservatório")) {
        if (pressao < 1.0) return Colors.red;
        return Colors.green;
      } else {
        if (pressao < 0.5) return Colors.red;
        if (pressao > 1.0) return Colors.orangeAccent;
        return Colors.green;
      }
    }

    final cor = getCorPressao();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      padding: const EdgeInsets.all(4),
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
              if (!label.contains("Reservatório"))
                Checkbox(
                  value: isAtivo,
                  onChanged: (val) => onAtivoChanged(val ?? true),
                ),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                color: cor,
                onPressed: !isAtivo || pressao <= min
                    ? null
                    : () => onPressaoChanged((pressao - 0.1).clamp(min, max)),
              ),
              Text(
                "${pressao.toStringAsFixed(1)} kgf",
                style: TextStyle(
                  color: cor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                color: cor,
                onPressed: !isAtivo || pressao >= max
                    ? null
                    : () => onPressaoChanged((pressao + 0.1).clamp(min, max)),
              ),
            ],
          ),
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
