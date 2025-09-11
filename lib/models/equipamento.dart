import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Equipamento {
  final String tag;
  final String area;

  String? observacao;
  String? fotoUrl;


  bool raspadorPrimarioNA;
  double raspadorPrimarioPressao;

  bool raspadorSecundarioNA;
  double raspadorSecundarioPressao;

  bool raspadorTerceiroNA;
  double raspadorTerceiroPressao;

  bool reservatorioNA;
  double reservatorioPressao;

  DateTime? updatedAt; // 👈 novo campo

  Equipamento({
    required this.tag,
    required this.area,
    this.raspadorPrimarioNA = true,
    this.raspadorPrimarioPressao = 0.0,
    this.raspadorSecundarioNA = true,
    this.raspadorSecundarioPressao = 0.0,
    this.raspadorTerceiroNA = true,
    this.raspadorTerceiroPressao = 0.0,
    this.reservatorioNA = true,
    this.reservatorioPressao = 0.0,
    this.updatedAt,
  });

  // --- Status
  Color get statusPrimario {
    if (!raspadorPrimarioNA) return Colors.grey;
    if (raspadorPrimarioPressao < 0.5) return Colors.red;
    if (raspadorPrimarioPressao > 1.0) return Colors.orangeAccent;
    return Colors.green;
  }

  Color get statusSecundario {
    if (!raspadorSecundarioNA) return Colors.grey;
    if (raspadorSecundarioPressao < 0.5) return Colors.red;
    if (raspadorSecundarioPressao > 1.0) return Colors.orangeAccent;
    return Colors.green;
  }

  Color get statusTerceiro {
    if (!raspadorTerceiroNA) return Colors.grey;
    if (raspadorTerceiroPressao < 0.5) return Colors.red;
    if (raspadorTerceiroPressao > 1.0) return Colors.orangeAccent;
    return Colors.green;
  }

  Color get statusReservatorio {
    if (reservatorioNA) return Colors.grey;
    if (reservatorioPressao < 1.0) return Colors.red;
   // if (reservatorioPressao > 4.0) return Colors.orangeAccent;
    return Colors.green;
  }

  bool get statusOk =>
      (statusPrimario == Colors.green || raspadorPrimarioNA) &&
          (statusSecundario == Colors.green || raspadorSecundarioNA) &&
          (statusTerceiro == Colors.green || raspadorTerceiroNA) &&
          (statusReservatorio == Colors.green || reservatorioNA);

  // --- Serialização (Firestore / SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      "tag": tag,
      "area": area,
      "raspadorPrimarioNA": raspadorPrimarioNA,
      "raspadorPrimarioPressao": raspadorPrimarioPressao,
      "raspadorSecundarioNA": raspadorSecundarioNA,
      "raspadorSecundarioPressao": raspadorSecundarioPressao,
      "raspadorTerceiroNA": raspadorTerceiroNA,
      "raspadorTerceiroPressao": raspadorTerceiroPressao,
      "reservatorioNA": reservatorioNA,
      "reservatorioPressao": reservatorioPressao,
      "updatedAt": updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory Equipamento.fromJson(Map<String, dynamic> json) {
    return Equipamento(
      tag: json["tag"]?? "-",
      area: json["area"] ?? "-",
      raspadorPrimarioNA: json["raspadorPrimarioNA"] ?? false,
      raspadorPrimarioPressao: (json["raspadorPrimarioPressao"] ?? 0.0).toDouble(),
      raspadorSecundarioNA: json["raspadorSecundarioNA"] ?? false,
      raspadorSecundarioPressao: (json["raspadorSecundarioPressao"] ?? 0.0).toDouble(),
      raspadorTerceiroNA: json["raspadorTerceiroNA"] ?? false,
      raspadorTerceiroPressao: (json["raspadorTerceiroPressao"] ?? 0.0).toDouble(),
      reservatorioNA: json["reservatorioNA"] ?? false,
      reservatorioPressao: (json["reservatorioPressao"] ?? 0.0).toDouble(),
      updatedAt: json["updatedAt"] != null
          ? (json["updatedAt"] as Timestamp).toDate()
          : null,
    );
  }
}

