import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

const String appServiceAccountUrl =
    '/opt/notifications-tracker-aeaa0a8324e9.json';

Future<bool> appAndroidUserSubVerification(
  bool freeUser,
  PurchaseDetails purchaseDetails,
  String apiKey,
  String apiUrl,
) async {
  if (freeUser) return true;
  if (purchaseDetails != null) {
    //getting resopnse
    final response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{'x-api-key': apiKey},
        body: jsonEncode(<String, String>{
          "packageName": "com.waltsoft.notifications",
          "productId": purchaseDetails.productID,
          "purchaseToken":
              purchaseDetails.verificationData.serverVerificationData,
          "purchaseType": "Subscription",
          "serviceAccount": appServiceAccountUrl
        }));

    if (response.statusCode == 200 && response != null) {
      bool subIsActive = response.body.contains('paymentState');

      return subIsActive;
    }
  }
  return false;
}

Future<bool> appIosUserSubVerification(
    bool freeUser,
    String apiUrl,
    String apiUrl2,
    PurchaseDetails purchaseDetails,
    String passwordForApplePurchaseVerfication) async {
  if (freeUser) return true;
  if (purchaseDetails == null) return false;
  //getting resopnse form apiUrl 1
  final response = await http.post(Uri.parse(apiUrl),
      body: jsonEncode(<String, String>{
        "password": passwordForApplePurchaseVerfication,
        "receipt-data": purchaseDetails.verificationData.serverVerificationData
      }));
  if (response.statusCode == 200 && response != null) {
    var res = json.decode(response.body);

    if (res['status'] == 21007) {
      //getting resopnse form apiUrl 2
      final response2 = await http.post(Uri.parse(apiUrl2),
          body: jsonEncode(<String, String>{
            "password": passwordForApplePurchaseVerfication,
            "receipt-data":
                purchaseDetails.verificationData.serverVerificationData,
          }));
      if (response2.statusCode == 200 && response2 != null) {
        var res2 = json.decode(response2.body);
        if (res2['status'] != 21007) {
          var renewStatus =
              res2["pending_renewal_info"][0]["auto_renew_status"];
          print('renewStatus:${renewStatus}');

          if (renewStatus == '1') {
            print('response2');
            return true;
          }
        }
      }
    } else {
      var renewStatus = res["pending_renewal_info"][0]["auto_renew_status"];
      print('renewStatus:$renewStatus');

      if (renewStatus == '1') {
        return true;
      }
    }
  }
  print('response2');
  return false;
}
