import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/equipamento.dart';

class FirebaseChecklistService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retorna lista de usinas (nomes dos documentos)
  Stream<List<String>> getUsinas() {
    return _db.collection("usinas").snapshots().map((snapshot) {
      print("🔎 Total docs: ${snapshot.docs.length}");
      for (var doc in snapshot.docs) {
        print("📄 Doc ID: ${doc.id}");
      }
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  /// Retorna lista de áreas de uma usina na ordem definida
  Stream<List<String>> getAreas(String usina) {
    const ordemDesejada = [
      "Pátio de Finos",
      "Moagem",
      "Filtragem",
      "Mistura",
      "Pelotamento",
      "Queima",
      "Peneiramento",
      "Pátio de Pelotas",
    ];

    return _db
        .collection("usinas")
        .doc(usina)
        .collection("areas")
        .snapshots()
        .map((snapshot) {
      final areas = snapshot.docs.map((doc) => doc.id).toList();

      // 🔹 Ordena pela ordem desejada
      areas.sort((a, b) {
        final indexA = ordemDesejada.indexOf(a);
        final indexB = ordemDesejada.indexOf(b);

        // Se não encontrar, joga pro final
        if (indexA == -1 && indexB == -1) return a.compareTo(b);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;

        return indexA.compareTo(indexB);
      });

      return areas;
    });
  }

  /// Retorna equipamentos em tempo real
  Stream<List<Equipamento>> getEquipamentos(String usina, String area) {
    return _db
        .collection("usinas")
        .doc(usina)
        .collection("areas")
        .doc(area)
        .collection("equipamentos")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Equipamento.fromJson({...data, "tag": doc.id});
      }).toList();
    });
  }

  /// Salva ou atualiza um checklist
  Future<void> salvarChecklist(String usina, String area, Equipamento eq) async {
    final user = FirebaseAuth.instance.currentUser;
    await _db
        .collection("usinas")
        .doc(usina)
        .collection("areas")
        .doc(area)
        .collection("equipamentos")
        .doc(eq.tag)
        .set({
      ...eq.toJson(),
      "updatedBy": user?.email ?? user?.uid ?? "desconhecido",
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Busca TODOS os equipamentos de uma usina (todas as áreas)
  Stream<List<Equipamento>> getEquipamentosPorUsina(String usina) async* {
    final areasSnap =
    await _db.collection("usinas").doc(usina).collection("areas").get();

    // cria streams de cada área
    final streams = areasSnap.docs.map((areaDoc) {
      return _db
          .collection("usinas")
          .doc(usina)
          .collection("areas")
          .doc(areaDoc.id)
          .collection("equipamentos")
          .snapshots()
          .map((snap) => snap.docs.map((doc) {
        final data = doc.data();
        return Equipamento.fromJson({...data, "tag": doc.id});
      }).toList());
    }).toList();

    // junta tudo em um único stream
    yield* StreamZip(streams).map((listas) => listas.expand((l) => l).toList());
  }

  /// Busca TODOS os equipamentos de uma usina (snapshot único, sem tempo real)
  /*
  Future<List<Equipamento>> getEquipamentosPorUsinaOnce(String usina) async {
    final areasSnap =
    await _db.collection("usinas").doc(usina).collection("areas").get();

    List<Equipamento> todos = [];

    for (var area in areasSnap.docs) {
      final eqSnap = await _db
          .collection("usinas")
          .doc(usina)
          .collection("areas")
          .doc(area.id)
          .collection("equipamentos")
          .get();

      todos.addAll(eqSnap.docs.map((doc) {
        final data = doc.data();
        return Equipamento.fromJson({...data, "tag": doc.id});
      }));
    }

    return todos;
  }
*/
  Future<List<Equipamento>> getEquipamentosPorUsinaOnce(String usina) async {
    final usinaRef = FirebaseFirestore.instance.collection("usinas").doc(usina);
    final areasSnapshot = await usinaRef.collection("areas").get();

    List<Equipamento> equipamentos = [];

    for (var areaDoc in areasSnapshot.docs) {
      final equipamentosSnapshot = await areaDoc.reference.collection("equipamentos").get();
      for (var eq in equipamentosSnapshot.docs) {
        final equipamento = Equipamento.fromJson(eq.data());
        equipamentos.add(
          Equipamento(
            tag: equipamento.tag,
            area: areaDoc.id, // 👈 usa o nome do doc da área como área
            raspadorPrimarioNA: equipamento.raspadorPrimarioNA,
            raspadorPrimarioPressao: equipamento.raspadorPrimarioPressao,
            raspadorSecundarioNA: equipamento.raspadorSecundarioNA,
            raspadorSecundarioPressao: equipamento.raspadorSecundarioPressao,
            raspadorTerceiroNA: equipamento.raspadorTerceiroNA,
            raspadorTerceiroPressao: equipamento.raspadorTerceiroPressao,
            reservatorioNA: equipamento.reservatorioNA,
            reservatorioPressao: equipamento.reservatorioPressao,
            updatedAt: equipamento.updatedAt,
          ),
        );
      }
    }
    return equipamentos;
  }


}
