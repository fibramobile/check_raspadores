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
/*
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
*/
  Future<void> salvarChecklist(String usina, String area, Equipamento eq) async {
    final docRef = FirebaseFirestore.instance
        .collection("usinas")
        .doc(usina)
        .collection("areas")
        .doc(area)
        .collection("equipamentos")
        .doc(eq.tag);

    // 🔹 Atualiza documento principal (mantém a lógica atual)
    await docRef.set(eq.toJson(), SetOptions(merge: true));

    // 🔹 Salva no histórico (1 registro por dia)
    final historicoRef = docRef.collection("historico");
    final hoje = DateTime.now();
    final hojeKey = "${hoje.year}-${hoje.month}-${hoje.day}";

    await historicoRef.doc(hojeKey).set({
      "raspadorPrimario": eq.raspadorPrimarioPressao,
      "raspadorSecundario": eq.raspadorSecundarioPressao,
      "raspadorTerceiro": eq.raspadorTerceiroPressao,
      "reservatorio": eq.reservatorioPressao,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    // 🔹 Mantém só os últimos 34 dias
    final snap = await historicoRef.orderBy("updatedAt", descending: true).get();
    if (snap.docs.length > 34) {
      for (var i = 34; i < snap.docs.length; i++) {
        await snap.docs[i].reference.delete();
      }
    }
  }

  Future<Map<String, Map<String, Map<String, List<double>>>>> carregarHistoricoMensal(
      String usina, int mes, int ano) async {
    final result = <String, Map<String, Map<String, List<double>>>>{};
    // Estrutura: {area: {tag: {dia: [r1, r2, r3]}}}

    final areasSnap = await FirebaseFirestore.instance
        .collection("usinas")
        .doc(usina)
        .collection("areas")
        .get();

    for (var areaDoc in areasSnap.docs) {
      final area = areaDoc.id;

      final eqSnap = await areaDoc.reference.collection("equipamentos").get();

      for (var eqDoc in eqSnap.docs) {
        final tag = eqDoc.id;

        final historicoSnap = await eqDoc.reference
            .collection("historico")
            .where("updatedAt", isGreaterThanOrEqualTo: DateTime(ano, mes, 1))
            .where("updatedAt", isLessThan: DateTime(ano, mes + 1, 1))
            .orderBy("updatedAt")
            .get();

        for (var h in historicoSnap.docs) {
          final data = (h["updatedAt"] as Timestamp).toDate();
          final dia = data.day.toString().padLeft(2, "0");

          result.putIfAbsent(area, () => {});
          result[area]!.putIfAbsent(tag, () => {});
          result[area]![tag]![dia] = [
            (h["raspadorPrimario"] ?? 0.0).toDouble(),
            (h["raspadorSecundario"] ?? 0.0).toDouble(),
            (h["raspadorTerceiro"] ?? 0.0).toDouble(),
          ];
        }
      }
    }

    return result;
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


  Future<void> salvarObservacao(
      String usina,
      String area,
      Equipamento eq,
      String texto, {
        String? fotoUrl,
      }) async {
    final user = FirebaseAuth.instance.currentUser;

    final ref = FirebaseFirestore.instance
        .collection("usinas").doc(usina)
        .collection("areas").doc(area)
        .collection("equipamentos").doc(eq.tag)
        .collection("observacoes");

    await ref.add({
      "texto": texto,
      "fotoUrl": fotoUrl,
      "usuarioId": user?.uid,
      "usuarioEmail": user?.email,
      "usuarioNome": user?.displayName,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<Map<String, dynamic>?> getUltimaObservacao(
      String usina,
      String area,
      Equipamento eq,
      ) {
    final ref = FirebaseFirestore.instance
        .collection("usinas").doc(usina)
        .collection("areas").doc(area)
        .collection("equipamentos").doc(eq.tag)
        .collection("observacoes")
        .orderBy("createdAt", descending: true)
        .limit(1);

    return ref.snapshots().map((snap) {
      if (snap.docs.isEmpty) return null;
      return snap.docs.first.data();
    });
  }


}
