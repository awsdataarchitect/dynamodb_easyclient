import 'package:flutter/material.dart';

int totalFreeTrialDays = 7;

Widget trialStatus(DateTime acCreateTime) {
  int difference =
      totalFreeTrialDays - (DateTime.now().difference(acCreateTime).inDays);
  int timeLeft = difference.isNegative ? 0 : difference;
  return Text(timeLeft == 0 ? 'Trial Expired!' : 'Trial $timeLeft days left',
      style: const TextStyle(
          color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold));
}

List<String> dynamomDbRegionLst = [
  'us-east-1',
  'us-east-2',
  'us-west-1',
  'us-west-2',
  //
  'af-south-1',
  //
  'ap-east-1',
  'ap-south-1',
  'ap-northeast-1',
  'ap-northeast-2',
  'ap-northeast-3',
  'ap-southeast-1',
  'ap-southeast-2',
  //
  'ca-central-1',
  //
  'eu-central-1',
  'eu-west-1',
  'eu-west-2',
  'eu-south-1',
  'eu-west-3',
  'eu-north-1',
  //
  'me-south-1',
  //
  'sa-east-1',
];

// List<Map<String, AttributeValue>> demoTableScanOutput = [
//   {
//     "id": AttributeValue(s: "id"),
//     "NewValue": AttributeValue(n: "0"),
//     "sdf": AttributeValue(n: "234234")
//   },
//   {
//     "Friends": AttributeValue(ss: ['Ayush', "Vikash", "lkj"]),
//     "Married": AttributeValue(boolValue: false),
//     "Clients": AttributeValue(l: [
//       AttributeValue(l: [AttributeValue(s: 'Clients1')])
//     ]),
//     "Friends No": AttributeValue(ns: ['34444444', '232131231221']),
//     "Phone Number": AttributeValue(n: "882991299923"),
//     "Plans": AttributeValue(m: {"P_Name": AttributeValue(s: "gold")}),
//     "Wife Name": AttributeValue(nullValue: true),
//     "id": AttributeValue(s: "User Data"),
//     "Name": AttributeValue(s: "Ashish Raturi")
//   }
// ];

Color dyc1 = const Color(0xfff9f7f9);
