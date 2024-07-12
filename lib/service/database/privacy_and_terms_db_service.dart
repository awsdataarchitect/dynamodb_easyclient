import 'package:cloud_firestore/cloud_firestore.dart';

class PrivacyAndTermsDbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getTermsOfServiceData() async {
    DocumentSnapshot res = await _firestore
        .collection('Shared Data')
        .doc('privacy and terms')
        .get();

    return res.get('terms');
  }

  Future<String> getPrivacyPolicyData() async {
    DocumentSnapshot res = await _firestore
        .collection('Shared Data')
        .doc('privacy and terms')
        .get();

    return res.get('privacy');
  }
}
