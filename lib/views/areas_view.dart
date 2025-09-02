import 'package:flutter/material.dart';
import '../services/firebase_checklist_service.dart';
import 'equipamentos_view.dart';
import 'relatorio_view.dart'; // 🔹 importa a tela de relatório

class AreasView extends StatelessWidget {
  final String usina;
  final FirebaseChecklistService service;

  AreasView({required this.usina, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // fundo claro
      appBar: AppBar(
        title: Text("Áreas - $usina"),
        backgroundColor: const Color(0xFF007C6C), // verde Vale
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            tooltip: "Relatório de críticos",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RelatorioView(usina: usina),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<String>>(
        stream: service.getAreas(usina),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final areas = snapshot.data!;
          return ListView.builder(
            itemCount: areas.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final area = areas[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EquipamentosView(
                        usina: usina,
                        area: area,
                        service: service,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF007C6C).withOpacity(0.15),
                        radius: 22,
                        child: const Icon(Icons.apartment, color: Color(0xFF007C6C)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          area,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[600]),
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
