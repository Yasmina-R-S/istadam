import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prueba/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Cargar la app
    await tester.pumpWidget(const InstaDAMApp());

    // Comprobamos que aparece el texto de la Splash
    expect(find.text('InstaDAM'), findsOneWidget);
    expect(find.text('Cargando aplicación...'), findsOneWidget);
  });
}