import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'areas_view.dart';
import 'equipamentos_view.dart';
/*
class UsinaListView extends StatelessWidget {
  final ChecklistController controller = ChecklistController();

  @override
  Widget build(BuildContext context) {
    final usinas = controller.usinas.keys.toList();

    return Scaffold(
      appBar: AppBar(title: Text("Checklist Raspadores")),
      body: ListView.builder(
        itemCount: usinas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(usinas[index]),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EquipamentosView(
                    usina: usinas[index],
                    controller: controller,
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

*/
/*
class UsinaListView extends StatefulWidget {
  @override
  _UsinaListViewState createState() => _UsinaListViewState();
}

class _UsinaListViewState extends State<UsinaListView> {
  final ChecklistController controller = ChecklistController();
  bool carregado = false;

  @override
  void initState() {
    super.initState();
    controller.carregarDoSharedPreferences().then((_) {
      setState(() => carregado = true);
    });
  }
/*
  @override
  Widget build(BuildContext context) {
    if (!carregado) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final usinas = controller.usinas.keys.toList();
    return Scaffold(
      appBar: AppBar(title: const Text("Checklist Raspadores")),
      body: ListView.builder(
        itemCount: usinas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(usinas[index]),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EquipamentosView(
                    usina: usinas[index],
                    controller: controller,
                  ),
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
    if (!carregado) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final usinas = controller.usinas.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checklist Raspadores"),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView.builder(
        itemCount: usinas.length,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AreasView(
                    usina: usinas[index],
                    controller: controller,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
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
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  child: const Icon(Icons.factory, color: Colors.blueAccent),
                ),
                title: Text(
                  usinas[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 18, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

}

*/
import 'package:flutter/material.dart';
import '../services/firebase_checklist_service.dart';
import 'areas_view.dart';
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
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checklist Raspadores"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blueAccent.withOpacity(0.1),
                        radius: 22,
                        child: const Icon(Icons.factory, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          usina,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
  */

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
            icon: const Icon(Icons.logout, color: Colors.white),
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
      /*
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFDB913), // amarelo Vale
        onPressed: () {
          // futuramente poderia abrir "relatório geral"
        },
        child: const Icon(Icons.picture_as_pdf, color: Colors.white),
      ),
    */
    );
  }

}
