import 'package:dynamodb_easyclient/shared_files/exception_handler.dart';
import 'package:dynamodb_easyclient/shared_files/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:dynamodb_easyclient/service/database/user_database.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class AuthService {
  final BuildContext context;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService({this.context});
  //auth change user Stream
  Stream<User> get user {
    return _auth.userChanges();
  }

  // sign in with Email & Password
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return user;
    } catch (e) {
      showToast(
        AuthExceptionHandler().emailSignInHandleException(e),
        context,
      );
      return null;
    }
  }

  // sign in with google
  Future<User> signInWithGoogle() async {
    final dynamic googleSigninAccount = await _googleSignIn.signIn();
    if (googleSigninAccount == null) {
      return null;
    } else {
      try {
        final gsa = await googleSigninAccount.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: gsa.accessToken, idToken: gsa.idToken);
        User user = (await _auth.signInWithCredential(credential)).user;
        await UserDbService(uid: user.uid).updateUserData(user.displayName);
        return user;
      } catch (e) {
        showToast(
          AuthExceptionHandler().signInWithCredentialHandleException(e),
          context,
        );
        return null;
      }
    }
  }

  // register with Email & Password
  Future registerWithEmailAndPassword(
      String email, String password, String userName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      user.sendEmailVerification();
      return user;
    } catch (e) {
      showToast(AuthExceptionHandler().createUserWithEmailHandleException(e),
          context);
      return null;
    }
  }

  // forgot password
  Future<bool> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      showToast(
        AuthExceptionHandler().reauthenticateWithCredentialHandleException(e),
        context,
      );
      return false;
    }
    return true;
  }

  // sign out
  Future signOut() async {
    try {
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      } else {
        await _auth.signOut();
      }
    } catch (e) {}
  }

  //delete user account
  Future<bool> deleteUser(String password) async {
    try {
      User user = _auth.currentUser;
      AuthCredential credentials;
      if (_auth.currentUser.providerData.first.providerId == 'google.com') {
        GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        //get google credentials
        credentials = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);
      } else if (_auth.currentUser.providerData.first.providerId ==
          'apple.com') {
        final AuthorizationResult appleResult =
            await TheAppleSignIn.performRequests([
          AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
        ]);

        credentials = OAuthProvider('apple.com').credential(
          accessToken:
              String.fromCharCodes(appleResult.credential.authorizationCode),
          idToken: String.fromCharCodes(appleResult.credential.identityToken),
        );
      } else {
        credentials =
            EmailAuthProvider.credential(email: user.email, password: password);
      }

      UserCredential res = await user.reauthenticateWithCredential(credentials);
      await UserDbService(uid: res.user.uid)
          .deleteUserData(); // called from database class
      await res.user.delete();

      return true;
    } catch (e) {
      showToast(
          AuthExceptionHandler().reauthenticateWithCredentialHandleException(e),
          context);
      return false;
    }
  }
}
