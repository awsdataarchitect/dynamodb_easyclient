import 'package:dynamodb_easyclient/service/database/shared_db_data.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class AppUserData {
  String email;
  String name;
  String userStripeId;
  String uuid;
  bool freeUser;
  PurchaseDetails purchaseDetails;
  bool subIsActive;
  bool stirpeSubIsActive;
  SharedDbData sharedDbData;
  // DynoSubData dynoSubData;
  AppUserData(
      {this.email,
      this.uuid,
      this.freeUser,
      this.userStripeId,
      this.name,
      this.subIsActive,
      this.sharedDbData,
      this.purchaseDetails
      // this.dynoSubData
      });
}

class DynoSubData {
  String sub1Price;
  String sub2Price;
  String sub1PriceId;
  String sub2PriceId;
  String stripePublisherApiKey;
  List<dynamic> taxRateIds;
  DynoSubData(
      {this.sub1Price,
      this.sub1PriceId,
      this.stripePublisherApiKey,
      this.sub2PriceId,
      this.sub2Price,
      this.taxRateIds});
}
