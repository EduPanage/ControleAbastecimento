import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Importando o Firestore
import 'package:http/http.dart' as http;
import 'dart:convert';

class AutenticacaoFirebase {
  // Função de login usando Firebase Authentication
  Future<String> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Usuário autenticado: ${userCredential.user!.uid}";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "Usuário não encontrado";
      } else if (e.code == 'wrong-password') {
        return "Senha incorreta";
      }
      return "Erro de autenticação";
    }
  }

  // Função de autenticação via API (se você tiver uma API externa)
  Future<String> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://sua-api.com/login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String token = data['token'];
      // Salve o token em um armazenamento seguro
      return "Autenticação bem-sucedida, token: $token";
    } else {
      return "Erro de autenticação";
    }
  }

  // Função de registro com Firebase Authentication e Firestore
  Future<String> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Cria o documento no Firestore para o novo usuário
      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': '',  // Nome vazio, pode ser preenchido depois
        'telefone': '',  // Telefone vazio
        'endereco': '',  // Endereço vazio
      });

      return "Usuário registrado com sucesso: ${userCredential.user!.uid}";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "A senha é muito fraca.";
      } else if (e.code == 'email-already-in-use') {
        return "A conta já existe para esse email.";
      }
      return "Erro de registro";
    } catch (e) {
      return "Erro: $e";
    }
  }

  // Função para verificar se o usuário está logado
  Future<bool> isUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null; // Retorna true se o usuário estiver logado, caso contrário, false
  }

  // Função de logout
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Faz o logout do Firebase
    } catch (e) {
      print("Erro ao realizar logout: $e");
    }
  }
}