import 'package:chat_app/feature/views/auth/mixin/login_view_mixin.dart';
import 'package:chat_app/product/components/custom_clippath.dart';
import 'package:chat_app/product/components/my_auth_button.dart';
import 'package:chat_app/product/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../../../product/components/my_text_form_field.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with LoginViewMixin{
  

  Future<void> signIn() async {
    if (formStateKey.currentState!.validate()) {
      isDisabled = true;
      AuthService authService = context.read<AuthService>();
      try {
        var userCred = await authService.signInWithEmailAndPassword(
            email: emailCtr.text, password: passwordCtr.text);

        if (!userCred.user!.emailVerified) {
          await _showVerificationDialog(userCred.user!);
        }

        emailCtr.clear();
        passwordCtr.clear();
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
      isDisabled = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: SingleChildScrollView(
        child: Form(
          key: formStateKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            // icon
            ClipPath(
              clipper: CustomClipPath(),
              child: Container(
                color: Colors.black,
                height: 270,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(50, 50, 0, 0),
                    child: Container(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          'assets/logo.png',
                          height: 180,
                        )),
                  ),
                ),
              ),
            ),

            //welcome back message
            const SizedBox(height: 20),

            Text(
              'Login',
              style:
                  GoogleFonts.rubik(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            //email textfield
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  MyTextFormField(
                      validator: (value) {
                        if (!EmailValidator.validate(value!)) {
                          return 'Please enter a valid email address';
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      controller: emailCtr,
                      hintText: 'Email',
                      obscureText: false),
                  const SizedBox(height: 15),

                  //password textfield
                  MyTextFormField(
                      validator: (value) {
                        if (value!.length < 6) {
                          return 'Password length cannot be less than 6';
                        } else {
                          return null;
                        }
                      },
                      controller: passwordCtr,
                      hintText: 'Password',
                      obscureText: true),
                  const SizedBox(height: 30),


                  //isDisabled is false as default

                  // signin button
                  MyAuthButton(
                      onPressed: isDisabled ? () {} : signIn, title: 'Sign In'),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),

            // register now text button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Not a member?'),
                const SizedBox(
                  width: 4,
                ),
                GestureDetector(
                    onTap: () {
                      context.read<AuthService>().togglePages();
                    },
                    child: const Text(
                      'Register now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            const SizedBox(height: 15,),
            GestureDetector(
              onTap: _showResetPasswordDialog,
              child: const Text('Forgot Password',style: TextStyle(fontWeight: FontWeight.bold),),),
          ]),
        ),
      ),
    );
  }

  Future<void> _showVerificationDialog(User user) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Verification'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please click to the verification link in your email. \n'),
                Text(
                    'If you dont see a verfication link , dont forget to check your spam folder.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await user.sendEmailVerification();
                  if (!mounted) return;
                  context.read<AuthService>().signOut();
                },
                child: const Text('Send Again')),
            TextButton(
              child: const Text('Approved'),
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<AuthService>().signOut();
                if (!mounted) return;
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResetPasswordDialog() async {
    final formStateKey = GlobalKey<FormState>();
    final emailCtr = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please enter your email\n'),
                const Text(
                    'When you click to the reset password, a reset mail will be sent to your email'),
                Form(
                    key: formStateKey,
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailCtr,
                      validator: (value) {
                        if (!EmailValidator.validate(emailCtr.text)) {
                          return 'Please enter a valid email';
                        } else {
                          return null;
                        }
                      },
                    )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Reset Password'),
              onPressed: () async {
                if (formStateKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await context
                      .read<AuthService>()
                      .sendPasswordResetEmail(email: emailCtr.text);
                  if(!mounted) return;
                }
              },
            ),
          ],
        );
      },
    );
  }
}
