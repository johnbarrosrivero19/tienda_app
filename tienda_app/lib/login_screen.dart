import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'firebase_service.dart'; // 👈 NUEVO

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool cargando = false;

  void loginUsuario() async {
    String usuario = usuarioController.text.trim();
    String password = passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      // 👇 USANDO EL SERVICE (ARQUITECTURA)
      final service = FirebaseService();
      await service.login(usuario, password);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );

    } catch (e) {

      String mensaje = "Error al iniciar sesión";

      // Manejo básico de errores (sin depender directo de FirebaseAuth)
      if (e.toString().contains('user-not-found')) {
        mensaje = "Usuario no encontrado";
      } else if (e.toString().contains('wrong-password')) {
        mensaje = "Contraseña incorrecta";
      } else if (e.toString().contains('invalid-email')) {
        mensaje = "Correo inválido";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }

    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.indigo],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [

                const SizedBox(height: 40),

                const Icon(
                  Icons.account_balance,
                  size: 80,
                  color: Colors.white,
                ),

                const SizedBox(height: 15),

                const Text(
                  "Banco JB",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Inicia sesión para continuar",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 40),

                // CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black12,
                      )
                    ],
                  ),
                  child: Column(
                    children: [

                      TextField(
                        controller: usuarioController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Correo",
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Contraseña",
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: cargando ? null : loginUsuario,
                          child: cargando
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Iniciar sesión"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}