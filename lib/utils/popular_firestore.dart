import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePopulator {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
/*
  Future<void> popular() async {
    final String jsonString = await rootBundle.loadString('assets/data/usinas.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);

    for (final usina in data.keys) {
      final areas = data[usina] as Map<String, dynamic>;

      for (final area in areas.keys) {
        final equipamentos = areas[area] as List;

        for (final eq in equipamentos) {
          await _db
              .collection("usinas")
              .doc(usina)
              .collection("areas")
              .doc(area)
              .collection("equipamentos")
              .doc(eq["tag"])
              .set({
            "raspadorPrimarioNA": false,
            "raspadorPrimarioPressao": 0.0,
            "raspadorSecundarioNA": false,
            "raspadorSecundarioPressao": 0.0,
            "reservatorioNA": false,
            "reservatorioPressao": 0.0,
          }, SetOptions(merge: true));
        }
      }
    }

    print("✅ Dados iniciais populados no Firestore!");
  }
*/
  Future<void> popular() async {
    final String jsonString = await rootBundle.loadString('assets/data/usinas.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);

    for (final usina in data.keys) {
      final areas = data[usina] as Map<String, dynamic>;

      for (final area in areas.keys) {
        final equipamentos = areas[area] as List;

        // 🔹 Garante que o documento da área existe com pelo menos 1 campo
        await _db
            .collection("usinas")
            .doc(usina)
            .collection("areas")
            .doc(area)
            .set({
          "nome": area,
          "createdAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        for (final eq in equipamentos) {
          await _db
              .collection("usinas")
              .doc(usina)
              .collection("areas")
              .doc(area)
              .collection("equipamentos")
              .doc(eq["tag"])
              .set({
            "raspadorPrimarioNA": false,
            "raspadorPrimarioPressao": 0.0,
            "raspadorSecundarioNA": false,
            "raspadorSecundarioPressao": 0.0,
            "reservatorioNA": false,
            "reservatorioPressao": 0.0,
          }, SetOptions(merge: true));
        }
      }
    }

    print("✅ Dados iniciais populados no Firestore!");
  }

}
