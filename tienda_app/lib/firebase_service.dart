import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //  LOGIN
  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  //  REGISTRO
  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  //  LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  //  GUARDAR MOVIMIENTOS (PAGOS / TRANSFERENCIAS)
  Future<void> guardarMovimiento({
    required String tipo,
    required String destinatario,
    required double monto,
    String? referencia,
  }) async {

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    await _db
        .collection('usuarios')
        .doc(user.uid)
        .collection('movimientos')
        .add({
      'tipo': tipo,
      'destinatario': destinatario,
      'referencia': referencia ?? '',
      'monto': monto,
      'fecha': FieldValue.serverTimestamp(),
    });
  }
}