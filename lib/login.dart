import 'package:flutter/material.dart';
import 'package:projeto/firebase/autenticacaoFirebase.dart';
import 'package:projeto/screens/homeScreen.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tela de Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AutenticacaoFirebase auth = AutenticacaoFirebase();

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos!')),
      );
      return;
    }

    String message = await auth.signInWithEmailPassword(email, password);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    _validaLogin();
  }

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos!')),
      );
      return;
    }

    String message = await auth.registerWithEmailPassword(email, password);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    _validaLogin();
  }

  void _validaLogin() async {
    if (await auth.isUserLoggedIn()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                labelStyle: TextStyle(fontSize: 14),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                labelStyle: TextStyle(fontSize: 14),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: Text('Entrar'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrar'),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Não tem uma conta? "),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text("Registrar-se"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
