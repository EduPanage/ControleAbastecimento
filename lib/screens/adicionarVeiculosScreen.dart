import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto/screens/homeScreen.dart';

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
  final _formKey = GlobalKey<FormState>();

  Future<void> _adicionarVeiculo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    User? user = _auth.currentUser;

    if (user != null) {
      Map<String, dynamic> dadosVeiculo = {
        'modelo': _modeloController.text,
        'placa': _placaController.text.toUpperCase(),
        'ano': _anoController.text,
        'cor': _corController.text,
        'dataCadastro': DateTime.now(),
      };

      try {
        await _firestore
            .collection('usuarios')
            .doc(user.uid)
            .collection('meus_veiculos')
            .add(dadosVeiculo);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veículo adicionado com sucesso!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o modelo do veículo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _placaController,
                decoration: InputDecoration(
                  labelText: 'Placa',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a placa do veículo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _anoController,
                decoration: InputDecoration(
                  labelText: 'Ano',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o ano do veículo';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um ano válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _corController,
                decoration: InputDecoration(
                  labelText: 'Cor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a cor do veículo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _adicionarVeiculo,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Adicionar Veículo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}