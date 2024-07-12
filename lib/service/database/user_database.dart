import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamodb_easyclient/models/app_user.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class UserDbService {
  String uid;
  bool signIn;

  UserDbService({this.uid, this.signIn = false});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Users Data
  // add & updater
  Future updateUserData(String name) async {
    await _firestore.collection('User Data').doc(uid).set({
      'Name': name,
    }, SetOptions(merge: true));
  }

  // get Users Data steam
  Stream<AppUserData> get getUserData {
    return _firestore
        .collection('User Data')
        .doc(uid)
        .snapshots()
        .map(appUserDataFormSnapshot);
  }

  // get pim User List Form Snapshot
  AppUserData appUserDataFormSnapshot(DocumentSnapshot snapshot) {
    String stripeId = '';
    String email = '';
    String name = '';
    bool freeUser = false;
    PurchaseDetails purchaseDetails;
    try {
      freeUser = snapshot.get('Free User');
    } catch (e) {}
    try {
      email = snapshot.get('email');
    } catch (e) {}
    try {
      stripeId = snapshot.get('stripeId');
    } catch (e) {}
    try {
      name = snapshot.get('Name');
    } catch (e) {}
    //getting puchase details
    try {
      var dbPD = snapshot.get('Subscription Details');

      purchaseDetails = PurchaseDetails(
        productID: dbPD['productID'],
        purchaseID: dbPD['purchaseID'],
        status: PurchaseStatus.purchased,
        transactionDate: dbPD['transactionDate'],
        verificationData: PurchaseVerificationData(
            localVerificationData: dbPD['localVerificationData'],
            serverVerificationData: dbPD['serverVerificationData'],
            source: dbPD['source']),
      );
      purchaseDetails.pendingCompletePurchase = dbPD['pendingCompletePurchase'];
    } catch (e) {
      purchaseDetails = null;
    }

    return AppUserData(
        purchaseDetails: purchaseDetails,
        freeUser: freeUser,
        name: name,
        userStripeId: stripeId,
        email: email,
        uuid: uid);
  }

  // get subs Data steam
  Stream<DynoSubData> get getSubsIdsData {
    if (signIn) {
      return _firestore
          .collection('Shared Data')
          .doc('stripe data')
          .snapshots()
          .map(subsDataFormSnapshot);
    } else {
      return _firestore
          .collection('Shared Data')
          .doc('homepage_price')
          .snapshots()
          .map(subsDataFormSnapshot);
    }
  }

  // get subs data Form Snapshot
  DynoSubData subsDataFormSnapshot(DocumentSnapshot snapshot) {
    if (signIn) {
      return DynoSubData(
        sub1PriceId: snapshot.get('sub1_price_id'),
        sub2PriceId: snapshot.get('sub2_price_id'),
        sub1Price: snapshot.get('sub1_price'),
        sub2Price: snapshot.get('sub2_price'),
        taxRateIds: snapshot.get('tax_rate_ids'),
        stripePublisherApiKey: snapshot.get('stripePublisherApiKey'),
      );
    } else {
      return DynoSubData(
        sub1Price: snapshot.get('sub_1'),
        sub2Price: snapshot.get('sub_2'),
      );
    }
  }

  deleteUserData() async {
    await FirebaseFirestore.instance.collection('User Data').doc(uid).delete();
  }
}
