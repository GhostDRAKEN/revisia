import 'package:flutter_test/flutter_test.dart';

import 'package:revisia/main.dart';

void main() {
  testWidgets('Revisia démarre correctement', (WidgetTester tester) async {
    // Vérifie que le point d'entrée principal se construit sans erreur.
    await tester.pumpWidget(const RevisiaApp());

    expect(find.text('Revisia'), findsOneWidget);
    expect(find.text("L'IA qui révise avec toi"), findsOneWidget);
  });
}
