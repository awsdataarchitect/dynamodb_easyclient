import 'package:document_client/document_client.dart';

Map<String, dynamic> objToSchemaJson(TableDescription t) {
  Map<String, dynamic> schemaJson = {};
  if (t.archivalSummary != null) {
    schemaJson['ArchivalSummary'] = {
      'ArchivalBackupArn': t.archivalSummary.archivalBackupArn ?? '',
      'ArchivalDateTime':
          t.archivalSummary.archivalDateTime.toString() != 'null'
              ? t.archivalSummary.archivalDateTime.toString()
              : '',
      'ArchivalReason': t.archivalSummary.archivalReason ?? '',
    };
  }
  if (t.attributeDefinitions != null) {
    schemaJson['AttributeDefinitions'] = t.attributeDefinitions
        .map((e) => {
              "AttributeName": e.attributeName ?? '',
              "AttributeType": e.attributeType.index ?? ''
            })
        .toList();
  }
  if (t.billingModeSummary != null) {
    schemaJson['BillingModeSummary'] = {
      'BillingMode': t.billingModeSummary.billingMode.index ?? '',
      'LastUpdateToPayPerRequestDateTime': t
                  .billingModeSummary.lastUpdateToPayPerRequestDateTime
                  .toString() !=
              'null'
          ? t.billingModeSummary.lastUpdateToPayPerRequestDateTime.toString()
          : '',
    };
  }
  if (t.creationDateTime != null) {
    schemaJson['creationDateTime'] = t.creationDateTime.toString() != 'null'
        ? t.creationDateTime.toString()
        : '';
  }
  if (t.globalSecondaryIndexes != null) {
    schemaJson['GlobalSecondaryIndexes'] = t.globalSecondaryIndexes
        .map((e) => {
              "backfilling": e.backfilling ?? '',
              "indexArn": e.indexArn ?? '',
              "indexName": e.indexName ?? '',
              "indexSizeBytes": e.indexSizeBytes ?? '',
              "indexStatus": e.indexStatus.index ?? '',
              "itemCount": e.itemCount ?? '',
              "keySchema": e.keySchema
                  .map((e) => {
                        'attributeName': e.attributeName ?? '',
                        'keyType': e.keyType.index ?? '',
                      })
                  .toList(),
              "projection": {
                "nonKeyAttributes": e.projection.nonKeyAttributes ?? '',
                "projectionType": e.projection.projectionType.index ?? ''
              },
              "provisionedThroughput": {
                "lastDecreaseDateTime": e
                            .provisionedThroughput.lastDecreaseDateTime
                            .toString() !=
                        'null'
                    ? e.provisionedThroughput.lastDecreaseDateTime.toString()
                    : '',
                "lastIncreaseDateTime":
                    e.provisionedThroughput.lastIncreaseDateTime.toString() ??
                        '',
                "numberOfDecreasesToday":
                    e.provisionedThroughput.numberOfDecreasesToday ?? '',
                "readCapacityUnits":
                    e.provisionedThroughput.readCapacityUnits ?? '',
                "writeCapacityUnits":
                    e.provisionedThroughput.writeCapacityUnits ?? '',
              },
            })
        .toList();
  }
  if (t.globalTableVersion != null) {
    schemaJson['globalTableVersion'] = t.globalTableVersion ?? '';
  }
  if (t.itemCount != null) {
    schemaJson['itemCount'] = t.itemCount ?? '';
  }
  if (t.keySchema != null) {
    schemaJson['keySchema'] = t.keySchema
        .map((e) => {
              'attributeName': e.attributeName ?? '',
              'keyType': e.keyType.index ?? '',
            })
        .toList();
  }
  if (t.latestStreamArn != null) {
    schemaJson['latestStreamArn'] = t.latestStreamArn ?? '';
  }
  if (t.latestStreamLabel != null) {
    schemaJson['latestStreamLabel'] = t.latestStreamLabel ?? '';
  }
  if (t.localSecondaryIndexes != null) {
    schemaJson['localSecondaryIndexes'] = t.localSecondaryIndexes
        .map((e) => {
              "indexArn": e.indexArn ?? '',
              "indexName": e.indexName ?? '',
              "indexSizeBytes": e.indexSizeBytes ?? '',
              "itemCount": e.itemCount ?? '',
              "keySchema": e.keySchema
                  .map((e) => {
                        'attributeName': e.attributeName ?? '',
                        'keyType': e.keyType.index ?? '',
                      })
                  .toList(),
              "projection": {
                "nonKeyAttributes": e.projection.nonKeyAttributes ?? '',
                "projectionType": e.projection.projectionType.index ?? ''
              },
            })
        .toList();
  }
  if (t.provisionedThroughput != null) {
    schemaJson['provisionedThroughput'] = {
      "lastDecreaseDateTime":
          t.provisionedThroughput.lastDecreaseDateTime.toString() != 'null'
              ? t.provisionedThroughput.lastDecreaseDateTime.toString()
              : '',
      "lastIncreaseDateTime":
          t.provisionedThroughput.lastIncreaseDateTime.toString() != 'null'
              ? t.provisionedThroughput.lastIncreaseDateTime.toString()
              : '',
      "numberOfDecreasesToday":
          t.provisionedThroughput.numberOfDecreasesToday ?? '',
      "readCapacityUnits": t.provisionedThroughput.readCapacityUnits ?? '',
      "writeCapacityUnits": t.provisionedThroughput.writeCapacityUnits ?? '',
    };
  }
  if (t.replicas != null) {
    schemaJson['replicas'] = t.replicas
        .map((e) => {
              "globalSecondaryIndexes": e.globalSecondaryIndexes
                  .map((e) => {
                        'indexName': e.indexName ?? '',
                        'provisionedThroughputOverride': {
                          "readCapacityUnits": e.provisionedThroughputOverride
                                  .readCapacityUnits ??
                              ''
                        }
                      })
                  .toList(),
              "kMSMasterKeyId": e.kMSMasterKeyId ?? '',
              "provisionedThroughputOverride": {
                "readCapacityUnits":
                    e.provisionedThroughputOverride.readCapacityUnits ?? ''
              },
              "regionName": e.regionName ?? '',
              "replicaStatus": e.replicaStatus.index ?? '',
              "replicaStatusDescription": e.replicaStatusDescription ?? '',
              "replicaStatusPercentProgress":
                  e.replicaStatusPercentProgress ?? '',
            })
        .toList();
  }
  if (t.restoreSummary != null) {
    schemaJson['restoreSummary'] = {
      "restoreDateTime": t.restoreSummary.restoreDateTime.toString() != 'null'
          ? t.restoreSummary.restoreDateTime.toString()
          : '',
      "restoreInProgress": t.restoreSummary.restoreInProgress ?? '',
      "sourceBackupArn": t.restoreSummary.sourceBackupArn ?? '',
      "sourceTableArn": t.restoreSummary.sourceTableArn ?? '',
    };
  }
  if (t.sSEDescription != null) {
    schemaJson['sSEDescription'] = {
      "inaccessibleEncryptionDateTime":
          t.sSEDescription.inaccessibleEncryptionDateTime.toString() != 'null',
      "kMSMasterKeyArn": t.sSEDescription.kMSMasterKeyArn ?? '',
      "sSEType": t.sSEDescription.sSEType.index ?? '',
      "status": t.sSEDescription.status.index ?? '',
    };
  }
  if (t.streamSpecification != null) {
    schemaJson['streamSpecification'] = {
      "streamEnabled": t.streamSpecification.streamEnabled ?? '',
      "streamViewType": t.streamSpecification.streamViewType.index ?? '',
    };
  }
  if (t.tableArn != null) {
    schemaJson['tableArn'] = t.tableArn ?? '';
  }
  if (t.tableId != null) {
    schemaJson['tableId'] = t.tableId ?? '';
  }
  if (t.tableName != null) {
    schemaJson['tableName'] = t.tableName ?? '';
  }
  if (t.tableSizeBytes != null) {
    schemaJson['tableSizeBytes'] = t.tableSizeBytes ?? '';
  }
  if (t.tableStatus != null) {
    schemaJson['tableStatus'] = t.tableStatus.index ?? '';
  }

  return schemaJson;
}
