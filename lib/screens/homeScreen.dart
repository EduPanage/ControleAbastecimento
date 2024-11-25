import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/customDrawer.dart';
import 'package:projeto/screens/adicionarVeiculosScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<Map<String, dynamic>> _getUserData() {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('usuarios')
            .doc(user.uid)
            .get();

        return {
          'user': user,
          'userData': userDoc.data() as Map<String, dynamic>?,
        };
      }
      return {};
    });
  }

  Stream<QuerySnapshot> _getVeiculosStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('meus_veiculos')
          .snapshots();
    }
    return Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home"),
      ),
      drawer: StreamBuilder<Map<String, dynamic>>(
        stream: _getUserData(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Drawer(child: Center(child: CircularProgressIndicator()));
          }

          if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
            return Drawer(child: Center(child: Text('Usuário não autenticado')));
          }

          User user = userSnapshot.data!['user'] as User;
          Map<String, dynamic>? userData = userSnapshot.data!['userData'];

          String nomeUsuario = userData?['nome']?.toString().isNotEmpty == true
              ? userData!['nome']
              : "Usuário Sem Nome";
          String emailUsuario = user.email ?? "email não disponível";

          return CustomDrawer(
            nomeUsuario: nomeUsuario,
            emailUsuario: emailUsuario,
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getVeiculosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar veículos'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nenhum veículo cadastrado'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdicionarVeiculoScreen(),
                        ),
                      );
                    },
                    child: Text('Adicionar Veículo'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var veiculo = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.directions_car, size: 40),
                  title: Text(veiculo['modelo']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Placa: ${veiculo['placa']}'),
                      Text('Ano: ${veiculo['ano']}'),
                      Text('Cor: ${veiculo['cor']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdicionarVeiculoScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Adicionar Veículo',
      ),
    );
  }
}
