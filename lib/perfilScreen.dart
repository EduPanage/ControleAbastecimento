import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto/autenticacaoFirebase.dart';

class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _loadUserData();
  }

  // Carrega os dados do usuário do Firestore
  void _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(_user.uid).get();

      if (userDoc.exists) {
        _nomeController.text = userDoc['nome'];
        _telefoneController.text = userDoc['telefone'];
        _enderecoController.text = userDoc['endereco'];
      } else {
        // Se o documento não existir, pode criar com dados padrões ou alertar o usuário
        print("Usuário não encontrado no Firestore");
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }


  // Atualiza os dados do usuário no Firestore
  void _updateUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Acessa a coleção 'usuarios' e atualiza os dados do documento do usuário pelo uid
      await FirebaseFirestore.instance.collection('usuarios').doc(_user.uid).update({
        'nome': _nomeController.text,
        'telefone': _telefoneController.text,
        'endereco': _enderecoController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dados atualizados com sucesso")));
    } catch (e) {
      print("Erro ao atualizar dados: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao atualizar dados")));
    }

    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _telefoneController,
              decoration: InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _enderecoController,
              decoration: InputDecoration(labelText: 'Endereço'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateUserData,
              child: Text('Atualizar Dados'),
            ),
          ],
        ),
      ),
    );
  }
}
