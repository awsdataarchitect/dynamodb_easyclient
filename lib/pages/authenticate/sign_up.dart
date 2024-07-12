import 'dart:io';
import 'package:dynamodb_easyclient/appleLogin/auth_service.dart';
import 'package:dynamodb_easyclient/pages/authenticate/welcome_page.dart';
import 'package:dynamodb_easyclient/pages/terms%20of%20service/privacy_policy.dart';
import 'package:dynamodb_easyclient/pages/terms%20of%20service/terms_of_service_page.dart';
import 'package:dynamodb_easyclient/service/auth.dart';
import 'package:dynamodb_easyclient/shared_files/constants.dart';
import 'package:dynamodb_easyclient/shared_files/show_loading.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formkey = GlobalKey<FormState>();
  String _email, _fullName, _password;
  final FocusNode _emailFN = FocusNode();
  final FocusNode _passwordFN = FocusNode();
  bool showLoading = false;
  bool _pwVisible = false;
  final Future<bool> _isAvailableFuture = TheAppleSignIn.isAvailable();

  @override
  Widget build(BuildContext context) {
    if (showLoading) return const Loading();
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.back, color: Colors.black),
            ),
            title: const Text('Create Account',
                style: TextStyle(fontSize: 16, color: Colors.black)),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    const Text('Create Account',
                        style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 10),
                    RichText(
                      // textAlign: TextAlign.center,
                      text: TextSpan(
                          text:
                              'Enter your Name, Email and Password for sign up.  ',
                          style: const TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                                text: 'Already have account?',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pop(context),
                                style: TextStyle(
                                  color: c1,
                                )),
                          ]),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: loginTextInputDecoration.copyWith(
                        hintText: 'Full Name',
                      ),
                      validator: (val) {
                        if (val.isEmpty) return 'Enter a your full name';

                        return null;
                      },
                      onChanged: (val) => setState(() => _fullName = val),
                      onFieldSubmitted: (val) {
                        FocusScope.of(context).requestFocus(_emailFN);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      focusNode: _emailFN,
                      decoration: loginTextInputDecoration.copyWith(
                        hintText: 'Email Address',
                      ),
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter your email address';
                        } else if (!EmailValidator.validate(_email)) {
                          return 'Enter vaild email address';
                        }
                        return null;
                      },
                      onChanged: (val) => setState(() => _email = val),
                      onFieldSubmitted: (val) {
                        FocusScope.of(context).requestFocus(_passwordFN);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: !_pwVisible,
                      focusNode: _passwordFN,
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
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.maxFinite,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: c1),
                          onPressed: () async {
                            if (_formkey.currentState.validate()) {
                              setState(() => showLoading = true);
                              dynamic user = await AuthService(context: context)
                                  .registerWithEmailAndPassword(
                                      _email, _password, _fullName);
                              setState(() => showLoading = false);
                              if (user != null) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WelcomePage(
                                              email: _email,
                                              password: _password,
                                              username: _fullName.trim(),
                                            )));
                              }
                            }
                          },
                          child: const Text('SIGN UP',
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
                            text: 'By Signing up you agree to our ',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                            children: [
                              TextSpan(
                                  text: 'Terms Conditions',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TermsOfService()));
                                    },
                                  style: TextStyle(color: c1)),
                              TextSpan(
                                  text: ' & ',
                                  style: const TextStyle(color: Colors.grey)),
                              TextSpan(
                                  text: 'Privacy Policy',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PrivacyPolicy()));
                                    },
                                  style: TextStyle(color: c1)),
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
                      FutureBuilder(
                          future: _isAvailableFuture,
                          builder: (context, isAvailableSnapshot) {
                            if (!isAvailableSnapshot.hasData) {
                              return Container();
                            }
                            return isAvailableSnapshot.data
                                ? SizedBox(
                                    width: double.maxFinite,
                                    height: 40,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: c3),
                                        onPressed: () async {
                                          logInWithApple(context);
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(3)),
                                              padding: const EdgeInsets.all(5),
                                              child: const Icon(
                                                FontAwesomeIcons.apple,
                                                color: Colors.black,
                                                size: 16,
                                              ),
                                            ),
                                            const Expanded(
                                                child: SizedBox(width: 3)),
                                            const Text('CONNECT WITH APPLE',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const Expanded(
                                                child: SizedBox(width: 3)),
                                          ],
                                        )),
                                  )
                                : const SizedBox();
                          }),
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
                              Navigator.pop(context);
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
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              const Expanded(child: SizedBox(width: 3)),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
