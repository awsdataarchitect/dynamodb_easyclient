import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:document_client/document_client.dart';
import 'package:dynamodb_easyclient/pages/homepage/dashboard/dashboard_table.dart';
import 'package:flutter/material.dart';
import 'package:dynamodb_easyclient/shared_files/data/constant_data.dart';

class TableFilter extends StatefulWidget {
  final Function loadTableFilter;
  const TableFilter({Key key, this.loadTableFilter}) : super(key: key);

  @override
  _TableFilterState createState() => _TableFilterState();
}

class _TableFilterState extends State<TableFilter> {
  List<String> attributeName = [''];
  List<String> attributeValue = [''];
  List<int> selConditionsLst = [0];

  int numOfFilters = 1;
  List<CustomPopupMenuController> popupControllers = [
    CustomPopupMenuController()
  ];
  final _formkey = GlobalKey<FormState>();

  bool scanFilterActive = true;

  List<String> scanConditions = [
    '=',
    '!=',
    '>',
    '<',
    '>=',
    '<=',
    'Contains',
    'Not Contains',
    'Begins With',
    'Exists',
    'Not Exists'
  ];

  addFilter() {
    setState(() {
      numOfFilters++;
      attributeName.insert(attributeName.length, '');
      attributeValue.insert(attributeValue.length, '');
      selConditionsLst.insert(selConditionsLst.length, 0);
      popupControllers.insert(
          popupControllers.length, CustomPopupMenuController());
    });
  }

  removeFilter(index) {
    setState(() {
      numOfFilters--;
      attributeName.removeAt(index);
      attributeValue.removeAt(index);
      selConditionsLst.removeAt(index);
      popupControllers.removeAt(index);
    });
  }

  clearFilter() {
    setState(() {
      _formkey.currentState.reset();
      numOfFilters = 1;
      attributeName = [''];
      attributeValue = [''];
      selConditionsLst = [0];
      popupControllers = [CustomPopupMenuController()];
    });
  }

  scanFilters() {
    String filterExpression = "";
    Map<String, String> expressionAttributeNames = {};
    Map<String, AttributeValue> expressionAttributeValues = {};

    for (int i = 0; i < numOfFilters; i++) {
      if (attributeName.elementAt(i).isNotEmpty) {
        if (i != 0) filterExpression += ' AND ';
        filterExpression +=
            filterExpressionFormConditioin(selConditionsLst.elementAt(i), i);
        expressionAttributeNames['#an$i'] = attributeName.elementAt(i);
        if (selConditionsLst.elementAt(i) != 9 &&
            selConditionsLst.elementAt(i) != 10) {
          expressionAttributeValues[':av$i'] =
              AttributeValue(s: attributeValue.elementAt(i));
        }
      }
    }

    widget.loadTableFilter(
        filterExpression, expressionAttributeNames, expressionAttributeValues);
  }

  filterExpressionFormConditioin(int index, int count) {
    // print('condition $index');
    String n = '#an$count';
    String v = ':av$count';
    switch (index) {
      case 0:
        return n + ' = ' + v;
      case 1:
        return n + ' <> ' + v;
      case 2:
        return n + ' > ' + v;
      case 3:
        return n + ' < ' + v;
      case 4:
        return n + ' >= ' + v;
      case 5:
        return n + ' <= ' + v;
      case 6:
        return "contains($n, $v)";
      case 7:
        return "NOT contains($n, $v)";
      case 8:
        return "begins_with($n, $v)";
      case 9:
        return "attribute_exists($n)";
      case 10:
        return "attribute_not_exists($n)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width - sideMenuWidth,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]), color: dyc1),
      child: ListView(children: [
        const SizedBox(height: 10),
        Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (int i = 0; i < numOfFilters; i++) filterTile(i)],
          ),
        ),
        SizedBox(
          width: 400,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(
                  width: 160,
                  child: TextButton(
                      onPressed: addFilter,
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey[300]))),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                          return Colors.white;
                        }),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, size: 15, color: Colors.black),
                          SizedBox(width: 5),
                          Text(
                            'Add another filter',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ],
                      )),
                ),
                SizedBox(
                  width: 110,
                  child: TextButton(
                    onPressed: clearFilter,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey[300]))),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return Colors.white;
                      }),
                    ),
                    child: const Text(
                      'Clear Filter',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 110,
                  child: TextButton(
                    onPressed: scanFilters,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey[300]))),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return Colors.white;
                      }),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.document_scanner_outlined,
                            color: Colors.black, size: 12),
                        SizedBox(width: 10),
                        Text(
                          'Scan',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  filterTile(int index) {
    return SizedBox(
      width: 650,
      height: 35,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, bottom: 5),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            SizedBox(
              width: 120,
              height: 35,
              child: TextFormField(
                autofocus: false,
                validator: (val) => val.isEmpty ? 'Enter Attribute name' : null,
                onChanged: (val) =>
                    setState(() => attributeName.insert(index, val)),
                decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(8.0),
                    hintText: 'Attribute name',
                    border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 10),
            columnsShowMenuBtn(index),
            const SizedBox(width: 10),
            if (selConditionsLst.elementAt(index) != 9 &&
                selConditionsLst.elementAt(index) != 10)
              SizedBox(
                width: 120,
                height: 35,
                child: TextFormField(
                  autofocus: false,
                  validator: (val) =>
                      val.isEmpty ? 'Enter Attribute value' : null,
                  onChanged: (val) =>
                      setState(() => attributeValue.insert(index, val)),
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(8.0),
                      hintText: 'Attribute value',
                      border: OutlineInputBorder()),
                ),
              ),
            const SizedBox(width: 10),
            IconButton(
                onPressed: () => removeFilter(index),
                icon: const Icon(Icons.remove_circle_outline))
          ],
        ),
      ),
    );
  }

  columnsShowMenuBtn(int index) {
    return CustomPopupMenu(
      child: SizedBox(
        width: 90,
        height: 32,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]),
                color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  scanConditions[selConditionsLst.elementAt(index)],
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
                const Icon(Icons.arrow_drop_down,
                    size: 18, color: Colors.black),
              ],
            )),
      ),
      barrierColor: Colors.transparent,
      pressType: PressType.singleClick,
      verticalMargin: -10,
      controller: popupControllers.elementAt(index),
      menuBuilder: () => ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(2),
            color: Colors.grey[100],
          ),
          // padding: EdgeInsets.all(8),
          height: 270,
          child: IntrinsicWidth(
            child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: scanConditions
                      .map((e) => GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              selConditionsLst.insert(
                                  index, scanConditions.indexOf(e));
                              // print(scanConditions.indexOf(e));
                              setState(() {});
                              popupControllers.elementAt(index).hideMenu();
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Container(
                                margin: const EdgeInsets.only(left: 5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                )),
          ),
        ),
      ),
    );
  }
}
