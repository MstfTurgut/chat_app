import 'package:chat_app/feature/views/home/home_view.dart';
import 'package:chat_app/product/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../feature/views/auth/login_view.dart';
import '../../feature/views/auth/register_view.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: context.read<AuthService>().authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return (context.watch<AuthService>().showLoginPage)
                  ? const LoginView()
                  : const RegisterView();
            } else {
             bool isEmailVerified =
                  FirebaseAuth.instance.currentUser!.emailVerified;

               return (isEmailVerified)
                  ? const HomeView()
                  : (context.watch<AuthService>().showLoginPage)
                      ? const LoginView()
                      : const RegisterView(); 
              
                 
            }
          } else {
            return const Center(
              child: SizedBox(
                height: 300,
                width: 300,
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
