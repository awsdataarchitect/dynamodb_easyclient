import 'package:dynamodb_easyclient/service/database/user_database.dart';
import 'package:dynamodb_easyclient/shared_files/exception_handler.dart';
import 'package:dynamodb_easyclient/shared_files/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

logInWithApple(BuildContext context) async {
  final AuthorizationResult result = await TheAppleSignIn.performRequests([
    const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
  ]);
  final _firebaseAuth = FirebaseAuth.instance;

  switch (result.status) {
    case AuthorizationStatus.authorized:
      try {
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        final authResult = await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = authResult.user;
        DateTime creationTime = firebaseUser.metadata.creationTime;
        DateTime now = DateTime.now().subtract(const Duration(minutes: 3));
        if (now.compareTo(creationTime) != 1) {
          await UserDbService(uid: firebaseUser.uid).updateUserData(
            firebaseUser.email,
          );
        }
        return firebaseUser;
      } catch (e) {
        showToast(AuthExceptionHandler().signInWithCredentialHandleException(e),
            context);
        return null;
      }
      break;

    case AuthorizationStatus.error:
      print("Sign in failed: ${result.error.localizedDescription}");
      break;

    case AuthorizationStatus.cancelled:
      print('User cancelled');
      break;
  }
}
