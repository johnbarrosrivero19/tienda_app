import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart'; //  NUEVO

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
      //  USANDO EL SERVICE (ARQUITECTURA)
      final service = FirebaseService();
      final user = await service.register(usuario, password);

      String uid = user!.uid;

      //  FIRESTORE (SE MANTIENE IGUAL)
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': nombre,
        'correo': usuario,
        'uid': uid,
        'fecha_registro': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario registrado en Firebase 🚀")),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });

    } catch (e) {

      String mensaje = "Error al registrar";

      if (e.toString().contains('email-already-in-use')) {
        mensaje = "El correo ya está registrado";
      } else if (e.toString().contains('invalid-email')) {
        mensaje = "Correo inválido";
      } else if (e.toString().contains('weak-password')) {
        mensaje = "La contraseña es muy débil (mínimo 6 caracteres)";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
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
