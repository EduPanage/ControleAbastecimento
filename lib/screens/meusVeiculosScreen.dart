import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto/screens/homeScreen.dart';

class MeusVeiculosScreen extends StatefulWidget {
  @override
  _MeusVeiculosScreenState createState() => _MeusVeiculosScreenState();
}

class _MeusVeiculosScreenState extends State<MeusVeiculosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<DocumentSnapshot>> _getVeiculos() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('meus_veiculos')
          .get();
      return querySnapshot.docs;
    }
    return [];
  }

  Future<void> _editarVeiculo(String id, Map<String, dynamic> dadosAtuais) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarVeiculoScreen(
          veiculoId: id,
          dadosAtuais: dadosAtuais,
        ),
      ),
    ).then((_) {
      setState(() {}); // Atualiza a lista após edição
    });
  }

  Future<void> _confirmarExclusao(BuildContext context, String id, String modelo) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Deseja realmente excluir o veículo $modelo?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteVeiculo(id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVeiculo(String id) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(_auth.currentUser?.uid)
          .collection('meus_veiculos')
          .doc(id)
          .delete();

      setState(() {}); // Atualiza a lista após exclusão

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veículo excluído com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir veículo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Veículos'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
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

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(veiculo['modelo']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Placa: ${veiculo['placa']}'),
                      Text('Ano: ${veiculo['ano']}'),
                      Text('Cor: ${veiculo['cor']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editarVeiculo(
                          veiculos[index].id,
                          veiculo,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _confirmarExclusao(
                          context,
                          veiculos[index].id,
                          veiculo['modelo'],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditarVeiculoScreen extends StatefulWidget {
  final String veiculoId;
  final Map<String, dynamic> dadosAtuais;

  EditarVeiculoScreen({required this.veiculoId, required this.dadosAtuais});

  @override
  _EditarVeiculoScreenState createState() => _EditarVeiculoScreenState();
}

class _EditarVeiculoScreenState extends State<EditarVeiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _modeloController;
  late TextEditingController _placaController;
  late TextEditingController _anoController;
  late TextEditingController _corController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _modeloController = TextEditingController(text: widget.dadosAtuais['modelo']);
    _placaController = TextEditingController(text: widget.dadosAtuais['placa']);
    _anoController = TextEditingController(text: widget.dadosAtuais['ano'].toString());
    _corController = TextEditingController(text: widget.dadosAtuais['cor']);
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore
            .collection('usuarios')
            .doc(_auth.currentUser?.uid)
            .collection('meus_veiculos')
            .doc(widget.veiculoId)
            .update({
          'modelo': _modeloController.text,
          'placa': _placaController.text,
          'ano': int.tryParse(_anoController.text) ?? 0,
          'cor': _corController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veículo atualizado com sucesso!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar alterações: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Veículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(labelText: 'Modelo'),
                validator: (value) => value == null || value.isEmpty ? 'Digite o modelo' : null,
              ),
              TextFormField(
                controller: _placaController,
                decoration: InputDecoration(labelText: 'Placa'),
                validator: (value) => value == null || value.isEmpty ? 'Digite a placa' : null,
              ),
              TextFormField(
                controller: _anoController,
                decoration: InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Digite o ano' : null,
              ),
              TextFormField(
                controller: _corController,
                decoration: InputDecoration(labelText: 'Cor'),
                validator: (value) => value == null || value.isEmpty ? 'Digite a cor' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvarAlteracoes,
                child: Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
