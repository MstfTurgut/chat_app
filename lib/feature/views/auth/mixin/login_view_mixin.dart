



import 'package:flutter/material.dart';

import '../login_view.dart';

mixin LoginViewMixin on State<LoginView> {


  bool isDisabled = false;
  final emailCtr = TextEditingController();
  final passwordCtr = TextEditingController();

  final formStateKey = GlobalKey<FormState>();


  @override
  void dispose() {
    emailCtr.dispose();
    passwordCtr.dispose();
    super.dispose();
  }

}