import 'package:dynamodb_easyclient/main.dart';
import 'package:dynamodb_easyclient/models/app_user.dart';
import 'package:dynamodb_easyclient/pages/payment/payment.dart';
import 'package:dynamodb_easyclient/pages/terms%20of%20service/privacy_policy.dart';
import 'package:dynamodb_easyclient/pages/terms%20of%20service/terms_of_service_page.dart';
import 'package:dynamodb_easyclient/service/auth.dart';
import 'package:dynamodb_easyclient/service/database/user_database.dart';
import 'package:dynamodb_easyclient/shared_files/toast.dart';
import 'package:dynamodb_easyclient/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatefulWidget {
  final AppUserData userData;
  const SettingPage({Key key, this.userData}) : super(key: key);

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  String name;
  User user;
  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();
  @override
  void initState() {
    name = widget.userData.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: const Text(
            'Settings',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  dialogForUpdatingUserName();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                              text: widget.userData.name + '\n',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: widget.userData.email,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal),
                                )
                              ])),
                      const Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubscriptionPaymentPage(
                              previousPurchase: widget.userData.purchaseDetails,
                              goldSubscriptionId:
                                  widget.userData.sharedDbData.goldSubId,
                              silverSubscriptionId:
                                  widget.userData.sharedDbData.silverSubId)));
                },
                style: ElevatedButton.styleFrom(primary: Colors.white),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Subscription Page',
                        style: TextStyle(color: Colors.black, fontSize: 17),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                        size: 18,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  String url = 'https://www.waltsoft.net';
                  if (await canLaunch(url)) await launch(url);
                },
                style: ElevatedButton.styleFrom(primary: Colors.white),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'About Page',
                        style: TextStyle(color: Colors.black, fontSize: 17),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                        size: 18,
                      )
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PrivacyPolicy()));
                },
                style: ElevatedButton.styleFrom(primary: Colors.white),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.black, fontSize: 17),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                        size: 18,
                      )
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TermsOfService()));
                },
                style: ElevatedButton.styleFrom(primary: Colors.white),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Terms of Service',
                        style: TextStyle(color: Colors.black, fontSize: 17),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                        size: 18,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.white,
                    // color: pC1,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200)),
                padding: const EdgeInsets.all(18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delete This Account',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Once you delete a account, there is no going back. Please be certain.',
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          onPressed: () {
                            createAlertDialogForDeleteAccount(context);
                          },
                          child: Text('Delete This Account',
                              style: TextStyle(color: Colors.white))),
                    ]),
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  AuthService().signOut();
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const MyApp()));
                },
                style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Log out',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  createAlertDialogForDeleteAccount(BuildContext context) {
    bool googleLogin =
        FirebaseAuth.instance.currentUser.providerData.first.providerId ==
                'google.com'
            ? true
            : false;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          String password = '';
          bool deletingUser = false;

          return StatefulBuilder(builder: (context, setState2) {
            return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                    width: 400,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    child: deletingUser
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                                CupertinoActivityIndicator(),
                                SizedBox(
                                  height: 20,
                                ),
                                Text('Deleting Account, Please wait...')
                              ])
                        : SingleChildScrollView(
                            child: Form(
                                key: _formkey2,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Delete Account',
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                          googleLogin
                                              ? 'If you are sure you wish to delete your account, tap \'Re-Authenticate & Delete Account.\''
                                              : 'If you are sure you wish to delete your account, type your password and tap \'Delete Account.\'',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                          )),
                                      if (!googleLogin)
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      if (!googleLogin)
                                        TextFormField(
                                          decoration: InputDecoration(
                                              hintText: 'Enter your password',
                                              fillColor: Colors.white,
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(17),
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .grey.shade200)),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(17),
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .grey.shade200)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(17),
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .grey.shade200))),
                                          validator: (val) {
                                            if (val.isEmpty) {
                                              return 'Enter your password';
                                            }
                                            return null;
                                          },
                                          onChanged: (val) =>
                                              setState2(() => password = val),
                                        ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Wrap(
                                        spacing: 20,
                                        runSpacing: 20,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: googleLogin ? 260 : 150,
                                            height: 30,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.red),
                                                onPressed: () async {
                                                  if (_formkey2.currentState
                                                      .validate()) {
                                                    setState2(() {
                                                      deletingUser = true;
                                                    });
                                                    bool res =
                                                        await AuthService(
                                                                context:
                                                                    context)
                                                            .deleteUser(
                                                                password);
                                                    if (res) {
                                                      showToast(
                                                          'Account Deleted',
                                                          context);
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Wrapper()));
                                                    } else {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        deletingUser = true;
                                                      });
                                                    }
                                                  }
                                                },
                                                child: Text(googleLogin
                                                    ? 'Re-Authentication & Delete Account'
                                                    : 'Delete Account')),
                                          ),
                                          SizedBox(
                                            width: 150,
                                            height: 30,
                                            child: ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel')),
                                          ),
                                        ],
                                      ),
                                    ])))));
          });
        });
  }

  dialogForUpdatingUserName() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              height: 210,
              decoration: BoxDecoration(
                  // color: sfBckColor,
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Form(
                key: _formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text('Update Name',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Flexible(
                      child: TextFormField(
                        initialValue: name,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(17),
                                borderSide:
                                    BorderSide(color: Colors.grey[200])),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(17),
                                borderSide:
                                    BorderSide(color: Colors.grey[200])),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(17),
                                borderSide:
                                    const BorderSide(color: Colors.white))),
                        validator: (val) =>
                            val.isEmpty ? 'Please enter your name' : null,
                        onChanged: (val) => setState(() {
                          name = val;
                        }),
                      ),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () {
                        if (_formkey.currentState.validate()) {
                          UserDbService(uid: user.uid).updateUserData(name);
                          setState(() => widget.userData.name = name);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Text(
                          'Update Name',
                          style: TextStyle(color: Colors.white, fontSize: 17),
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
  }
}
