import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/providers/banco_provider.dart';

void main() {

  // =========================
  // TEST 1
  // =========================
  test("TEST 1 - Saldo inicial correcto", () {
    final banco = BancoProvider();

    expect(banco.saldo, 5000000);
  });

  // =========================
  // TEST 2
  // =========================
  test("TEST 2 - Transferencia reduce saldo", () {
    final banco = BancoProvider();

    banco.transferir(100000, "Juan");

    expect(banco.saldo, 4900000);
  });

  // =========================
  // TEST 3
  // =========================
  test("TEST 3 - Pago reduce saldo", () {
    final banco = BancoProvider();

    banco.pagar(50000, "Luz");

    expect(banco.saldo, 4950000);
  });

  // =========================
  // TEST 4
  // =========================
  test("TEST 4 - Se registra movimiento", () {
    final banco = BancoProvider();

    banco.transferir(100000, "Carlos");

    expect(banco.movimientos.isNotEmpty, true);
  });

  // =========================
  // TEST 5
  // =========================
  test("TEST 5 - Múltiples operaciones", () {
    final banco = BancoProvider();

    banco.transferir(100000, "Juan");
    banco.pagar(50000, "Agua");

    expect(banco.saldo, 4850000);
  });

}