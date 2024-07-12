import 'dart:convert';
import 'dart:io';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:document_client/document_client.dart';
import 'package:dynamodb_easyclient/models/app_user.dart';
import 'package:dynamodb_easyclient/pages/homepage/dashboard/region_table_tile.dart';
import 'package:dynamodb_easyclient/pages/homepage/dashboard/schema.dart';
import 'package:dynamodb_easyclient/pages/homepage/dashboard/table_filters.dart';
import 'package:dynamodb_easyclient/pages/homepage/dashboard/text_editor.dart';
import 'package:dynamodb_easyclient/pages/payment/payment.dart';
import 'package:dynamodb_easyclient/shared_files/method/attribute_value_to_string.dart';
import 'package:dynamodb_easyclient/shared_files/method/obj_to_schema_json.dart';
import 'package:dynamodb_easyclient/shared_files/method/save_json_file.dart';
import 'package:dynamodb_easyclient/shared_files/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dynamodb_easyclient/shared_files/data/constant_data.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'keys_id_dashboard.dart';
import 'package:file_picker/file_picker.dart';

class DashboardTable extends StatefulWidget {
  final AppUserData apiUserData;
  final String keyId;
  final String keySecret;
  final Map<String, List<String>> activeRegionTableLst;
  final Map<String, List<String>> notactiveRegionTableLst;
  final Function loadDynamodb;
  const DashboardTable(
      {Key key,
      this.keyId,
      this.keySecret,
      this.activeRegionTableLst,
      this.notactiveRegionTableLst,
      this.apiUserData,
      this.loadDynamodb})
      : super(key: key);

  @override
  _DashboardTableState createState() => _DashboardTableState();
}

final showEditor = ValueNotifier<bool>(false);
final showEditRowBtn = ValueNotifier<bool>(false);
final reloadTableData = ValueNotifier<bool>(false);
final selectedRowData = ValueNotifier<Map<String, AttributeValue>>({});

List<Map<String, AttributeValue>> selectedTableItemListData = [];

List<String> hideCloumnNames = [];
double sideMenuWidth = 190;

class _DashboardTableState extends State<DashboardTable> {
  DataGridController controller;
  DocumentClient _documentClient;
  Map<String, double> columnWidths = {};
  Map<String, dynamic> schemaJson;
  // Map<String, String> selectedTableRegionName = {};
  Map<String, bool> showTable = {for (var v in dynamomDbRegionLst) v: true};
  String selectedRegionName = '', selectedTableName = '';
  Map<String, List<String>> filterdActiveRegionTableLst = {};
  User user;
  bool showingSideMenu = true,
      showingKeyIdsSettings = false,
      loadingTable = false,
      showingSchema = false,
      filterActive = true,
      addRowEditor = false,
      selectedRowExportActive = false;
  final CustomPopupMenuController _controller = CustomPopupMenuController();
  final CustomPopupMenuController _controller2 = CustomPopupMenuController();
  final _scrollController = ScrollController();

  int totalFreeTrialDays = 0;
  @override
  void initState() {
    controller = DataGridController();
    showEditor.value = false;
    sideMenuWidth = 190;
    selectedTableItemListData = [];
    hideCloumnNames = [];
    showEditor.value = false;
    showEditRowBtn.value = false;
    reloadTableData.value = false;
    selectedRowData.value = {};

    super.initState();
  }

  void loadTableFilter(
      String filterExpression,
      Map<String, String> expressionAttributeNames,
      Map<String, AttributeValue> expressionAttributeValues) async {
    setState(() => loadingTable = true);
    if (filterExpression.isNotEmpty) {
      try {
        ScanOutput d = await _documentClient.dynamoDB.scan(
            tableName: selectedTableName,
            filterExpression: filterExpression,
            expressionAttributeNames: expressionAttributeNames,
            expressionAttributeValues: expressionAttributeValues.isEmpty
                ? null
                : expressionAttributeValues);

        selectedTableItemListData = [];

        for (Map<String, AttributeValue> item in d.items) {
          selectedTableItemListData
              .add({for (String s in item.keys) s: item[s]});
        }
        columnWidths = {
          for (var i in headerNameLst(selectedTableItemListData)) i: 200.0
        };
      } catch (e) {
        // print('load filter error;');
        // print(e.toString());
      }
    } else {
      loadTableItem(reloadSameTable: true);
    }

    setState(() => loadingTable = false);
  }

