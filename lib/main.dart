import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:projeto/daoFirestore.dart';
import 'package:projeto/firebase_options.dart';
import 'package:projeto/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DaoFirestore.inicializa();
  runApp(Login());
}