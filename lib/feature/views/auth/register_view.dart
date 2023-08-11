import 'package:chat_app/feature/views/auth/mixin/register_view_mixin.dart';
import 'package:chat_app/product/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../../../product/components/my_auth_button.dart';
import '../../../product/components/my_text_form_field.dart';
import '../../../product/components/custom_clippath.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> with RegisterViewMixin{


  Future<void> signUp() async {
    if (formStateKey.currentState!.validate()) {
      isDisabled = true;
      try {
        final userCred = await context.read<AuthService>().signUpWithEmailAndPassword(
            email: emailCtr.text, password: passwordCtr.text);

        await userCred.user!.sendEmailVerification();
        if(!mounted) return;

        await _showVerificationDialog();
        if(!mounted) return;
        context.read<AuthService>().togglePages();

        emailCtr.clear();
        passwordCtr.clear();
        confirmPasswordCtr.clear();

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
          child: Column(children: [
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
                      child: Image.asset('assets/logo.png' , height: 180,)),
                  ),
                ),
              ),
            ),
      
            //welcome back message
            const SizedBox(height: 20),

            Text('Register' , style: GoogleFonts.rubik(fontSize: 25, fontWeight: FontWeight.bold),),
      
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
                  const SizedBox(height: 15),
                  // confirm password textfield
                  MyTextFormField(
                      validator: (value) {
                        if (value != passwordCtr.text) {
                          return 'Passwords does not match';
                        } else {
                          return null;
                        }
                      },
                      controller: confirmPasswordCtr,
                      hintText: 'Confirm Password',
                      obscureText: true),
                  const SizedBox(height: 30),
                  // signin button
                  MyAuthButton(onPressed: isDisabled?() {}:signUp, title:'Sign Up'),
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
                const Text('Already a member?'),
                const SizedBox(
                  width: 4,
                ),
                GestureDetector(
                    onTap: () {
                      context.read<AuthService>().togglePages();
                    },
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    )),
              ],
            ),

          ]),
        ),
      ),
    );
  }


  Future<void> _showVerificationDialog() async {
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
                    'If you dont see a verification link , do not forget to check your spam folder.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approved'),
              onPressed: () async{
                Navigator.of(context).pop();
                await context.read<AuthService>().signOut();
                if(!mounted) return;
              },
            ),
          ],
        );
      },
    );
  }
}