  void loadTableItem(
      {String regionName,
      String tableName,
      bool reloadSameTable = false}) async {
    setState(() => loadingTable = true);

    if (!reloadSameTable) {
      _documentClient = DocumentClient(
          region: reloadSameTable ? selectedRegionName : regionName,
          credentials: AwsClientCredentials(
              accessKey: widget.keyId, secretKey: widget.keySecret));
    }

    try {
      ScanOutput d = await _documentClient.dynamoDB
          .scan(tableName: reloadSameTable ? selectedTableName : tableName);

      selectedTableItemListData = [];

      for (Map<String, AttributeValue> item in d.items) {
        selectedTableItemListData.add({for (String s in item.keys) s: item[s]});
      }
      columnWidths = {
        for (var i in headerNameLst(selectedTableItemListData)) i: 200.0
      };
    } catch (e) {}
    reloadTableData.value = false;
    getSchema();
    setState(() => loadingTable = false);
  }

  deleteRow(Map<String, AttributeValue> selRowData) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              width: 450,
              height: 250,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delete Row',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                          hoverColor: Colors.white,
                          splashRadius: 1,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            FontAwesomeIcons.times,
                            size: 18,
                          ))
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    color: Colors.red[50],
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.exclamationTriangle,
                            size: 14, color: Colors.red[900]),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                              'This will delete the Row (id : ${attributeValueToString(selRowData['id'])}) form the table',
                              style: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      SizedBox(
                        width: 75,
                        height: 30,
                        child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              )),
                            ),
                            child: const Text(
                              'Cancel',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            )),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 75,
                        height: 30,
                        child: TextButton(
                            onPressed: () {
                              // print(selRowData);
                              _documentClient.dynamoDB.deleteItem(
                                key: {'id': selRowData['id']},
                                tableName: 'asdf',
                              );
                              loadTableItem(reloadSameTable: true);
                              selectedRowData.value = {};
                              showEditRowBtn.value = false;

                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side:
                                          BorderSide(color: Colors.red[900]))),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                return Colors.red[900];
                              }),
                            ),
                            child: const Text(
                              'Delete',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  void getSchema() async {
    DescribeTableOutput res =
        await _documentClient.dynamoDB.describeTable(tableName: 'asdf');
    var t = res.table;

    schemaJson = objToSchemaJson(t);

    setState(() {});
  }

  sideMenu() {
    return Container(
      width: 40,
      color: dyc1,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          IconButton(
              onPressed: () {
                setState(() {
                  showingSideMenu = !showingSideMenu;

                  showingKeyIdsSettings = false;
                  if (showingSideMenu) {
                    sideMenuWidth = 190;
                  } else {
                    sideMenuWidth = 50;
                  }
                });
              },
              icon: Icon(
                Icons.table_chart,
                size: 18,
                color: showingSideMenu ? Colors.blue : Colors.black,
              )),
          const SizedBox(
            height: 20,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  sideMenuWidth = 50;
                  showingSideMenu = false;

                  showingKeyIdsSettings = true;
                });
              },
              icon: Icon(Icons.vpn_key,
                  color: showingKeyIdsSettings ? Colors.blue : Colors.black,
                  size: 18)),
        ],
      ),
    );
  }

  void editUpdateRowData(dynamic rawText, {bool multipleItems = false}) async {
    if (multipleItems) {
      List jsonData = rawText;
      print(jsonData.length);
      for (var d in jsonData) {
        print(d);
        editUpdateRowData(d, multipleItems: false);
      }
    } else {
      print('updaing data:$rawText');
      dynamic json = rawText;
      // jsonDecode(rawText);
      print('yo1');
      Map<String, AttributeValueUpdate> attJson = {
        for (var k in json.keys)
          if (k != 'id')
            k: AttributeValueUpdate(
                action: AttributeAction.put,
                value: AttributeValue.fromJson(json[k]))
      };

      try {
        await _documentClient.dynamoDB.updateItem(
            key: {'id': AttributeValue.fromJson(json['id'])},
            tableName: selectedTableName,
            attributeUpdates: attJson);
        loadTableItem(reloadSameTable: true);
        showEditor.value = false;
        if (addRowEditor) {
          setState(() {
            addRowEditor = false;
          });
        }
      } catch (e) {
        showToast(e.toString(), context);
      }
    }
    showToast('Item Updated', context, center: true);
  }

  filterTable(String query) {
    filterdActiveRegionTableLst = {};

    for (int i = 0; i < widget.activeRegionTableLst.keys.length; i++) {
      List<String> tfound = [];
      String r = widget.activeRegionTableLst.keys.elementAt(i);
      List<String> t = widget.activeRegionTableLst[r];
      for (int j = 0; j < t.length; j++) {
        if (t.elementAt(j).toLowerCase().contains(query)) {
          tfound.add(t.elementAt(j));
        }
      }

      filterdActiveRegionTableLst[r] = tfound;
    }
    setState(() {});
  }

  calculateTrialTimeLeft(DateTime acCreateTime) {
    int difference =
        totalFreeTrialDays - (DateTime.now().difference(acCreateTime).inDays);
    totalFreeTrialDays = difference.isNegative ? 0 : difference;
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    // print(widget.activeRegionTableLst);
    calculateTrialTimeLeft(user.metadata.creationTime);

    if (filterdActiveRegionTableLst != widget.activeRegionTableLst) {
      filterdActiveRegionTableLst = widget.activeRegionTableLst;
    }

    return ValueListenableBuilder<bool>(
        valueListenable: reloadTableData,
        builder: (_, loadTable, __) {
          if (loadTable &&
              selectedRegionName.isNotEmpty &&
              selectedTableName.isNotEmpty) {
            loadTableItem(reloadSameTable: true);
          }
          return ValueListenableBuilder<bool>(
              valueListenable: showEditor,
              builder: (_, editorActive, __) {
                return ValueListenableBuilder<Map<String, AttributeValue>>(
                    valueListenable: selectedRowData,
                    builder: (_, selRowData, __) {
                      return Stack(
                        children: [
                          Container(
                            color: dyc1,
                            child: Row(
                              children: [
                                Container(
                                  height: double.maxFinite,
                                  margin: EdgeInsets.only(
                                      top: selectedRegionName.isNotEmpty &&
                                              !showingKeyIdsSettings &&
                                              selectedTableName.isNotEmpty
                                          ? 40
                                          : 0),
                                  width: sideMenuWidth,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]),
                                    color:
                                        showingSideMenu ? Colors.white : dyc1,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      sideMenu(),
                                      if (showingSideMenu)
                                        Column(
                                          children: [
                                            Flexible(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children:
                                                        // dynamomDbRegionLst
                                                        //         .map((e) =>
                                                        //             regionTile(
                                                        //                 e,
                                                        //                 widget
                                                        //                     .activeRegionTableLst))
                                                        //         .toList() +
                                                        filterdActiveRegionTableLst
                                                                .keys
                                                                .map((k) =>
                                                                    regionTile(
                                                                        k,
                                                                        filterdActiveRegionTableLst))
                                                                .toList() +
                                                            widget
                                                                .notactiveRegionTableLst
                                                                .keys
                                                                .map((k) =>
                                                                    regionTile(
                                                                        k,
                                                                        widget
                                                                            .notactiveRegionTableLst))
                                                                .toList()),
                                              ),
                                            ),
                                            Container(
                                                width: sideMenuWidth - 42,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[300]),
                                                    color: Colors.white),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(width: 5),
                                                    const Icon(
                                                        CupertinoIcons.search,
                                                        color: Colors.grey,
                                                        size: 15),
                                                    const SizedBox(width: 5),
                                                    Flexible(
                                                      child: TextField(
                                                        onChanged: (val) {
                                                          filterTable(val);
                                                        },
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                        decoration: const InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    bottom: 15),
                                                            hintText:
                                                                'Fliter tables...',
                                                            border: InputBorder
                                                                .none),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                  ],
                                                ))
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                if (showingKeyIdsSettings)
                                  KeyIdsDashboard(
                                    apiUserData: widget.apiUserData,
                                    loadDynamodb: widget.loadDynamodb,
                                  ),
                                if (!showingKeyIdsSettings)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (selectedTableName.isNotEmpty)
                                        Container(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              sideMenuWidth,
                                          decoration: const BoxDecoration(
                                              // border: Border.all(color: Colors.grey[300]),
                                              color: Colors.white),
                                        ),
                                      if (!showingSchema &&
                                          filterActive &&
                                          selectedTableName.isNotEmpty)
                                        TableFilter(
                                            loadTableFilter: loadTableFilter),
                                      if (selectedTableName.isEmpty)
                                        Expanded(
                                            child: Container(
                                                width: MediaQuery.of(
                                                            context)
                                                        .size
                                                        .width -
                                                    sideMenuWidth,
                                                color: Colors.white,
                                                child: totalFreeTrialDays ==
                                                            0 &&
                                                        !widget.apiUserData
                                                            .freeUser &&
                                                        !widget.apiUserData
                                                            .subIsActive &&
                                                        !widget.apiUserData
                                                            .stirpeSubIsActive
                                                    ? trialIsOver()
                                                    : const Center(
                                                        child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.0),
                                                        child: Text(
                                                            'No Table is selected',
                                                            style: TextStyle(
                                                                fontSize: 20)),
                                                      )))),
                                      if (loadingTable)
                                        Expanded(
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    sideMenuWidth,
                                                color: Colors.white,
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      CupertinoActivityIndicator(),
                                                      SizedBox(height: 10),
                                                      Text('Loading Table...',
                                                          style: TextStyle(
                                                              fontSize: 18))
                                                    ],
                                                  ),
                                                ))),
                                      if (selectedTableName.isNotEmpty &&
                                          !showingSchema &&
                                          !loadingTable)
                                        Expanded(
                                          child: Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                sideMenuWidth,
                                            child: SfDataGrid(
                                                showCheckboxColumn:
                                                    selectedRowExportActive
                                                        ? true
                                                        : false,
                                                selectionMode:
                                                    !selectedRowExportActive
                                                        ? SelectionMode.single
                                                        : SelectionMode
                                                            .multiple,
                                                checkboxColumnSettings:
                                                    const DataGridCheckboxColumnSettings(
                                                        backgroundColor:
                                                            Colors.blue),
                                                controller: controller,
                                                allowColumnsResizing: true,
                                                allowTriStateSorting: true,
                                                allowSorting: true,
                                                columnWidthMode:
                                                    ColumnWidthMode.fill,
                                                isScrollbarAlwaysShown: true,
                                                highlightRowOnHover: true,
                                                navigationMode:
                                                    GridNavigationMode.row,
                                                columnResizeMode:
                                                    ColumnResizeMode.onResize,
                                                columnWidthCalculationRange:
                                                    ColumnWidthCalculationRange
                                                        .visibleRows,
                                                gridLinesVisibility:
                                                    GridLinesVisibility.none,
                                                headerGridLinesVisibility:
                                                    GridLinesVisibility.both,
                                                headerRowHeight: 30,
                                                rowHeight: 30,
                                                onColumnResizeUpdate:
                                                    (details) {
                                                  setState(() {
                                                    columnWidths[details.column
                                                            .columnName] =
                                                        details.width;
                                                  });
                                                  return true;
                                                },
                                                onCellTap:
                                                    (DataGridCellTapDetails d) {
                                                  // _showPopupMenu(d.globalPosition, context);

                                                  // showEditRowBtn.value =
                                                  //     d.rowColumnIndex.rowIndex - 1;
                                                  // setState(() {});
                                                },
                                                source: TableItemDataSource(
                                                    controller, context),
                                                columns: headerNameLst(
                                                        selectedTableItemListData)
                                                    .map((e) => GridColumn(
                                                        columnName: e,
                                                        width: columnWidths[e],
                                                        minimumWidth: 25,
                                                        maximumWidth: 130,
                                                        columnWidthMode:
                                                            ColumnWidthMode
                                                                .fill,
                                                        label: Container(
                                                            padding: const EdgeInsets.all(6.0),
                                                            alignment: Alignment.centerLeft,
                                                            color: dyc1,
                                                            child: Text(
                                                              e,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ))))
                                                    .toList()),
                                          ),
                                        ),
                                      if (showingSchema)
                                        Flexible(
                                            child: TableSchema(
                                                sideMenuWidth: sideMenuWidth,
                                                schemaJson: schemaJson)),
                                      if (selectedTableName.isNotEmpty)
                                        bottomBar(selRowData)
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          if (selectedRegionName.isNotEmpty &&
                              !showingKeyIdsSettings &&
                              selectedTableName.isNotEmpty)
                            header(),
                          if (editorActive)
                            GestureDetector(
                              onTap: () {
                                showEditor.value = false;
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                color: Colors.black38,
                                alignment: Alignment.center,
                              ),
                            ),
                          // if (editorActive)
                          //   Align(
                          //     alignment: Alignment.center,
                          //     child: JsonEditor(
                          //         addRowEditor: addRowEditor,
                          //         editUpdateRowData: editUpdateRowData),
                          //   ),
                        ],
                      );
                    });
              });
        });
    // });
  }

  trialIsOver() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Your trial is over',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: const Text(
              'Thanks for using DynamoDb EasyClient. Unfortunately, your trial is already over. Consider purchasing a subscription for continue using our services.',
              textAlign: TextAlign.center),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubscriptionPaymentPage(
                          previousPurchase: widget.apiUserData.purchaseDetails,
                          goldSubscriptionId:
                              widget.apiUserData.sharedDbData.goldSubId,
                          silverSubscriptionId:
                              widget.apiUserData.sharedDbData.silverSubId)));
            },
            child: const Text('Buy Now'))
      ],
    );
  }

  bottomBar(selRowData) {
    return ValueListenableBuilder<bool>(
        valueListenable: showEditRowBtn,
        builder: (_, editDeleteBtnIsActive, __) {
          return selectedRowExportActive
              ? Container(
                  width: MediaQuery.of(context).size.width - sideMenuWidth,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300])),
                  height: 40,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: SingleChildScrollView(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 110,
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRowExportActive = false;
                                    loadTableItem(reloadSameTable: true);
                                  });
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.grey[300]))),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                    return Colors.white;
                                  }),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.cancel,
                                        size: 15, color: Colors.red),
                                    SizedBox(width: 5),
                                    Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                )),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 150,
                            child: TextButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.grey[300]))),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                    return Colors.white;
                                  }),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.arrow_upward,
                                        size: 15, color: Colors.green),
                                    SizedBox(width: 5),
                                    Text(
                                      'Export Selected',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                )),
                          ),
                        ]),
                  ))
              : Container(
                  width: MediaQuery.of(context).size.width - sideMenuWidth,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300])),
                  height: 40,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 110,
                        child: TextButton(
                            onPressed: () {
                              if (showingSchema) {
                                setState(() {
                                  showingSchema = false;
                                });
                              }
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      side:
                                          BorderSide(color: Colors.grey[300]))),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                if (!showingSchema) return Colors.grey[200];

                                return Colors.white;
                              }),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.table_chart,
                                    size: 15, color: Colors.black),
                                SizedBox(width: 5),
                                Text(
                                  'Data',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        width: 110,
                        child: TextButton(
                            onPressed: () {
                              if (!showingSchema) {
                                setState(() {
                                  showingSchema = true;
                                });
                              }
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      side:
                                          BorderSide(color: Colors.grey[300]))),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                if (showingSchema) return Colors.grey[200];

                                return Colors.white;
                              }),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.schema_sharp,
                                    size: 15, color: Colors.black),
                                SizedBox(width: 5),
                                Text(
                                  'Schema',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ],
                            )),
                      ),
                      if (editDeleteBtnIsActive && !showingSchema)
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1),
                      if (editDeleteBtnIsActive && !showingSchema)
                        SizedBox(
                          width: 110,
                          child: TextButton(
                              onPressed: () {
                                if (addRowEditor) {
                                  setState(() {
                                    addRowEditor = false;
                                  });
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => JsonEditor(
                                            addRowEditor: addRowEditor,
                                            editUpdateRowData:
                                                editUpdateRowData)));

                                // showEditor.value = true;
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.grey[300]))),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                  return const Color(0xff2f84e9);
                                }),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.edit,
                                      size: 15, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text(
                                    'Row',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              )),
                        ),
                      if (editDeleteBtnIsActive && !showingSchema)
                        SizedBox(
                          width: 110,
                          child: TextButton(
                              onPressed: () {
                                deleteRow(selRowData);
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.red[300]))),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                  return Colors.red;
                                }),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.delete_forever,
                                      size: 15, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text(
                                    'Row',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              )),
                        ),

                      SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                      // SizedBox(width: 30),
                      if (!showingSchema)
                        SizedBox(
                          width: 110,
                          child: TextButton(
                              onPressed: () {
                                if (!addRowEditor) {
                                  setState(() {
                                    addRowEditor = true;
                                  });
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => JsonEditor(
                                            addRowEditor: addRowEditor,
                                            editUpdateRowData:
                                                editUpdateRowData)));
                                // showEditor.value = true;
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.grey[300]))),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                  return Colors.white;
                                }),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add,
                                      size: 15, color: Colors.black),
                                  SizedBox(width: 5),
                                  Text(
                                    'Row',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                ],
                              )),
                        ),
                      const SizedBox(width: 10),
                      if (!showingSchema)
                        SizedBox(
                          width: 110,
                          child: TextButton(
                              onPressed: () async {
                                FilePickerResult result =
                                    await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['json'],
                                        allowMultiple: false);

                                if (result.count != 0) {
                                  String fileData =
                                      await File(result.files.first.path)
                                          .readAsString();

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => JsonEditor(
                                              addRowEditor: addRowEditor,
                                              initialData: fileData,
                                              multipleItems: true,
                                              editUpdateRowData:
                                                  editUpdateRowData)));
                                }
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.grey[300]))),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                  return Colors.white;
                                }),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.arrow_downward,
                                      size: 15, color: Colors.black),
                                  SizedBox(width: 5),
                                  Text(
                                    'Import',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                ],
                              )),
                        ),
                      const SizedBox(width: 10),
                      if (!showingSchema) exportBtn(),

                      const SizedBox(width: 10)
                    ],
                  ),
                );
        });
  }

  exportBtn() {
    return CustomPopupMenu(
        child: SizedBox(
          width: 110,
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]),
                  color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.arrow_upward, size: 15, color: Colors.black),
                  SizedBox(width: 5),
                  Text(
                    'Export',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              )),
        ),
        barrierColor: Colors.transparent,
        pressType: PressType.singleClick,
        verticalMargin: -10,
        controller: _controller2,
        menuBuilder: () => ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(2),
                color: Colors.grey[100],
              ),
              // padding: EdgeInsets.all(8),
              height: 85,
              width: 140,
              child: IntrinsicWidth(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // SizedBox(height: 10),
                        // GestureDetector(
                        //   behavior: HitTestBehavior.translucent,
                        //   onTap: () {
                        //     setState(() {
                        //       selectedRowExportActive = true;
                        //     });
                        //     _controller2.hideMenu();
                        //   },
                        //   child: Expanded(
                        //     child: Container(
                        //       decoration: BoxDecoration(
                        //         border: Border.all(color: Colors.grey),
                        //         borderRadius: BorderRadius.circular(2),
                        //         color: Colors.white,
                        //       ),
                        //       alignment: Alignment.center,
                        //       padding: EdgeInsets.symmetric(vertical: 5),
                        //       child: Text(
                        //         'Selection',
                        //         style: TextStyle(
                        //             color: Colors.black,
                        //             fontSize: 12,
                        //             fontWeight: FontWeight.w500),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            saveJsonFile(selectedTableItemListData,
                                selectedTableName, context);
                            _controller2.hideMenu();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: const Text(
                              'Current Results',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            saveJsonFile(selectedTableItemListData,
                                selectedTableName, context);
                            _controller2.hideMenu();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: const Text(
                              'Whole Table',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ]),
                ),
              ),
            )));
  }

  tablePath() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.lightGreen[100],
          borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(5),
      child: Text(
        selectedRegionName + ' / ' + selectedTableName,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
    );
  }

  Widget header() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: dyc1,
          border: Border.all(color: Colors.grey[300]),
        ),
        width: MediaQuery.of(context).size.width - 1,
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const SizedBox(
              width: 10,
            ),
            if (!showingKeyIdsSettings) tablePath(),
            const SizedBox(
              width: 10,
            ),
            if (!showingKeyIdsSettings && !showingSchema)
              GestureDetector(
                onTap: () {
                  loadTableItem(reloadSameTable: true);
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[200]),
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.refresh, size: 15, color: Colors.black),
                        SizedBox(width: 5),
                        Text(
                          'Table',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    )),
              ),
            const SizedBox(width: 20),
            if (!showingSchema && !showingKeyIdsSettings) columnsShowMenuBtn(),
            const SizedBox(width: 10),
            if (selectedTableName.isNotEmpty &&
                !showingSchema &&
                !showingKeyIdsSettings)
              SizedBox(
                width: 110,
                height: 32,
                child: TextButton(
                    onPressed: () {
                      setState(() => filterActive = !filterActive);
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey[300]))),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (showingSchema) return Colors.grey[200];
                        if (filterActive) return Colors.grey[350];
                        return Colors.white;
                      }),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.filter_alt_rounded,
                            size: 15, color: Colors.black),
                        SizedBox(width: 5),
                        Text(
                          'Filter',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    )),
              ),
            const SizedBox(width: 30),
          ],
        ),
      ),
    );
  }

  columnsShowMenuBtn() {
    List<String> colunms =
        headerNameLst(selectedTableItemListData, showAllColumns: true);
    return CustomPopupMenu(
      child: SizedBox(
        width: 110,
        height: 32,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]),
                color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.view_column_outlined, size: 18, color: Colors.black),
                SizedBox(width: 5),
                Text(
                  'Columns',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            )),
      ),
      barrierColor: Colors.transparent,
      pressType: PressType.singleClick,
      verticalMargin: -10,
      controller: _controller,
      menuBuilder: () => ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(2),
            color: Colors.grey[100],
          ),
          // padding: EdgeInsets.all(8),
          height: 200,
          child: IntrinsicWidth(
            child: Scrollbar(
              controller: _scrollController, // <---- Here, the controller
              isAlwaysShown: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Show table columns',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                hideCloumnNames = [];
                                setState(() {});
                                _controller.hideMenu();
                                _controller.showMenu();
                              },
                              child: const Text(
                                'Select all /',
                                style: TextStyle(
                                  // color: dyC7,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                                onTap: () {
                                  hideCloumnNames = colunms;

                                  setState(() {});
                                  _controller.hideMenu();
                                  _controller.showMenu();
                                },
                                child: const Text(
                                  'Deselect all',
                                  style: TextStyle(
                                    // color: dyC7,
                                    fontSize: 10,
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 5),
                        for (int i = 0; i < colunms.length; i++)
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              if (hideCloumnNames
                                  .contains(colunms.elementAt(i))) {
                                hideCloumnNames.remove(colunms.elementAt(i));
                              } else {
                                hideCloumnNames.add(colunms.elementAt(i));
                              }
                              setState(() {});
                              _controller.hideMenu();
                              _controller.showMenu();
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    hideCloumnNames
                                            .contains(colunms.elementAt(i))
                                        ? Icons.check_box_outline_blank
                                        : Icons.check_box,
                                    size: 15,
                                    // color: dyC7,
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Text(
                                        colunms.elementAt(i),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                      ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget regionTile(k, Map<String, List<String>> currentRegionLst) {
    // print(currentRegionLst[k]);
    // if (currentRegionLst.isNotEmpty && currentRegionLst[k].isNotEmpty) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            if (showTable[k]) {
              showTable[k] = false;
            } else {
              showTable[k] = true;
            }
            // print('sdf');
            setState(() {});
          },
          child: SizedBox(
            width: sideMenuWidth - 60,
            // height: 25,
            // padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            child: Row(
              children: [
                Icon(
                  !showTable[k]
                      ? Icons.keyboard_arrow_right
                      : Icons.keyboard_arrow_down_outlined,
                  size: 18,
                ),
                Text(k,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
        if (showTable[k])
          for (var e in currentRegionLst[k])
            RegionTableTile(
              showDeleteIcon: true,
              isSelectedTable:
                  selectedRegionName == k && selectedTableName == e,
              tableName: e,
              onTap: () {
                if (totalFreeTrialDays == 0 &&
                    !widget.apiUserData.freeUser &&
                    !widget.apiUserData.subIsActive &&
                    !widget.apiUserData.stirpeSubIsActive) {
                } else {
                  selectedRegionName = k;
                  selectedTableName = e;
                  showingSchema = false;
                  // sideMenuWidth = 50;
                  loadTableItem(regionName: k, tableName: e);
                  // setState(() {});
                }
              },
              onTapDelete: () {
                if (totalFreeTrialDays == 0 &&
                    !widget.apiUserData.freeUser &&
                    !widget.apiUserData.subIsActive &&
                    !widget.apiUserData.stirpeSubIsActive) {
                } else {
                  deleteTableDialog(e, k);
                }
              },
            ),
        //   onHover: (e) {},
      ],
    );
    // }
  }
  // return Padding(
  //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
  //   child: Row(
  //     children: [
  //       Icon(Icons.info_outline, color: Colors.grey, size: 15),
  //       SizedBox(
  //         width: 5,
  //       ),
  //       Text('Loading region $k failed', style: TextStyle(fontSize: 10)),
  //       SizedBox(
  //         width: 20,
  //       ),
  //     ],
  //   ),
  // );

  deleteTableDialog(String table, String region) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          bool deletingTable = false;
          return StatefulBuilder(builder: (context, setState2) {
            return Dialog(
              child: Container(
                width: 450,
                height: 230,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                child: deletingTable
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CupertinoActivityIndicator(),
                          SizedBox(height: 20),
                          Text('Deleting Table, please wait...')
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Delete Table',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                  hoverColor: Colors.white,
                                  splashRadius: 1,
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    FontAwesomeIcons.times,
                                    size: 18,
                                  ))
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            color: Colors.red[50],
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(FontAwesomeIcons.exclamationTriangle,
                                    size: 14, color: Colors.red[900]),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 320,
                                  child: Text(
                                      'This will delete the Table ($table) form the region ($region).',
                                      // textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.red[900],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Row(
                            children: [
                              const Expanded(child: SizedBox()),
                              SizedBox(
                                width: 75,
                                height: 30,
                                child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      )),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    )),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 75,
                                height: 30,
                                child: TextButton(
                                    onPressed: () async {
                                      setState2(() {
                                        deletingTable = true;
                                      });

                                      await DocumentClient(
                                              region: region,
                                              credentials: AwsClientCredentials(
                                                  accessKey: widget.keyId,
                                                  secretKey: widget.keySecret))
                                          .dynamoDB
                                          .deleteTable(tableName: table);

                                      selectedTableItemListData = [];
                                      selectedRegionName = '';
                                      selectedTableName = '';
                                      columnWidths = {};
                                      schemaJson = {};
                                      showEditor.value = false;
                                      //remove table form all region table list
                                      List<String> tlist =
                                          filterdActiveRegionTableLst[region];
                                      tlist.remove(table);

                                      filterdActiveRegionTableLst[region] =
                                          tlist;
                                      //remove table form filtered table list
                                      List<String> tlist2 =
                                          filterdActiveRegionTableLst[region];
                                      tlist2.remove(table);

                                      filterdActiveRegionTableLst[region] =
                                          tlist2;
                                      showToast('Table Deleted', context);
                                      setState2(() {
                                        deletingTable = false;
                                      });
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              side: BorderSide(
                                                  color: Colors.red[900]))),
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                        return Colors.red[900];
                                      }),
                                    ),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    )),
                              ),
                            ],
                          )
                        ],
                      ),
              ),
            );
          });
        });
  }
}

