import 'dart:io';

import 'package:dynamodb_easyclient/appleLogin/auth_service.dart';
import 'package:dynamodb_easyclient/main.dart';
import 'package:dynamodb_easyclient/pages/authenticate/sign_up.dart';
import 'package:dynamodb_easyclient/service/auth.dart';
import 'package:dynamodb_easyclient/shared_files/constants.dart';
import 'package:dynamodb_easyclient/shared_files/show_loading.dart';
import 'package:dynamodb_easyclient/shared_files/toast.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();
  FocusNode pwdFocusNode = FocusNode();
  String _email;
  String _password;
  bool showLoading = false, _pwVisible = false, resetPwEmailSended = false;
  @override
  Widget build(BuildContext context) {
    if (showLoading) return const Loading();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formkey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text('Welcome', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 10),
                    const Text('Enter your Email address to sign in.',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      decoration: loginTextInputDecoration.copyWith(
                        hintText: 'Email',
                      ),
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter a email address';
                        } else if (!EmailValidator.validate(_email)) {
                          return 'Enter vaild email address';
                        }
                        return null;
                      },
                      onChanged: (val) => setState(() => _email = val),
                      onFieldSubmitted: (val) {
                        FocusScope.of(context).requestFocus(pwdFocusNode);
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: !_pwVisible,
                      focusNode: pwdFocusNode,
                      decoration: loginTextInputDecoration.copyWith(
                        hintText: 'Password',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _pwVisible = !_pwVisible;
                            });
                          },
                          child: Icon(
                              _pwVisible
                                  ? FontAwesomeIcons.eyeSlash
                                  : FontAwesomeIcons.eye,
                              size: 18,
                              color: Colors.grey),
                        ),
                      ),
                      validator: (val) => val.length < 6
                          ? 'Please enter 6+ char password'
                          : null,
                      onChanged: (val) => setState(() => _password = val),
                    ),
                    const SizedBox(height: 7),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: resetPasswordDialog,
                          child: const Text('Forgot Password?',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12))),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: double.maxFinite,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: c1),
                          onPressed: () async {
                            if (_formkey.currentState.validate()) {
                              setState(() => showLoading = true);

                              dynamic user = await AuthService(context: context)
                                  .signInWithEmailAndPassword(
                                      _email, _password);

                              if (user == null) {
                                setState(() => showLoading = false);
                              } else {
                                setState(() => showLoading = false);
                                if (!user.emailVerified) {
                                  showToast(
                                      emailVerificationFailedMsg, context);
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const MyApp()));
                                }
                              }
                            }
                          },
                          child: const Text('SIGN IN',
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontSize: 18,
                                  fontWeight: FontWeight.w500))),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.center,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: 'Don\'t have account?  ',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                            children: [
                              TextSpan(
                                  text: 'Create new account.',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpPage()));
                                    },
                                  style: TextStyle(color: c1, fontSize: 12)),
                            ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                        alignment: Alignment.center,
                        child: Text('Or',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 18))),
                    if (Platform.isIOS) const SizedBox(height: 20),
                    if (Platform.isIOS)
                      SizedBox(
                        width: double.maxFinite,
                        height: 40,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: c3),
                            onPressed: () async {
                              logInWithApple(context);
                            },
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(3)),
                                  padding: const EdgeInsets.all(5),
                                  child: const Icon(
                                    FontAwesomeIcons.apple,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                ),
                                const Expanded(child: SizedBox(width: 3)),
                                const Text('CONNECT WITH APPLE',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                                const Expanded(child: SizedBox(width: 3)),
                              ],
                            )),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.maxFinite,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: c2),
                          onPressed: () async {
                            setState(() {
                              showLoading = true;
                            });
                            User user = await AuthService(context: context)
                                .signInWithGoogle();
                            if (user == null) {
                              setState(() {
                                showLoading = false;
                              });
                            } else {
                              setState(() {
                                showLoading = false;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3)),
                                padding: const EdgeInsets.all(5),
                                child: Image.asset('assets/google-logo.png',
                                    width: 15, height: 15),
                              ),
                              const Expanded(child: SizedBox(width: 3)),
                              const Text('CONNECT WITH GOOGLE',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                              const Expanded(child: SizedBox(width: 3)),
                            ],
                          )),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  resetPasswordDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState2) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Container(
                height: 210,
                decoration: BoxDecoration(
                    // color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: resetPwEmailSended
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Please check your inbox and reset your password.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Email sent to: $_email',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style:
                                ElevatedButton.styleFrom(primary: Colors.green),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: const Text(
                                'Ok',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Form(
                        key: _formkey2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text('Reset Password',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Flexible(
                              child: TextFormField(
                                decoration: loginTextInputDecoration.copyWith(
                                  hintText: 'Enter you email',
                                ),
                                validator: (val) => val.isEmpty
                                    ? 'Please enter your email'
                                    : null,
                                onChanged: (val) => setState(() {
                                  _email = val;
                                }),
                              ),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formkey2.currentState.validate()) {
                                  bool res = await AuthService(context: context)
                                      .forgotPassword(_email);
                                  if (res) {
                                    setState2(() {
                                      resetPwEmailSended = true;
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: const Text(
                                  'Reset Password',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
              ),
            );
          });
        });
  }
}
