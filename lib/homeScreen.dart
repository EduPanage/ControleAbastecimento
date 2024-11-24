// homeScreen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/customDrawer.dart';
import 'package:projeto/adicionarVeiculosScreen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      routes: {
        '/adicionar-veiculo': (context) => AdicionarVeiculoScreen(),
      },
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        nomeUsuario = user.displayName ?? "Usuário Sem Nome";
        emailUsuario = user.email ?? "email não disponível";
      });
    }
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
      drawer: CustomDrawer(
        nomeUsuario: nomeUsuario,
        emailUsuario: emailUsuario,
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
                  onTap: () {
                    // Implementar navegação para detalhes do veículo
                  },
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