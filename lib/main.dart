import 'package:dynamodb_easyclient/service/auth.dart';
import 'package:dynamodb_easyclient/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
        value: AuthService().user,
        initialData: FirebaseAuth.instance.currentUser,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Purchase Notification Tracker',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const Wrapper(),
        ));
  }
}
