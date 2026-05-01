import 'package:flutter/material.dart';
import 'transferencia_screen.dart';
import 'movimientos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
 State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool verSaldo = true;
  double saldo = 5000000;

  // 🔥 LISTA DINÁMICA DE MOVIMIENTOS
  List<String> movimientos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Banco JB"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [

            // 👤 Saludo
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Hola, Usuario 👋",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // 💳 TARJETA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.indigo],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Banco JB",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.account_balance, color: Colors.white),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "**** **** **** 1234",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Saldo disponible",
                        style: TextStyle(color: Colors.white70),
                      ),
                      IconButton(
                        icon: Icon(
                          verSaldo ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            verSaldo = !verSaldo;
                          });
                        },
                      )
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    verSaldo ? "\$ ${saldo.toStringAsFixed(0)}" : "******",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Válido hasta 12/28",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔘 BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                botonAccion(Icons.send, "Transferir"),
                botonAccion(Icons.receipt, "Pagar"),
                botonAccion(Icons.account_balance, "Cuenta"),
              ],
            ),

            const SizedBox(height: 30),

            // 📄 MOVIMIENTOS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Últimos movimientos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 LISTA DINÁMICA
            Expanded(
              child: movimientos.isEmpty
                  ? const Center(
                      child: Text("No hay movimientos aún"),
                    )
                  : ListView.builder(
                      itemCount: movimientos.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.arrow_upward, color: Colors.red),
                          title: const Text("Transferencia"),
                          subtitle: Text(movimientos[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 BOTONES FUNCIONALES
  Widget botonAccion(IconData icono, String texto) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {

            // 🔥 TRANSFERIR
            if (texto == "Transferir") {

              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransferenciaScreen(saldo: saldo),
                ),
              );

              if (resultado != null) {
                setState(() {
                  saldo = resultado["saldo"];
                  movimientos.add(resultado["movimiento"]);
                });
              }

            }

            // 📄 MOVIMIENTOS (pantalla aparte si quieres)
            else if (texto == "Cuenta") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MovimientosScreen(),
                ),
              );
            }

            // 🚧 OTROS
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$texto en construcción")),
              );
            }
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade100,
            child: Icon(icono, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 8),
        Text(texto),
      ],
    );
  }
}