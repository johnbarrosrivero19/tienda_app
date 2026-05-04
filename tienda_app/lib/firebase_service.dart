import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // LOGIN
  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // REGISTRO
  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // GUARDAR MOVIMIENTO (MEJORADO)
  Future<void> guardarMovimiento({
    required String tipo,
    required String destinatario,
    required double monto,
    String? referencia,
    String estado = "completado",
  }) async {

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    await _firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('movimientos')
        .add({
      'tipo': tipo,
      'destinatario': destinatario,
      'monto': monto,
      'referencia': referencia,
      'estado': estado,
      'fecha': FieldValue.serverTimestamp(),
    });
  }
}