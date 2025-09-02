import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'areas_view.dart';
import '../services/firebase_checklist_service.dart';
import 'login_view.dart';

class UsinaListView extends StatelessWidget {
  final FirebaseChecklistService service = FirebaseChecklistService();

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginView()),
          (route) => false, // remove todas as telas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // fundo bem claro
      appBar: AppBar(
        title: const Text("Checklist Raspadores"),
        backgroundColor: const Color(0xFF007C6C), // verde Vale
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: const Color(0xFFF3A712)),// Colors.white),
            tooltip: "Sair",
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<List<String>>(
        stream: service.getUsinas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final usinas = snapshot.data!;
          return ListView.builder(
            itemCount: usinas.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final usina = usinas[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AreasView(usina: usina, service: service),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
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
                        backgroundColor: const Color(0xFF007C6C).withOpacity(0.15), // verde claro
                        radius: 22,
                        child: const Icon(Icons.factory, color: Color(0xFF007C6C)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          usina,
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
