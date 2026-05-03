import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// IMPORTA TUS PANTALLAS
import 'package:tienda_app/login_screen.dart';
import 'package:tienda_app/transferencia_screen.dart';
import 'package:tienda_app/home_screen.dart';
import 'package:tienda_app/providers/banco_provider.dart';

void main() {

  // ===============================
  // TEST 1
  // ===============================
  testWidgets('TEST 1 - Login falla con campos vacíos', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Todos los campos son obligatorios'), findsOneWidget);
  });


  // ===============================
  // TEST 2
  // ===============================
  testWidgets('TEST 2 - Login renderiza correctamente', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });


  // ===============================
  // TEST 3
  // ===============================
  testWidgets('TEST 3 - Transferencia falla con monto inválido', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BancoProvider()),
        ],
        child: const MaterialApp(home: TransferenciaScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), '123');
    await tester.enterText(find.byType(TextField).at(1), 'Juan');
    await tester.enterText(find.byType(TextField).at(2), '0');

    await tester.tap(find.text('Transferir'));
    await tester.pump();

    expect(find.text('Monto inválido'), findsOneWidget);
  });


  // ===============================
  // TEST 4
  // ===============================
  testWidgets('TEST 4 - Transferencia reduce saldo', (tester) async {
    final banco = BancoProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: banco,
        child: const MaterialApp(home: TransferenciaScreen()),
      ),
    );

    double saldoInicial = banco.saldo;

    await tester.enterText(find.byType(TextField).at(0), '123');
    await tester.enterText(find.byType(TextField).at(1), 'Juan');
    await tester.enterText(find.byType(TextField).at(2), '100');

    await tester.tap(find.text('Transferir'));
    await tester.pump();

    expect(banco.saldo, lessThan(saldoInicial));
  });


  // ===============================
  // TEST 5
  // ===============================
  testWidgets('TEST 5 - Home muestra saludo', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BancoProvider()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.textContaining('Hola'), findsWidgets);
  });

}