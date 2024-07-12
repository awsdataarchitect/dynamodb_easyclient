import 'package:cloud_firestore/cloud_firestore.dart';

Future<SharedDbData> getSharedDbData() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var ds =
      await _firestore.collection('Shared Data').doc('app_shared_data').get();

  return SharedDbData(
    //api key
    apiKey: ds.get('api key'),
    passwordForApplePurchaseVerfication:
        ds.get('passwordForApplePurchaseVerfication'),
    //subscription ids
    goldSubId: ds.get('gold_subscription'),
    silverSubId: ds.get('sliver_subscription'),
    //all api urls
    googleReceiptValidation: ds.get('Google Receipt Validation'),
    appleReceiptValidation: ds.get('Verify Apple Receipt'),
    appleReceiptValidation2: ds.get('Verify Apple Receipt 2'),
  );
}

class SharedDbData {
  //api key
  String apiKey;
  //Subscirption ids
  String goldSubId;
  String silverSubId;
  String googleReceiptValidation;
  String appleReceiptValidation;
  String appleReceiptValidation2;
  String passwordForApplePurchaseVerfication;
  SharedDbData({
    this.apiKey,
    this.goldSubId,
    this.silverSubId,
    this.passwordForApplePurchaseVerfication,
    this.appleReceiptValidation2,
    this.googleReceiptValidation,
    this.appleReceiptValidation,
  });
}
