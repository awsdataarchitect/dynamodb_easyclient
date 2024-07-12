# dynamodb_easyclient

DynamoDb Client for Mobile to manage your DynamoDb tables. Written in Flutter and uses High-level APIs for Amazon Web Services (AWS) in Dart.
We use the DocumentClient for DynamoDB Flutter package that simplifies working with items in Amazon DynamoDB by abstracting away the notion of attribute values. This abstraction annotates native Dart types supplied as input parameters, as well as converts annotated response data to native Dart types.

# Usage:

This below example demonstrates how to perform basic read operations on Amazon DynamoDB using Dart, showing both single and batch retrievals. The snippet includes two primary operations: a single get request and a batchGet request.

- 1. Importing Dependencies
import 'dart:convert';

import 'package:document_client/document_client.dart';

dart:convert: Provides encoding and decoding for JSON.
document_client: A package that simplifies interactions with DynamoDB.

- 2. Main Function
void main() async { 

  final dc = DocumentClient(region: 'eu-west-1');

The main function is declared as async to handle asynchronous operations.
DocumentClient is initialized with the specified AWS region (eu-west-1).

- 3. Single Get Request
final getResponse = await dc.get(

  tableName: 'MyTable', 

  key: {'Car': 'DudeWheresMyCar'},

);

print(jsonEncode(getResponse.item)); // e.g. { "wheels": 24, "units": "inch" }

A single get request is made to the DynamoDB table named MyTable.
The request fetches an item with the primary key {'Car': 'DudeWheresMyCar'}.
The response item is printed in JSON format. 
An example output could be {"wheels": 24, "units": "inch"}.

- 4. Batch Get Request
final batchGetResponse = await dc.batchGet(

  requestItems: {

    'Table-1': KeysAndProjection(

      keys: [

        {'HashKey': 'hashkey', 'NumberRangeKey': 1},

      ],

    ),

    'Table-2': KeysAndProjection(

      keys: [

        {'foo': 'bar'},

      ],

    ),

  },

);

print(jsonEncode(batchGetResponse.responses));

A batchGet request retrieves items from multiple tables (Table-1 and Table-2).
For Table-1, it fetches items using keys {'HashKey': 'hashkey', 'NumberRangeKey': 1}.
For Table-2, it fetches items using keys {'foo': 'bar'}.
The response, which includes items from both tables, is printed in JSON format.

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
