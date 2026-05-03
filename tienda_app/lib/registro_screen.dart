import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void registrarUsuario() async {

    String nombre = nombreController.text.trim();
    String usuario = usuarioController.text.trim();
    String password = passwordController.text.trim();

    // VALIDACIONES
    if (nombre.isEmpty || usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    try {
      // 🔐 1. CREAR USUARIO EN FIREBASE AUTH
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: usuario,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // 🔥 2. GUARDAR DATOS EN FIRESTORE
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': nombre,
        'correo': usuario,
        'uid': uid,
        'fecha_registro': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario registrado en Firebase 🚀")),
      );

      // 🔄 REGRESAR AL LOGIN
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });

    } on FirebaseAuthException catch (e) {

      String mensaje = "Error al registrar";

      if (e.code == 'email-already-in-use') {
        mensaje = "El correo ya está registrado";
      } else if (e.code == 'invalid-email') {
        mensaje = "Correo inválido";
      } else if (e.code == 'weak-password') {
        mensaje = "La contraseña es muy débil (mínimo 6 caracteres)";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Crear cuenta",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            // NOMBRE
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                labelText: "Nombre completo",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // USUARIO (EMAIL)
            TextField(
              controller: usuarioController,
              decoration: InputDecoration(
                labelText: "Correo (usuario)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // PASSWORD
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // BOTÓN
            ElevatedButton(
              onPressed: registrarUsuario,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text("Registrarse"),
            ),
          ],
        ),
      ),
    );
  }
}
