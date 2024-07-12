import 'package:dynamodb_easyclient/service/database/user_database.dart';
import 'package:dynamodb_easyclient/shared_files/constants.dart';
import 'package:dynamodb_easyclient/shared_files/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class WelcomePage extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  const WelcomePage({Key key, this.username, this.email, this.password})
      : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20.0),
              Text(
                'Welcome, ${widget.username}',
                style: TextStyle(
                    color: c1, fontWeight: FontWeight.w500, fontSize: 35),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0),
              const Text('Verification email sent!',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20)),
              const SizedBox(height: 10.0),
              const Text(
                  'Thanks for signing up! We just need your to verify your email address to complete setting up your account. Please check your inbox and follow the instructions.',
                  style: TextStyle(fontSize: 18, color: Colors.black)),
              const SizedBox(height: 20.0),
              Text('Email sent to: ${widget.email}',
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18)),
              const SizedBox(height: 30.0),
              Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), color: c1),
                child: TextButton(
                    onPressed: () async {
                      await user.delete();
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: const [
                        SizedBox(width: 15),
                        Icon(Icons.email, color: Colors.white),
                        Expanded(child: SizedBox(width: 10)),
                        Text('Change Email',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                        Expanded(child: SizedBox(width: 10)),
                      ],
                    )),
              ),
              const SizedBox(height: 20.0),
              Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), color: c1),
                child: TextButton(
                    onPressed: () async {
                      if (_auth.currentUser.emailVerified) {
                        await UserDbService(uid: user.uid).updateUserData(
                          widget.username,
                        );
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyApp()));
                      }
                      if (_auth.currentUser != null) {
                        _auth
                            .signInWithEmailAndPassword(
                                email: widget.email, password: widget.password)
                            .then((value) async {
                          if (_auth.currentUser.emailVerified) {
                            //adding User data
                            await UserDbService(uid: user.uid)
                                .updateUserData(widget.username);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyApp()));
                          } else {
                            showToast(emailVerificationFailedMsg, context);
                          }
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(width: 15),
                        Icon(Icons.login, color: Colors.white),
                        Expanded(child: SizedBox(width: 10)),
                        Text('Verification Done? Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                        Expanded(child: SizedBox(width: 10)),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
