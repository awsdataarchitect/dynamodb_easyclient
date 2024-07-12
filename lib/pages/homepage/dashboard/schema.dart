import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:pretty_json/pretty_json.dart';
import "package:text/text.dart" as txt;
import 'package:highlight/languages/json.dart';
import 'package:flutter_highlight/themes/googlecode.dart';

class TableSchema extends StatefulWidget {
  final Map<String, dynamic> schemaJson;
  final double sideMenuWidth;
  const TableSchema({Key key, this.sideMenuWidth, this.schemaJson})
      : super(key: key);

  @override
  _TableSchemaState createState() => _TableSchemaState();
}

class _TableSchemaState extends State<TableSchema> {
  List<String> key = [
    '"ArchivalSummary"',
    '"ArchivalBackupArn"',
    '"ArchivalDateTime"',
    '"ArchivalReason"',
    '"AttributeDefinitions"',
    '"AttributeName"',
    '"AttributeType"',
    '"BillingModeSummary"',
    '"BillingMode"',
    '"LastUpdateToPayPerRequestDateTime"',
    '"creationDateTime"',
    '"GlobalSecondaryIndexes"',
    '"backfilling"',
    '"indexArn"',
    '"indexName"',
    '"indexSizeBytes"',
    '"itemCount"',
    '"keySchema"',
    '"attributeName"',
    '"keyType"',
    '"projection"',
    '"nonKeyAttributes"',
    '"projectionType"',
    '"provisionedThroughput"',
    '"lastDecreaseDateTime"',
    '"lastIncreaseDateTime"',
    '"numberOfDecreasesToday"',
    '"readCapacityUnits"',
    '"writeCapacityUnits"',
    '"globalTableVersion"',
    '"itemCount"',
    '"keySchema"',
    '"attributeName"',
    '"latestStreamArn"',
    '"latestStreamLabel"',
    '"localSecondaryIndexes"',
    '"indexArn"',
    '"indexName"',
    '"indexSizeBytes"',
    '"itemCount"',
    '"replicas"',
    '"provisionedThroughputOverride"',
    '"kMSMasterKeyId"',
    '"regionName"',
    '"replicaStatus"',
    '"replicaStatusDescription"',
    '"replicaStatusPercentProgress"',
    '"restoreSummary"',
    '"restoreDateTime"',
    '"restoreInProgress"',
    '"sourceBackupArn"',
    '"sourceTableArn"',
    '"sSEDescription"',
    '"inaccessibleEncryptionDateTime"',
    '"kMSMasterKeyArn"',
    '"sSEType"',
    '"status"',
    '"streamSpecification"',
    '"streamEnabled"',
    '"streamViewType"',
    '"tableArn"',
    '"tableId"',
    '"tableName"',
    '"tableSizeBytes"',
    '"tableStatus'
  ];
  txt.Text text;
  CodeController _codeController;

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

// "atom-one-light"
// 'googlecode'
  @override
  void initState() {
    final source = prettyJson(widget.schemaJson, indent: 2);
    // Instantiate the CodeController
    _codeController = CodeController(
      text: source,
      language: json,
      theme: googlecodeTheme,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - widget.sideMenuWidth,
      padding: const EdgeInsets.all(10),
      height: double.maxFinite,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
          child: CodeField(
        controller: _codeController,
        textStyle: const TextStyle(fontSize: 14, fontFamily: 'SourceCode'),
      )),
    );
  }
}
