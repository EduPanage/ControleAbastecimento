import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:projeto/screens/homeScreen.dart';

class HistoricoAbastecimentoScreen extends StatefulWidget {
  @override
  _HistoricoAbastecimentoScreenState createState() =>
      _HistoricoAbastecimentoScreenState();
}

class _HistoricoAbastecimentoScreenState
    extends State<HistoricoAbastecimentoScreen> {
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _quilometragemController = TextEditingController();
  DateTime? _dataSelecionada;
  final _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _buildResumoConsumo(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return SizedBox();

    double mediaConsumoTotal = 0;
    int registrosComMedia = 0;
    double ultimaMedia = 0;

    for (var i = 0; i < docs.length - 1; i++) {
      var atual = docs[i].data() as Map<String, dynamic>;
      var anterior = docs[i + 1].data() as Map<String, dynamic>;

      double quilometragemAtual = atual['quilometragem'].toDouble();
      double quilometragemAnterior = anterior['quilometragem'].toDouble();
      double litros = atual['quantidade'].toDouble();

      if (quilometragemAtual > quilometragemAnterior && litros > 0) {
        double media = (quilometragemAtual - quilometragemAnterior) / litros;
        mediaConsumoTotal += media;
        registrosComMedia++;
        if (i == 0) ultimaMedia = media;
      }
    }

    double mediaGeral = registrosComMedia > 0 ? mediaConsumoTotal / registrosComMedia : 0;

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo de Consumo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Média Geral: ${mediaGeral.toStringAsFixed(2)} km/L',
              style: TextStyle(fontSize: 16),
            ),
            if (ultimaMedia > 0)
              Text(
                'Último Consumo: ${ultimaMedia.toStringAsFixed(2)} km/L',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _adicionarAbastecimento() async {
    if (!_formKey.currentState!.validate() || _dataSelecionada == null) {
      if (_dataSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selecione uma data')),
        );
      }
      return;
    }

    User? user = _auth.currentUser;

    if (user != null) {
      try {
        QuerySnapshot ultimoAbastecimento = await _firestore
            .collection('usuarios')
            .doc(user.uid)
            .collection('historico_abastecimento')
            .orderBy('quilometragem', descending: true)
            .limit(1)
            .get();

        double mediaConsumo = 0;
        if (ultimoAbastecimento.docs.isNotEmpty) {
          double quilometragemAnterior =
          (ultimoAbastecimento.docs.first['quilometragem'] ?? 0).toDouble();
          double quilometragemAtual = double.parse(_quilometragemController.text);
          double litros = double.parse(_quantidadeController.text);

          if (litros > 0 && quilometragemAtual > quilometragemAnterior) {
            mediaConsumo = (quilometragemAtual - quilometragemAnterior) / litros;
          }
        }

        Map<String, dynamic> dadosAbastecimento = {
          'quantidade': double.parse(_quantidadeController.text),
          'valor': double.parse(_valorController.text),
          'quilometragem': int.parse(_quilometragemController.text),
          'data': _dataSelecionada,
          'mediaConsumo': mediaConsumo,
        };

        await _firestore
            .collection('usuarios')
            .doc(user.uid)
            .collection('historico_abastecimento')
            .add(dadosAbastecimento);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abastecimento adicionado com sucesso!')),
        );

        _limparCampos();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar abastecimento: $e')),
        );
      }
    }
  }

  void _limparCampos() {
    _quantidadeController.clear();
    _valorController.clear();
    _quilometragemController.clear();
    setState(() {
      _dataSelecionada = null;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _selecionarData() async {
    DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataSelecionada = dataEscolhida;
      });
    }
  }

  Stream<QuerySnapshot> _getHistoricoStream() {
    return _firestore
        .collection('usuarios')
        .doc(_auth.currentUser?.uid)
        .collection('historico_abastecimento')
        .orderBy('data', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Histórico de Abastecimento'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Histórico'),
              Tab(text: 'Novo Abastecimento'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Primeira tab - Histórico
            StreamBuilder<QuerySnapshot>(
              stream: _getHistoricoStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Nenhum abastecimento registrado'));
                }

                return Column(
                  children: [
                    _buildResumoConsumo(snapshot.data!.docs),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var abastecimento = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                          DateTime data = (abastecimento['data'] as Timestamp).toDate();
                          String dataFormatada =
                          DateFormat('dd/MM/yyyy').format(data);

                          double mediaConsumo = 0;
                          if (index < snapshot.data!.docs.length - 1) {
                            var abastecimentoAnterior = snapshot.data!.docs[index + 1].data()
                            as Map<String, dynamic>;
                            double quilometragemAtual = abastecimento['quilometragem'].toDouble();
                            double quilometragemAnterior = abastecimentoAnterior['quilometragem'].toDouble();
                            double litros = abastecimento['quantidade'].toDouble();

                            if (litros > 0 && quilometragemAtual > quilometragemAnterior) {
                              mediaConsumo = (quilometragemAtual - quilometragemAnterior) / litros;
                            }
                          }

                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                'Data: $dataFormatada',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Quantidade: ${abastecimento['quantidade'].toString()} L'),
                                  Text('Valor: R\$ ${abastecimento['valor'].toStringAsFixed(2)}'),
                                  Text('Quilometragem: ${abastecimento['quilometragem']} km'),
                                  if (mediaConsumo > 0)
                                    Text(
                                      'Consumo: ${mediaConsumo.toStringAsFixed(2)} km/L',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool confirmarExclusao = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirmar Exclusão'),
                                        content: Text('Deseja excluir este registro?'),
                                        actions: [
                                          TextButton(
                                            child: Text('Cancelar'),
                                            onPressed: () => Navigator.of(context).pop(false),
                                          ),
                                          TextButton(
                                            child: Text('Excluir'),
                                            onPressed: () => Navigator.of(context).pop(true),
                                          ),
                                        ],
                                      );
                                    },
                                  ) ?? false;

                                  if (confirmarExclusao) {
                                    await snapshot.data!.docs[index].reference.delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Registro excluído com sucesso')),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _quantidadeController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Quantidade (L)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a quantidade';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor, insira um número válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _valorController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Valor (R\$)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o valor';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor, insira um número válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _quilometragemController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quilometragem',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a quilometragem';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Por favor, insira um número válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _selecionarData,
                      child: Text(
                        _dataSelecionada == null
                            ? 'Selecionar Data'
                            : 'Data: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada!)}',
                      ),
                    ),
                    SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: _adicionarAbastecimento,
                      child: Text('Adicionar Abastecimento'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}