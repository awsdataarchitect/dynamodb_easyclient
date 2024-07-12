// import 'dart:js' as js;
// import 'dart:html' as html;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:document_client/document_client.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:dynamodb_easyclient/shared_files/toast.dart';
import 'package:flutter/material.dart';

void saveJsonFile(List<Map<String, AttributeValue>> data, String fileName,
    BuildContext context) async {
  // await FileSaver.instance.saveAs(fileName, bytes, 'json', MimeType.JSON);

  Directory downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
  final file = File('${downloadsDirectory.path}/$fileName.json');
  file.writeAsString(jsonEncode(data));

  await file.create(recursive: true);
  Uint8List bytes = await file.readAsBytes();
  await file.writeAsBytes(bytes);
  showToast('Save File', context);
}
