import 'package:flutter/material.dart'; // Para a interface do Flutter
import 'package:cloud_firestore/cloud_firestore.dart'; // Para acessar o Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Para acessar o Firebase Auth (para pegar o UID do usuário)
import 'package:projeto/homeScreen.dart';

class MeusVeiculosScreen extends StatefulWidget {
  @override
  _MeusVeiculosScreenState createState() => _MeusVeiculosScreenState();
}

class _MeusVeiculosScreenState extends State<MeusVeiculosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Veículos'),
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
      body: FutureBuilder(
        future: _getVeiculos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar veículos'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum veículo encontrado'));
          }

          List<DocumentSnapshot> veiculos = snapshot.data as List<DocumentSnapshot>;

          return ListView.builder(
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              var veiculo = veiculos[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text(veiculo['modelo']),
                subtitle: Text('Placa: ${veiculo['placa']}'),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> _getVeiculos() async {
    User? user = _auth.currentUser;

    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore.collection('usuarios')
          .doc(user.uid)
          .collection('meus_veiculos')
          .get();

      return querySnapshot.docs;
    }
    return [];
  }
}
