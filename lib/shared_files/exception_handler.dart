class AuthExceptionHandler {
  //sign in with email exceptions
  String emailSignInHandleException(e) {
    String msg;
    switch (e.code) {
      case 'invalid-email':
        msg = "Your email address appears to be malformed.";
        break;
      case "wrong-password":
        msg = "Your password is wrong.";
        break;
      case "user-not-found":
        msg = "User with this email doesn't exist.";
        break;
      case "user-disabled":
        msg = "User with this email has been disabled.";
        break;
      default:
        msg = "An undefined Error happened.";
    }
    return msg;
  }

  //signInWithCredential exceptions
  String signInWithCredentialHandleException(e) {
    String msg;
    switch (e.code) {
      /*If you enabled the One account per email address setting in the Firebase console, when a user tries to sign in a to a provider (such as Google) with an email that already exists for another Firebase user's provider (such as Facebook), the error auth/account-exists-with-different-credential is thrown along with an AuthCredential object (Google ID token). To complete the sign in to the intended provider, the user has to sign first to the existing provider (Facebook) and then link to the former AuthCredential (Google ID token).
      */
      case "account-exists-with-different-credential":
        msg = 'Account exists with different credentials.';
        break;
      case "invalid-credential":
        msg = "Your credential appears to be malformed or has expired.";
        break;
      case "operation-not-allowed":
        msg = "Type of account corresponding to the credential is not enabled";
        break;
      case "user-disabled":
        msg = "User with this email has been disabled.";
        break;
      case "user-not-found":
        msg = "User with this credential doesn't exist.";
        break;
      //only for EmailAuthProvider.credential
      case "wrong-password":
        msg = "Your password is wrong.";
        break;
      //only for PhoneAuthProvider.credential
      case "invalid-verification-code":
        msg = "Number verification code is not valid.";
        break;
      //only for PhoneAuthProvider.credential
      case "invalid-verification-id":
        msg = "Verification ID of the credential is not valid.id.";
        break;
      default:
        msg = "An undefined Error happened.";
    }
    return msg;
  }

  //reauthenticateWithCredential & update password exceptions
  String reauthenticateWithCredentialHandleException(e) {
    String msg;
    switch (e.code) {
      case "user-mismatch":
        msg = 'Account exists with different credentials.';
        break;
      case "user-not-found":
        msg = "User with this credential doesn't exist.";
        break;
      case "invalid-credential":
        msg = "Your credential appears to be malformed or has expired.";
        break;
      //only for EmailAuthProvider.credential
      case "invalid-email":
        msg = "Your email is not valid";
        break;
      //only for EmailAuthProvider.credential
      case "wrong-password":
        msg = "Your password is wrong.";
        break;
      //only for PhoneAuthProvider.credential
      case "invalid-verification-code":
        msg = "Number verification code is not valid.";
        break;
      //only for PhoneAuthProvider.credential
      case "invalid-verification-id":
        msg = "Verification ID of the credential is not valid.id.";
        break;
      //update password exceptions
      case "weak-password":
        msg = "Your password is not strong enough.";
        break;
      //update password exceptions
      case 'requires-recent-login':
        msg = 'Recent login required';
        break;
      //When your email updated
      case 'user-token-expired':
        msg =
            'Your profile data is update successfully, try to login with new credential';
        break;
      default:
        msg = "An undefined Error happened.";
    }
    return msg;
  }

  //create User with email exceptions
  String createUserWithEmailHandleException(e) {
    String msg;
    switch (e.code) {
      case "email-already-in-use":
        msg =
            'The email has already been registered. Please login or reset your password.';
        break;
      case "invalid-email":
        msg = "Your email appears to be malformed or has expired.";
        break;
      case "operation-not-allowed":
        msg = "Sign in with email/password is not enabled.";
        break;
      case "weak-password":
        msg = "Your password is not strong enough.";
        break;

      default:
        msg = "An undefined Error happened.";
    }
    return msg;
  }
}
