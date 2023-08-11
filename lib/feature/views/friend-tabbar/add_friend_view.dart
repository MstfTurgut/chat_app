import 'package:chat_app/product/components/my_basic_button.dart';
import 'package:chat_app/product/components/my_text_form_field.dart';
import 'package:chat_app/feature/view-models/friend-tabbar/add_friend_view_model.dart';
import 'package:chat_app/product/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';

import '../../model/profile.dart';
import '../../../product/services/auth_service.dart';

class AddFriendView extends StatefulWidget {
  const AddFriendView({super.key});

  @override
  State<AddFriendView> createState() => _AddFriendViewState();
}

class _AddFriendViewState extends State<AddFriendView> {
  final formStateKey = GlobalKey<FormState>();

  final profileEmailCtr = TextEditingController();

  final _addFriendViewModel = AddFriendViewModel();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formStateKey,
      child: StreamBuilder<List<Profile>>(
          stream: _addFriendViewModel.profileListStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ScaffoldMessenger(
                  child: SnackBar(content: Text(snapshot.error.toString())));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: MyTextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: profileEmailCtr,
                      hintText: 'Friend Email',
                      obscureText: false,
                      validator: (value) {
                        var existingProfilesList = snapshot.data!;
                        var authRef = context.read<AuthService>();

                        if (!EmailValidator.validate(value!)) {
                          return 'Please enter a valid email';
                        } else if (!_addFriendViewModel.belongToProfile(
                            existingProfilesList, value)) {
                          return 'This email does not belong to any profile';
                        } else if (authRef.isCurrentEmail(value)) {
                          return 'Cannot send request to this email';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  MyBasicButton(
                    onPressed: () async {
                      if (formStateKey.currentState!.validate()) {
                        var existingProfilesList = snapshot.data!;
                        Profile currentProfile;
                        bool alreadySent;
                        bool alreadyFriend;

                        if (!mounted) return;
                        currentProfile = await context
                            .read<AuthService>()
                            .getCurrentProfile();

                        if (!mounted) return;
                        alreadySent =
                            await _addFriendViewModel.doesRequestAlreadySent(
                                currentProfile: currentProfile,
                                email: profileEmailCtr.text,
                                profileList: existingProfilesList);

                        if (!mounted) return;
                        alreadyFriend = await _addFriendViewModel
                            .isAlreadyFriend(email: profileEmailCtr.text);

                        if (alreadyFriend) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'User of this email is already your friend!')));
                        } else if (alreadySent) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Request already sent!')));
                        } else {
                          if (!mounted) return;
                          try {
                            await _addFriendViewModel.sendFriendRequest(
                                currentProfile: currentProfile,
                                receiverEmail: profileEmailCtr.text,
                                profileList: existingProfilesList);
                            profileEmailCtr.clear();
                          }  catch (e) {
                            await showErrorDialog(Text('$e'), context);
                          }

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Friend request succesfully sent!')));
                        }
                      }
                    },
                    title: 'Send Friend Request',
                  )
                ],
              );
            }
          }),
    );
  }
}
