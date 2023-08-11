import 'package:chat_app/feature/model/profile.dart';
import 'package:chat_app/product/db/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AuthService extends ChangeNotifier {
  
  final _firebaseAuth = FirebaseAuth.instance;
  final _database = Database();

  bool showLoginPage = true;

  void togglePages() {
    showLoginPage = !showLoginPage;
    notifyListeners();
  }


  Future<UserCredential> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
  
      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      Profile profile = Profile(uid: userCredential.user!.uid, email: email);
          
      await _database.addAndUpdateProfile(profileMap: profile.toJson());

      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> sendPasswordResetEmail({required String email}) async{
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  bool isCurrentEmail(String email) {
    return (email == _firebaseAuth.currentUser!.email);
  }

  Future<Profile> getCurrentProfile() async{

    var currentProfileMap = await _database.getProfileMap(_firebaseAuth.currentUser!.uid);

    return Profile.fromJson(currentProfileMap);
  }

  Stream<Profile> currentProfileStream() {

    var currentProfileMapStream = _database.getProfileStream(_firebaseAuth.currentUser!.uid);

    return currentProfileMapStream.map((currentProfileMap) => Profile.fromJson(currentProfileMap));

  } 
  







  
}
