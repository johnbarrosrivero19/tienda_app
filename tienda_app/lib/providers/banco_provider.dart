import 'package:flutter/material.dart';

class BancoProvider extends ChangeNotifier {

  double saldo = 5000000;
  List<String> movimientos = [];

  void transferir(double monto, String nombre) {
    saldo -= monto;
    movimientos.add("Transferencia a $nombre -\$${monto.toStringAsFixed(0)}");
    notifyListeners();
  }

  void pagar(double monto, String servicio) {
    saldo -= monto;
    movimientos.add("Pago $servicio -\$${monto.toStringAsFixed(0)}");
    notifyListeners();
  }
}