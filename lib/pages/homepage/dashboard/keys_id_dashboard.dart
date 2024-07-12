import 'dart:ui';
import 'package:dynamodb_easyclient/models/app_user.dart';
import 'package:dynamodb_easyclient/models/key_id_data.dart';
import 'package:dynamodb_easyclient/service/database/key_id_secret_db_service.dart';
import 'package:dynamodb_easyclient/shared_files/constants.dart';
import 'package:dynamodb_easyclient/shared_files/toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class KeyIdsDashboard extends StatefulWidget {
  final AppUserData apiUserData;
  final Function loadDynamodb;

  const KeyIdsDashboard({Key key, this.loadDynamodb, this.apiUserData})
      : super(key: key);

  @override
  _KeyIdsDashboardState createState() => _KeyIdsDashboardState();
}

class _KeyIdsDashboardState extends State<KeyIdsDashboard> {
  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();
  List<KeyIdData> keyIdsData = [];
  String newKeyId = '', newKeySecret = '';
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<KeyIdData>>(
        stream:
            UserKeyIdDbService(uid: widget.apiUserData.uuid).getUserKeyIdsData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            keyIdsData = snapshot.data;
            // print('sd');
            // print(keyIdsData.first.keyId);
          }

          return SizedBox(
            height: MediaQuery.of(context).size.height - 60,
            width: MediaQuery.of(context).size.width - 50,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: keyIdsData.isEmpty
                        ? MediaQuery.of(context).size.height - 60
                        : 200,
                    child: Form(
                      key: _formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                  hintText: 'Enter Access Key Id'),
                              validator: (val) => val.isEmpty
                                  ? 'Enter Your Access Key Id'
                                  : null,
                              onChanged: (val) {
                                setState(() => newKeyId = val);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                  hintText: 'Enter Access Key Secret'),
                              validator: (val) => val.isEmpty
                                  ? 'Enter Your Access Key Secret'
                                  : null,
                              onChanged: (val) {
                                setState(() => newKeySecret = val);
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(primary: c2),
                              onPressed: () {
                                if (_formkey.currentState.validate()) {
                                  if (checkIsAlreadyExistInDb()) {
                                    UserKeyIdDbService(
                                            uid: widget.apiUserData.uuid)
                                        .addNewKey('', newKeyId, newKeySecret);
                                  }
                                  widget.loadDynamodb(newKeyId, newKeySecret);
                                }
                              },
                              child: const Text(
                                'Load Dynamodb',
                                style: TextStyle(fontSize: 12),
                              ))
                        ],
                      ),
                    ),
                  ),
                  for (KeyIdData k in keyIdsData)
                    Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      splashRadius: 1,
                                      onPressed: () {
                                        createAlertDialogForDeleteProfile(
                                            context, k.docId);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      )),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      k.keyName.isEmpty
                                          ? 'Profile ${keyIdsData.indexOf(k) + 1}'
                                          : k.keyName,
                                      style: TextStyle(
                                          color: k.keyName.isEmpty
                                              ? Colors.grey
                                              : Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  IconButton(
                                      splashRadius: 1,
                                      onPressed: () {
                                        editPorfileDialog(context, k.docId, k);
                                      },
                                      icon: const Icon(
                                        Icons.mode_edit,
                                        size: 20,
                                      )),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text('ACCESS KEY ID  :  ',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(
                                height: 5,
                              ),
                              SelectableText(k.keyId,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black)),
                              const SizedBox(
                                height: 10,
                              ),
                              SecretTile(
                                k: k,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                    style:
                                        ElevatedButton.styleFrom(primary: c2),
                                    onPressed: () {
                                      widget.loadDynamodb(k.keyId, k.keySecret);
                                    },
                                    child: const Text(
                                      'Dynamodb >',
                                      style: TextStyle(fontSize: 12),
                                    )),
                              )
                            ],
                          ),
                        )),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          );
        });
  }

  checkIsAlreadyExistInDb() {
    for (KeyIdData k in keyIdsData) {
      if (k.keyId == newKeyId && k.keySecret == newKeySecret) {
        return false;
      }
    }
    return true;
  }

  editPorfileDialog(BuildContext context, String docId, KeyIdData k) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState2) {
            return Dialog(
              child: Container(
                  width: 380,
                  height: 350,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                      child: Form(
                          key: _formkey2,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Edit Profile',
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  initialValue: k.keyName,
                                  decoration: InputDecoration(
                                      hintText: 'Enter profile name (Optional)',
                                      fillColor: Colors.white,
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200))),
                                  validator: (val) {
                                    return null;
                                  },
                                  onChanged: (val) =>
                                      setState2(() => k.keyName = val),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  initialValue: k.keyId,
                                  decoration: InputDecoration(
                                      hintText: 'Enter Access Key Id',
                                      fillColor: Colors.white,
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200))),
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return 'Enter Your Access Key Id';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) =>
                                      setState2(() => k.keyId = val),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  initialValue: k.keySecret,
                                  decoration: InputDecoration(
                                      hintText: 'Enter Access Key Secret',
                                      fillColor: Colors.white,
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200))),
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return 'Enter Your Access Key Secret';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) =>
                                      setState2(() => k.keySecret = val),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 300,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formkey2.currentState.validate()) {
                                          UserKeyIdDbService(
                                                  uid: widget.apiUserData.uuid)
                                              .updateKey(k.keyName, k.keyId,
                                                  k.keySecret, k.docId);

                                          setState(() {});
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('Submit')),
                                )
                              ])))),
            );
          });
        });
  }

  createAlertDialogForDeleteProfile(BuildContext context, String docId) {
    return showDialog(
        context: context,
        builder: (context2) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
                width: 400,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Delete Proflie',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                          'If you are sure you wish to delete this profile, tap \'Delete.\'',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 30,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red),
                                onPressed: () async {
                                  Navigator.pop(context2);
                                  await UserKeyIdDbService(
                                          uid: widget.apiUserData.uuid)
                                      .deleteKeyID(docId);

                                  showToast('Profile Deleted', context);
                                },
                                child: const Text('Delete')),
                          ),
                          SizedBox(
                            width: 150,
                            height: 30,
                            child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context2);
                                },
                                child: const Text('Cancel')),
                          ),
                        ],
                      ),
                    ])),
          );
        });
  }
}

class SecretTile extends StatefulWidget {
  final KeyIdData k;

  const SecretTile({Key key, this.k}) : super(key: key);

  @override
  _SecretTileState createState() => _SecretTileState();
}

class _SecretTileState extends State<SecretTile> {
  bool revealSecret = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACCESS KEY SECRET  :  ',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: SelectableText(
                  revealSecret
                      ? widget.k.keySecret
                      : widget.k.keySecret.substring(0, 3) +
                          '***********************' +
                          widget.k.keySecret.substring(
                              widget.k.keySecret.length - 4,
                              widget.k.keySecret.length - 1),
                  style: const TextStyle(fontSize: 12)),
            ),
            const Expanded(child: SizedBox(width: 10)),
            GestureDetector(
                onTap: () {
                  setState(() {
                    revealSecret = !revealSecret;
                  });
                },
                child: Icon(
                    revealSecret
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 18,
                    color: Colors.grey)),
            const SizedBox(width: 10)
          ],
        ),
      ],
    );
  }
}
