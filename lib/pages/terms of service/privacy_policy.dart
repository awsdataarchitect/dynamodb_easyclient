import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamodb_easyclient/service/database/privacy_and_terms_db_service.dart';
import 'package:dynamodb_easyclient/shared_files/show_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key key}) : super(key: key);

  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: PrivacyAndTermsDbService().getPrivacyPolicyData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Loading();

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                elevation: 0.1,
                // backgroundColor:
                //     selectedTheme == 'dark' || selectedTheme == 'dark_b'
                //         ? Theme.of(context).appBarTheme.backgroundColor
                //         : Colors.white,
                // iconTheme: IconThemeData(
                //     color: selectedTheme == 'dark' || selectedTheme == 'dark_b'
                //         ? Colors.white
                //         : Colors.black),
                title: const Text(
                  'Privacy Policy',
                ),
              ),
              body: SafeArea(
                child: Center(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: HtmlWidget(snapshot.data),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
