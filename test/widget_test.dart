import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:check_raspadores/main.dart';

void main() {
  testWidgets('Exibe lista de usinas e navega até equipamentos',
          (WidgetTester tester) async {
        // Monta o app
        await tester.pumpWidget(ChecklistApp());

        // Verifica se as usinas aparecem
        expect(find.text('Usina 5'), findsOneWidget);
        expect(find.text('Usina 6'), findsOneWidget);
        expect(find.text('Usina 7'), findsOneWidget);

        // Clica na "Usina 5"
        await tester.tap(find.text('Usina 5'));
        await tester.pumpAndSettle();

        // Verifica se os equipamentos da usina 5 aparecem
        expect(find.text('5PA6'), findsOneWidget);
        expect(find.text('5PA6A'), findsOneWidget);
        expect(find.text('5PA6B'), findsOneWidget);

        // Clica no equipamento 5PA6
        await tester.tap(find.text('5PA6'));
        await tester.pumpAndSettle();

        // Verifica se abriu a tela de checklist
        expect(find.text('Checklist - 5PA6'), findsOneWidget);

        // Verifica se existe botão "Salvar"
        expect(find.text('Salvar'), findsOneWidget);
      });
}
