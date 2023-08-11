import 'dart:convert';

import 'package:chat_app/product/services/auth_gate.dart';
import 'package:chat_app/product/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeStr = await rootBundle.loadString('assets/appainter_theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  runApp(ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: MyApp(theme: theme)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key ,required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App Demo',
      theme: theme,
      home: const AuthGate(),
    );
  }
}
