import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionDetails {
  Timestamp startTime;
  Timestamp endTime;
  String status; // active, incomplete
  String subscriptionName;
  String membershipImgPath;
  String billingPeriod;

  String productId;
  SubscriptionDetails({
    this.billingPeriod,
    this.startTime,
    this.subscriptionName,
    this.membershipImgPath,
    this.endTime,
    this.status,
    this.productId,
  });
}
