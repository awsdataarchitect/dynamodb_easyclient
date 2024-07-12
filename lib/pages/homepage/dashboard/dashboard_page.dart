import 'package:document_client/document_client.dart';
import 'package:dynamodb_easyclient/models/app_user.dart';
import 'package:dynamodb_easyclient/pages/homepage/dashboard/dashboard_table.dart';
import 'package:dynamodb_easyclient/pages/homepage/dashboard/keys_id_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dynamodb_easyclient/shared_files/data/constant_data.dart';
import 'package:provider/provider.dart';

class DynoDbDashboard extends StatefulWidget {
  final AppUserData apiUserData;
  const DynoDbDashboard({Key key, this.apiUserData}) : super(key: key);

  @override
  _DynoDbDashboardState createState() => _DynoDbDashboardState();
}

class _DynoDbDashboardState extends State<DynoDbDashboard> {
  String newKeyId = '',
      newKeySecret = '';
  bool showLoading = false, showSetting = false;
  Map<String, bool> showTable = {for (var v in dynamomDbRegionLst) v: false};

  Map<String, List<String>> activeRegionTableLst = {};
  Map<String, List<String>> notactiveRegionTableLst = {};
  final loadingRegionStatus = ValueNotifier<String>('');
  User user;
  void loadRegion(String keyId, String keySecret) async {
    activeRegionTableLst = {};
    for (var r in dynamomDbRegionLst) {
      loadingRegionStatus.value = 'Scanning region $r';
      ListTablesOutput lt;
      try {
        final service = DocumentClient(
            region: r,
            credentials:
                AwsClientCredentials(accessKey: keyId, secretKey: keySecret));
        lt = await service.dynamoDB.listTables();
      } catch (e) {}
      if (lt != null && lt.tableNames != null) {
        // print(r + ': tables -> ' + lt.tableNames.length.toString());
        activeRegionTableLst[r] = lt.tableNames;
      } else {
        // print(r + ': tables -> ' + 'null');
        notactiveRegionTableLst[r] = [];
      }
    }
    newKeyId = keyId;
    newKeySecret = keySecret;
    showLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // loadRegion('', '');
    user = Provider.of<User>(context);

    return ValueListenableBuilder<String>(
        valueListenable: loadingRegionStatus,
        builder: (_, loadingStatus, __) {
          return Scaffold(
              backgroundColor: dyc1,
              body: Center(
                child: activeRegionTableLst.length +
                            notactiveRegionTableLst.length ==
                        // 2
                        21
                    ? DashboardTable(
                        apiUserData: widget.apiUserData,
                        activeRegionTableLst: activeRegionTableLst,
                        notactiveRegionTableLst: notactiveRegionTableLst,
                        keySecret: newKeySecret,
                        keyId: newKeyId,
                        loadDynamodb: (key, secret) {
                          setState(() => showLoading = true);

                          loadRegion(key, secret);
                        })
                    : Container(
                        width: MediaQuery.of(context).size.width - 40,
                        alignment: Alignment.center,
                        child: showLoading
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CupertinoActivityIndicator(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    loadingStatus,
                                  )
                                ],
                              )
                            : KeyIdsDashboard(
                                apiUserData: widget.apiUserData,
                                loadDynamodb: (key, secret) {
                                  setState(() => showLoading = true);

                                  loadRegion(key, secret);
                                })),
              ));
        });
  }

  // Widget header() {
  //   return FutureBuilder<bool>(
  //       future: UserSubscriptionInfoDbService(uid: widget.apiUserData.uuid)
  //           .checkUserHaveSubscriptionQuery(),
  //       builder: (context, snapshot) {
  //         return Align(
  //           alignment: Alignment.topCenter,
  //           child: Container(
  //             height: 40,
  //             decoration: BoxDecoration(
  //               color: dyc1,
  //               border: Border.all(color: Colors.grey[300]),
  //             ),
  //             width: MediaQuery.of(context).size.width - 1,
  //             padding: const EdgeInsets.symmetric(vertical: 5),
  //             child: Row(
  //               children: [
  //                 const SizedBox(
  //                   width: 20,
  //                 ),
  //                 MouseRegion(
  //                     cursor: SystemMouseCursors.click,
  //                     child: GestureDetector(
  //                         onTap: () {
  //                           // launch('https://dynamodb-easyclient.web.app/');
  //                         },
  //                         child: Row(children: [
  //                           Image.asset(
  //                             'assets/waltsoft_logo.png',
  //                             color: dyc1,
  //                             height: 20,
  //                           ),
  //                           const SizedBox(
  //                             width: 10,
  //                           ),
  //                           // Text(
  //                           //   'Waltsoft Inc',
  //                           //   style: pageFontStyle.copyWith(
  //                           //       color: Colors.black,
  //                           //       fontSize: 16,
  //                           //       fontWeight: FontWeight.bold),
  //                           // ),
  //                         ]))),
  //                 const Expanded(
  //                   child: SizedBox(
  //                     width: 10,
  //                   ),
  //                 ),
  //                 if (snapshot.hasData && !snapshot.data)
  //                   ElevatedButton(
  //                       onPressed: () {
  //                         setState(() {
  //                           showSetting = true;
  //                         });
  //                       },
  //                       style: ElevatedButton.styleFrom(primary: Colors.white),
  //                       child: trialStatus(user.metadata.creationTime)),
  //                 const SizedBox(
  //                   width: 20,
  //                 ),
  //                 if (showSetting)
  //                   ElevatedButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                         AuthService().signOut();
  //                       },
  //                       style: ElevatedButton.styleFrom(primary: Colors.red),
  //                       child: const Text('Logout')),
  //                 const SizedBox(
  //                   width: 20,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

  sideMenu() {
    return Container(
      width: 40,
      height: MediaQuery.of(context).size.height - 40,
      decoration: BoxDecoration(
        color: dyc1,
        border: Border.all(color: Colors.grey[300]),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          IconButton(
              onPressed: () {
                if (showSetting) {
                  setState(() {
                    showSetting = false;
                  });
                }
              },
              splashRadius: 1,
              icon: Icon(
                // CupertinoIcons.cube_box_fill,
                Icons.vpn_key,
                size: 18,
                color: !showSetting ? dyc1 : Colors.black,
              )),
          const SizedBox(
            height: 20,
          ),
          IconButton(
              splashRadius: 1,
              onPressed: () {
                setState(() {
                  showSetting = true;
                });
              },
              icon: Icon(Icons.settings,
                  color: showSetting ? dyc1 : Colors.black, size: 18)),
        ],
      ),
    );
  }
}
