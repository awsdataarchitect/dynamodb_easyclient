import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionDatabaseService {
  final String uid;

  SubscriptionDatabaseService({this.uid});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future updataUserPurchaseDetails(
    PurchaseDetails purchaseDetails,
  ) async {
    return await _firestore.collection('User Data').doc(uid).set({
      'Subscription Details': {
        'error': purchaseDetails.error,
        'pendingCompletePurchase': purchaseDetails.pendingCompletePurchase,
        'productID': purchaseDetails.productID,
        'purchaseID': purchaseDetails.purchaseID,
        'status': purchaseDetails.status.index,
        'transactionDate': purchaseDetails.transactionDate,
        'localVerificationData':
            purchaseDetails.verificationData.localVerificationData,
        'serverVerificationData':
            purchaseDetails.verificationData.serverVerificationData,
        'source': purchaseDetails.verificationData.source,
        'date': Timestamp.now()
      }
    }, SetOptions(merge: true));
  }

  Future<Map<String, String>> getSubIds() async {
    var ds =
        await _firestore.collection('Shared Data').doc('app_sub_ids').get();

    String sub1 = ds.get('gold_subscription');
    String sub2 = ds.get('sliver_subscription');

    return {'sliver_sub_id': sub1, 'gold_sub_id': sub2};
  }

  Future<bool> checkUserHaveStripeSubscription() async {
    QuerySnapshot qs = await _firestore
        .collection('User Data')
        .doc(uid)
        .collection('subscriptions')
        .where('status', isEqualTo: 'Active')
        .get();

    if (qs.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
