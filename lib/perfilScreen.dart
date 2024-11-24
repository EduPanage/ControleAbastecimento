import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto/homeScreen.dart';

class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _paisController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para atualizar os dados do perfil no Firestore
  Future<void> _atualizarPerfil() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Criação dos dados do perfil
      Map<String, dynamic> dadosPerfil = {
        'nome': _nomeController.text,
        'endereco': _enderecoController.text,
        'idade': _idadeController.text,
        'cidade': _cidadeController.text,
        'pais': _paisController.text,
      };

      // Atualizando os dados na coleção "usuarios"
      try {
        await _firestore.collection('usuarios').doc(user.uid)
            .update(dadosPerfil);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: $e')),
        );
      }
    }
  }
  @override
  void initState() {
    super.initState();
    _carregarDadosPerfil();
  }

  Future<void> _carregarDadosPerfil() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nomeController.text = data['nome'] ?? '';
          _enderecoController.text = data['endereco'] ?? '';
          _idadeController.text = data['idade'] ?? '';
          _cidadeController.text = data['cidade'] ?? '';
          _paisController.text = data['pais'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navega de volta para a HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo Nome
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            // Campo Cidade
            TextField(
              controller: _cidadeController,
              decoration: InputDecoration(labelText: 'Cidade'),
            ),
            // Campo País
            TextField(
              controller: _paisController,
              decoration: InputDecoration(labelText: 'País'),
            ),
            // Campo Endereço
            TextField(
              controller: _enderecoController,
              decoration: InputDecoration(labelText: 'Endereço'),
            ),
            // Campo Idade
            TextField(
              controller: _idadeController,
              decoration: InputDecoration(labelText: 'Idade'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _atualizarPerfil,
              child: Text('Atualizar Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
