import 'dart:convert';
import 'package:code_text_field/code_text_field.dart';
import 'package:dynamodb_easyclient/pages/homepage/dashboard/dashboard_table.dart';
import 'package:dynamodb_easyclient/shared_files/toast.dart';
import 'package:highlight/languages/json.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:flutter_highlight/themes/googlecode.dart';

class JsonEditor extends StatefulWidget {
  final Function editUpdateRowData;
  final bool addRowEditor;
  final bool multipleItems;
  final String initialData;
  const JsonEditor(
      {Key key,
      this.addRowEditor,
      this.editUpdateRowData,
      this.multipleItems,
      this.initialData})
      : super(key: key);

  @override
  _JsonEditorState createState() => _JsonEditorState();
}

class _JsonEditorState extends State<JsonEditor> {
  final invalidJson = ValueNotifier<bool>(false);
  CodeController _codeController;
  String rawCode;
  // final pageFontStyle =
  //     GoogleFonts.poppins(color: Colors.black, fontSize: 12, letterSpacing: 2);
  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // Instantiate the CodeController
    String st;
    if (widget.initialData != null && widget.multipleItems) {
      st = widget.initialData;
    } else {
      if (widget.addRowEditor) {
        st = """{
  "id": {
    "S":""
  }
}""";
      } else {
        Map<String, dynamic> d = {
          for (var k in selectedRowData.value.keys)
            k: selectedRowData.value[k].toJson()
        };
        st = prettyJson(d, indent: 2);
      }
    }
// json.

    _codeController =
        CodeController(text: st, language: json, theme: googlecodeTheme);

    _codeController.addListener(checkJsonIsValid);
    super.initState();
  }

  checkJsonIsValid() {
    try {
      jsonDecode(_codeController.rawText);
      invalidJson.value = false;
    } catch (e) {
      invalidJson.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: invalidJson,
        builder: (_, showInvalidJsonError, __) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.black),
                title: Text(widget.addRowEditor ? 'Add Row' : 'Edit Row',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                actions: [
                  SizedBox(
                    height: 40,
                    child: TextButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10)),
                            backgroundColor: showInvalidJsonError
                                ? MaterialStateProperty.all(Colors.grey)
                                : MaterialStateProperty.all(Colors.blue)),
                        onPressed: () {
                          widget.editUpdateRowData(
                              jsonDecode(_codeController.rawText),
                              multipleItems: widget.multipleItems);
                        },
                        child: Row(
                          children: const [
                            Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Save Item',
                                style: TextStyle(color: Colors.white)),
                          ],
                        )),
                  ),
                ],
              ),
              body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: CodeField(
                          controller: _codeController,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    SizedBox(
                      height: 50,

                      // color: Colors.red,
                      child: Wrap(
                        spacing: 10, runSpacing: 10,
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,

                        // mainAxisAlignment: MainAxisAlignment.end,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 40,
                            child: TextButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          side: BorderSide(
                                              color: Colors.grey[300]))),
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10)),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white)),
                              onPressed: () {
                                if (!showInvalidJsonError) {
                                  String pt = prettyJson(
                                      jsonDecode(_codeController.rawText));
                                  // var encoder =
                                  //     const JsonEncoder.withIndent("     ");
                                  // String pt = encoder.convert(jsonDecode(
                                  //     '{' + _codeController.rawText + '}'));
                                  // pt = pt.substring(1, pt.length - 1);
                                  _codeController.text = pt;
                                  setState(() {});
                                }
                              },
                              child: Text('Prettify JSON',
                                  style: TextStyle(
                                      color: showInvalidJsonError
                                          ? Colors.grey
                                          : Colors.black)),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            height: 40,
                            width: 160,
                            child: TextButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            side: BorderSide(
                                                color: Colors.grey[300]))),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10)),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.white)),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: _codeController.rawText));
                                  showToast('Copied', context);
                                },
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.copy,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('Copy to clipboard',
                                        style: TextStyle(color: Colors.black)),
                                  ],
                                )),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          if (showInvalidJsonError)
                            SizedBox(
                              width: 140,
                              child: Row(
                                children: const [
                                  Icon(
                                    FontAwesomeIcons.exclamationTriangle,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Invalid Json',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.red)),
                                ],
                              ),
                            ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    )
                  ],
                ),
              ));
        });
  }
}
