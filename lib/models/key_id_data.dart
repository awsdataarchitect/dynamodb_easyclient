class KeyIdData {
  String keyName;
  String keyId;
  String keySecret;
  String docId;
  bool revealSecret;

  KeyIdData(
      {this.keyId,
      this.revealSecret,
      this.docId,
      this.keyName,
      this.keySecret});
}
