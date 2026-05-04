import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/banco_provider.dart';
import 'login_screen.dart';
import 'registro_screen.dart';
import 'theme/app_theme.dart'; //  IMPORTANTE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDuaedUuAsjEaivz4djozjadxkocURjQCw",
      authDomain: "banco-jb.firebaseapp.com",
      projectId: "banco-jb",
      storageBucket: "banco-jb.firebasestorage.app",
      messagingSenderId: "172822252371",
      appId: "1:172822252371:web:0c6b0b489d808416d86fa6",
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => BancoProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Banco JB',

      //  AQUÍ APLICAMOS EL TEMA GLOBAL
      theme: AppTheme.lightTheme,

      home: const Login(),
    );
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  SIN AppBar para look más moderno
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              //  ICONO PROFESIONAL (evita error en tests)
              const Icon(
                Icons.account_balance,
                size: 100,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                "Banco JB",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Tu dinero seguro",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              //  BOTÓN INGRESAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text("Ingresar"),
                ),
              ),

              const SizedBox(height: 15),

              //  BOTÓN REGISTRO
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistroScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Registrarse"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
