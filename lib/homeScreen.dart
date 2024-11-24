import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto/customDrawer.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String nomeUsuario = "";
  String emailUsuario = "";

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        nomeUsuario = user.displayName ?? "Usuário Sem Nome"; // Pega o nome, ou um valor padrão
        emailUsuario = user.email ?? "email não disponível";  // Pega o e-mail do usuário
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home"),
      ),
      drawer: CustomDrawer(
        nomeUsuario: nomeUsuario,
        emailUsuario: emailUsuario,
      ),
      body: Center(
        child: Text(
          'Bem-vindo à tela inicial!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