List<String> headerNameLst(List<Map<String, dynamic>> demoTableScanOutput,
    {bool showAllColumns = false}) {
  List<String> lst = [];

  // painter.hitTestInteractive(position, PointerDeviceKind.touch)
  for (var itm in demoTableScanOutput) {
    for (var k in itm.keys) {
      if (!lst.contains(k)) {
        if (showAllColumns || !hideCloumnNames.contains(k)) {
          lst.add(k);
        }
      }
    }
  }
  return lst;
}

class TableItemDataSource extends DataGridSource {
  final DataGridController controller;
  final BuildContext context;

  TableItemDataSource(this.controller, this.context);

  final List<DataGridRow> _employees = selectedTableItemListData
      .map((e) => DataGridRow(
          cells: headerNameLst(selectedTableItemListData)
              .map((k) => DataGridCell(
                  columnName: k,
                  value: e.containsKey(k) ? attributeValueToString(e[k]) : ''))
              .toList()))
      .toList();

  @override
  List<DataGridRow> get rows => _employees;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Listener(
        onPointerDown: (p) => _onRowSelected(row),
        child: Container(
          color: _employees.indexOf(row) == controller.selectedIndex
              ? Colors.purple
              : _employees.indexOf(row).isEven
                  ? Colors.white
                  : dyc1,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Text(
            dataGridCell.value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12,
                color: _employees.indexOf(row) == controller.selectedIndex
                    ? Colors.white
                    : Colors.black),
          ),
        ),
      );
    }).toList());
  }
}

Future<void> _onRowSelected(DataGridRow row) async {
  if (row.getCells().first.columnName == 'id') {
    for (Map<String, AttributeValue> ele in selectedTableItemListData) {
      for (var v in ele.values) {
        if (v.toJson().values.first == row.getCells().first.value) {
          // print(ele[k]);
          selectedRowData.value = ele;
        }
      }

      // for (var v in ele.values) {
      //   if (v == row.getCells().first.value) {
      //     print('$v == ${row.getCells().first.value}');
      //     editorRowData.value = ele;

      //     print(ele);
      //     break;
      //   }
      // }
    }
  }
  // else {
  //   row.getCells().forEach((ele) {});
  // }
  showEditRowBtn.value = true;

  // print(row.getCells().first.columnName);
  // print(row.getCells().first.value);
}
