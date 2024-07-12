import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamodb_easyclient/models/key_id_data.dart';

class UserKeyIdDbService {
  String uid;

  UserKeyIdDbService({this.uid});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Users Data
  // add & updater
  Future addNewKey(String keyName, String keyId, String keySecret) async {
    await _firestore
        .collection('User Data')
        .doc(uid)
        .collection('User Key Ids')
        .doc()
        .set(
      {'key_name': keyName, 'key_id': keyId, 'key_secret': keySecret},
    );
  }

  Future updateKey(
      String keyName, String keyId, String keySecret, String docId) async {
    await _firestore
        .collection('User Data')
        .doc(uid)
        .collection('User Key Ids')
        .doc(docId)
        .set(
      {'key_name': keyName, 'key_id': keyId, 'key_secret': keySecret},
    );
  }

  // get Users Data steam
  Stream<List<KeyIdData>> get getUserKeyIdsData {
    return _firestore
        .collection('User Data')
        .doc(uid)
        .collection('User Key Ids')
        .snapshots()
        .map(keyIdsFormSnapshot);
  }

  // get pim User List Form Snapshot
  List<KeyIdData> keyIdsFormSnapshot(QuerySnapshot qs) {
    return qs.docs.map((ds) {
      String key_name = '';
      String key_id = '';
      String key_secret = '';
      try {
        key_name = ds.get('key_name');
      } catch (e) {}
      try {
        key_id = ds.get('key_id');
      } catch (e) {}
      try {
        key_secret = ds.get('key_secret');
      } catch (e) {}

      return KeyIdData(
          revealSecret: false,
          docId: ds.id,
          keyId: key_id,
          keyName: key_name,
          keySecret: key_secret);
    }).toList();
  }

  deleteKeyID(String docId) async {
    await _firestore
        .collection('User Data')
        .doc(uid)
        .collection('User Key Ids')
        .doc(docId)
        .delete();
  }
}
