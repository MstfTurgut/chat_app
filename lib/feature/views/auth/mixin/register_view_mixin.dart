import 'package:flutter/material.dart';

import '../register_view.dart';


mixin RegisterViewMixin on State<RegisterView> {


  bool isDisabled = false;
  final emailCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  final confirmPasswordCtr = TextEditingController();

  final formStateKey = GlobalKey<FormState>();


  @override
  void dispose() {
    emailCtr.dispose();
    passwordCtr.dispose();
    confirmPasswordCtr.dispose();
    super.dispose();
  } 




}