import 'package:document_client/document_client.dart';

String attributeValueToString(AttributeValue av) {
  if (av.boolValue != null) {
    return av.boolValue.toString();
  } else if (av.nullValue != null) {
    return 'null';
  } else if (av.b != null) {
    return av.b.toString();
  } else if (av.bs != null) {
    return av.b.toString();
  } else if (av.l != null) {
    return av.toJson().toString();
  } else if (av.m != null) {
    return av.toJson().toString();
  } else if (av.n != null) {
    return av.n;
  } else if (av.ns != null) {
    var d = av.ns.toString().replaceAll("[", "{");
    d = d.replaceAll("]", "}");
    return d;
  } else if (av.s != null) {
    return av.s;
  } else if (av.ss != null) {
    var d = av.ss.toString().replaceAll("[", "{");
    d = d.replaceAll("]", "}");
    return d;
  }
  return 'error';
}
