# dynamodb_easyclient

DynamoDb Client for Mobile to manage your DynamoDb tables. Written in Flutter and uses High-level APIs for Amazon Web Services (AWS) in Dart.
We use the DocumentClient for DynamoDB Flutter package that simplifies working with items in Amazon DynamoDB by abstracting away the notion of attribute values. This abstraction annotates native Dart types supplied as input parameters, as well as converts annotated response data to native Dart types.

e.g
import 'dart:convert';

import 'package:document_client/document_client.dart';

void main() async {
  final dc = DocumentClient(region: 'eu-west-1');

  final getResponse = await dc.get(
    tableName: 'MyTable',
    key: {'Car': 'DudeWheresMyCar'},
  );

  print(jsonEncode(getResponse.item));
  // e.g. { "wheels": 24, "units": "inch" }

  final batchGetResponse = await dc.batchGet(
    requestItems: {
      'Table-1': KeysAndProjection(
        keys: [
          {
            'HashKey': 'hashkey',
            'NumberRangeKey': 1,
          }
        ],
      ),
      'Table-2': KeysAndProjection(
        keys: [
          {
            'foo': 'bar',
          }
        ],
      ),
    },
  );

  print(jsonEncode(batchGetResponse.responses));
}

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
