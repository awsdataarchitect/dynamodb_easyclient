import 'package:dynamodb_easyclient/pages/authenticate/sign_in.dart';
import 'package:dynamodb_easyclient/pages/homepage/home_page.dart';
import 'package:dynamodb_easyclient/service/database/user_database.dart';
import 'package:dynamodb_easyclient/shared_files/show_loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_user.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null) {
      return const SignInPage();
    } else {
      //getting user data and purchase details
      return StreamBuilder<AppUserData>(
          stream: UserDbService(uid: user.uid).getUserData,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Loading();
            AppUserData userDataModel = snapshot.data;
            userDataModel.uuid = user.uid;

            if (user.emailVerified) {
              return HomePage(
                userDataModel: userDataModel,
              );
            }
            return const SignInPage();
          });
    }
  }
}
