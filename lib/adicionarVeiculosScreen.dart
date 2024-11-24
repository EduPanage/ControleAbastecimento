import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto/homeScreen.dart';


class AdicionarVeiculoScreen extends StatefulWidget {
  @override
  _AdicionarVeiculoScreenState createState() => _AdicionarVeiculoScreenState();
}

class _AdicionarVeiculoScreenState extends State<AdicionarVeiculoScreen> {
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final TextEditingController _corController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para salvar o veículo no Firestore
  Future<void> _adicionarVeiculo() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Criação dos dados do veículo
      Map<String, dynamic> dadosVeiculo = {
        'modelo': _modeloController.text,
        'placa': _placaController.text,
        'ano': _anoController.text,
        'cor': _corController.text,
      };

      // Salvando os dados na subcoleção "meus_veiculos"
      try {
        await _firestore.collection('usuarios').doc(user.uid)
            .collection('meus_veiculos')
            .add(dadosVeiculo);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veículo adicionado com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar veículo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Veículo'),
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
            TextField(
              controller: _modeloController,
              decoration: InputDecoration(labelText: 'Modelo'),
            ),
            TextField(
              controller: _placaController,
              decoration: InputDecoration(labelText: 'Placa'),
            ),
            TextField(
              controller: _anoController,
              decoration: InputDecoration(labelText: 'Ano'),
            ),
            TextField(
              controller: _corController,
              decoration: InputDecoration(labelText: 'Cor'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _adicionarVeiculo,
              child: Text('Adicionar Veículo'),
            ),
          ],
        ),
      ),
    );
  }
}
