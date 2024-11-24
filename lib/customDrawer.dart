import 'package:flutter/material.dart';
import 'package:projeto/homeScreen.dart';
import 'package:projeto/login.dart';
import 'package:projeto/meusVeiculosScreen.dart';
import 'package:projeto/perfilScreen.dart';
import 'package:projeto/adicionarVeiculosScreen.dart';
import 'package:projeto/autenticacaoFirebase.dart';

class CustomDrawer extends StatelessWidget {
  final String nomeUsuario;
  final String emailUsuario;

  CustomDrawer({required this.nomeUsuario, required this.emailUsuario});

  final AutenticacaoFirebase auth = AutenticacaoFirebase();

  void _logout(BuildContext context) async {
    await auth.logout(); // Chama o logout da sua classe personalizada
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()), // Redireciona para a tela de login
          (route) => false, // Remove todas as rotas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(nomeUsuario),
            accountEmail: Text(emailUsuario),
            currentAccountPicture: CircleAvatar(
              child: Text(nomeUsuario[0].toUpperCase()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.directions_car),
            title: Text('Meus Veículos'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MeusVeiculosScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Adicionar Veículo'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdicionarVeiculoScreen()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.history),
            title: Text('Histórico de Abastecimentos'),
            onTap: () {
              // Navegação para Histórico de Abastecimentos, se necessário
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Perfil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PerfilScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
