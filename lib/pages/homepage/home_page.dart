import 'dart:io';
import 'package:dynamodb_easyclient/models/app_user.dart';
import 'package:dynamodb_easyclient/pages/homepage/dashboard/dashboard_page.dart';
import 'package:dynamodb_easyclient/pages/homepage/settings/setting_page.dart';
import 'package:dynamodb_easyclient/pages/payment/app_subscription_verfication.dart';
import 'package:dynamodb_easyclient/pages/payment/payment.dart';
import 'package:dynamodb_easyclient/service/database/subscription_db_service.dart';
import 'package:dynamodb_easyclient/service/database/shared_db_data.dart';
import 'package:dynamodb_easyclient/shared_files/data/constant_data.dart';
import 'package:dynamodb_easyclient/shared_files/show_loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final AppUserData userDataModel;
  const HomePage({Key key, this.userDataModel}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalFreeTrialDays = 0;
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    calculateTrialTimeLeft(user.metadata.creationTime);
    //checking subcription is active or not
    return FutureBuilder<SharedDbData>(
        future: getSharedDbData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Loading();
          SharedDbData sharedDbData = snapshot.data;
          return FutureBuilder<bool>(
              future:
                  SubscriptionDatabaseService(uid: widget.userDataModel.uuid)
                      .checkUserHaveStripeSubscription(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Loading();
                bool stripeSubIsActive = snapshot.data;
                widget.userDataModel.stirpeSubIsActive = stripeSubIsActive;
                return FutureBuilder<bool>(
                    future: Platform.isAndroid
                        ? appAndroidUserSubVerification(
                            widget.userDataModel.freeUser,
                            widget.userDataModel.purchaseDetails,
                            sharedDbData.apiKey,
                            sharedDbData.googleReceiptValidation)
                        : appIosUserSubVerification(
                            widget.userDataModel.freeUser,
                            sharedDbData.appleReceiptValidation,
                            sharedDbData.appleReceiptValidation2,
                            widget.userDataModel.purchaseDetails,
                            sharedDbData.passwordForApplePurchaseVerfication),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Loading();
                      widget.userDataModel.sharedDbData = sharedDbData;
                      widget.userDataModel.subIsActive = snapshot.data;

                      return Scaffold(
                        appBar: AppBar(
                          toolbarHeight: 45,
                          title: TextButton(
                            onPressed: () {},
                            child: Row(
                              children: [
                                Image.asset('assets/waltsoft_logo.png',
                                    color: Colors.blue, height: 20),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text('Waltsoft',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 19)),
                              ],
                            ),
                          ),
                          elevation: 0,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          actions: [
                            if (totalFreeTrialDays == 0 &&
                                !widget.userDataModel.freeUser &&
                                !widget.userDataModel.subIsActive &&
                                !stripeSubIsActive)
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SubscriptionPaymentPage(
                                                    previousPurchase: widget
                                                        .userDataModel
                                                        .purchaseDetails,
                                                    goldSubscriptionId:
                                                        sharedDbData.goldSubId,
                                                    silverSubscriptionId:
                                                        sharedDbData
                                                            .silverSubId)));
                                  },
                                  icon: Image.asset(
                                    'assets/diamond2.png',
                                    width: 25,
                                  )),
                            if (totalFreeTrialDays == 0 &&
                                !widget.userDataModel.freeUser &&
                                !widget.userDataModel.subIsActive &&
                                !stripeSubIsActive)
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SubscriptionPaymentPage(
                                                    previousPurchase: widget
                                                        .userDataModel
                                                        .purchaseDetails,
                                                    goldSubscriptionId:
                                                        sharedDbData.goldSubId,
                                                    silverSubscriptionId:
                                                        sharedDbData
                                                            .silverSubId)));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.white),
                                  child:
                                      trialStatus(user.metadata.creationTime)),
                            IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SettingPage(
                                                userData: widget.userDataModel,
                                              )));
                                },
                                icon: const Icon(
                                  CupertinoIcons.settings,
                                  color: Colors.black,
                                  size: 20,
                                ))
                          ],
                        ),
                        body: DynoDbDashboard(
                          apiUserData: widget.userDataModel,
                        ),
                      );
                    });
              });
        });
  }

  calculateTrialTimeLeft(DateTime acCreateTime) {
    int difference =
        totalFreeTrialDays - (DateTime.now().difference(acCreateTime).inDays);
    totalFreeTrialDays = difference.isNegative ? 0 : difference;
  }
}
