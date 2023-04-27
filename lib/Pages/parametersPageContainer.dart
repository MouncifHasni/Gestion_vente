import 'dart:convert';
import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_vente_app/model/role.dart';
import 'package:gestion_vente_app/model/utilisateur.dart';
import 'package:gestion_vente_app/utility/mongodb.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:mongo_dart/mongo_dart.dart' as _MongoDb;

class ParametersPageContainer extends StatefulWidget {
  @override
  _ParametersPageContainer createState() => _ParametersPageContainer();
}

class _ParametersPageContainer extends State<ParametersPageContainer> {
  bool _modifyImageChanged = false;
  File _image;
  ImageProvider imageprovider;
  var _cmpressed_image;
  _MongoDb.GridFS bucket;
  String id_image = null;
  bool _showpassword = false;
  List<RoleJson> listroles;
  Utilisateur _dataTomodify = new Utilisateur();
  bool _isModified = false;
  UtilisateurJson _myuser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSingleUser().then((value) => _myuser = value);
    getProfileInfo();
  }

  final _nomControllermodify = TextEditingController();
  final _emailControllermodify = TextEditingController();
  final _teleControllermodify = TextEditingController();
  final _passwordControllermodify = TextEditingController();
  final _roleControllermodify = TextEditingController();

  void pickImage() {
    final file = OpenFilePicker()
      ..filterSpecification = {
        'PNG (*.png)': '*.png',
        'JPEG (*.jpeg,*.jpg)': '*.jpeg;*.jpg',
        'All Files': '*.*'
      }
      ..defaultFilterIndex = 0
      ..defaultExtension = 'doc'
      ..title = 'Select an image';

    setState(() {
      _image = file.getFile();
    });
    _modifyImageChanged = true;
    _isModified = true;
  }

  Future<void> readImage(String id) async {
    var _db = await DBSingleton.instance.database;
    bucket = await _MongoDb.GridFS(_db, "image");

    var img = await bucket.chunks.findOne({"_id": id});
    setState(() {
      globale_image = MemoryImage(base64Decode(img["data"]));
    });
  }

  Future<void> modifyImage(String id) async {
    var _db = await DBSingleton.instance.database;
    bucket = await _MongoDb.GridFS(_db, "image");

    try {
      _cmpressed_image = await _image.readAsBytes();
    } catch (e) {
      _cmpressed_image = await FlutterImageCompress.compressWithFile(
          _image.path,
          format: CompressFormat.jpeg,
          quality: 70);
    }

    await bucket.chunks.update(_MongoDb.where.eq("_id", id), {
      r'$set': {"data": base64Encode(_cmpressed_image)}
    });
    readImage(id);

    print("image modified");
  }

  Future<void> uploadImageToDB() async {
    var _db = await DBSingleton.instance.database;
    bucket = await _MongoDb.GridFS(_db, "image");

    try {
      _cmpressed_image = await _image.readAsBytes();
    } catch (e) {
      _cmpressed_image = await FlutterImageCompress.compressWithFile(
          _image.path,
          format: CompressFormat.jpeg,
          quality: 70);
    }
    id_image = getRandomString(8);
    if (_image != null) {
      Map<String, dynamic> image = {
        "_id": id_image,
        "data": base64Encode(_cmpressed_image)
      };
      await bucket.chunks.insert(image);
    }
    readImage(id_image);
    globaleUser.image = id_image;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Paramètres de Profile",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Stack(
              children: [
                getImageWidget(),
                Positioned(
                  bottom: 5,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      //pick Image
                      setState(() {
                        _modifyImageChanged = true;
                      });
                      pickImage();
                    },
                    child: CircleAvatar(
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 10,
                      ),
                      radius: 10,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            )),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    width: getWidgetWidth(280),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _nomControllermodify,
                      decoration: InputDecoration(
                          labelText: "Nom d'utilisateur",
                          suffixIcon: Icon(
                            FontAwesomeIcons.user,
                            size: 17,
                          )),
                      onChanged: (value) {
                        _isModified = true;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 7,
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    width: getWidgetWidth(280),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      onChanged: (value) {
                        _isModified = true;
                      },
                      controller: _passwordControllermodify,
                      obscureText: !_showpassword,
                      decoration: InputDecoration(
                          labelText: "Mot de passe",
                          suffixIcon: IconButton(
                            icon: Icon(
                              this._showpassword
                                  ? FontAwesomeIcons.eye
                                  : FontAwesomeIcons.eyeSlash,
                              size: 17,
                            ),
                            onPressed: () {
                              setState(() {
                                this._showpassword = !this._showpassword;
                              });
                            },
                          )),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    width: getWidgetWidth(330),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      onChanged: (value) {
                        _isModified = true;
                      },
                      controller: _emailControllermodify,
                      decoration: InputDecoration(
                          labelText: "Email",
                          suffixIcon: Icon(
                            Icons.email,
                            size: 17,
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  width: 7,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    width: getWidgetWidth(280),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      onChanged: (value) {
                        _isModified = true;
                      },
                      controller: _teleControllermodify,
                      decoration: InputDecoration(
                          labelText: "Téléphone",
                          suffixIcon: Icon(
                            FontAwesomeIcons.phone,
                            size: 17,
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  width: 7,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    width: getWidgetWidth(280),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      enabled: false,
                      decoration: InputDecoration(
                          labelText: "Role",
                          suffixIcon: Icon(
                            FontAwesomeIcons.userCheck,
                            size: 17,
                          )),
                      controller: _roleControllermodify,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: getWidgetHeight(40),
                  width: getWidgetWidth(250),
                  child: ElevatedButton(
                      child: Text('Enregistrer'),
                      style: ButtonStyle(),
                      onPressed: () async {
                        if (_isModified) {
                          if (_modifyImageChanged == true &&
                              globale_image == null) {
                            await uploadImageToDB();
                          } else if (_modifyImageChanged &&
                              globale_image != null) {
                            await modifyImage(globaleUser.image);
                          }
                          getModifyDataFromControllers();
                          modifyUtilisateur(_dataTomodify).whenComplete(() {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  Future.delayed(Duration(milliseconds: 500),
                                      () {
                                    Navigator.of(context).pop(true);
                                  });
                                  return AlertDialog(
                                    title: Image.asset(
                                      'assets/success.png',
                                      height: 50,
                                      width: 50,
                                    ),
                                    content: Text(
                                      "Utilisateur Modifier!",
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                });
                          });
                        }
                      }),
                ),
                SizedBox(
                  width: 5,
                )
              ],
            ),
          ],
        ));
  }

  double getWidgetWidth(double nb) {
    return MediaQuery.of(context).size.width * nb / 1265;
  }

  double getWidgetHeight(double nb) {
    return MediaQuery.of(context).size.height * nb / 646;
  }

  void getProfileInfo() async {
    await getListRoles().then((value) => listroles = value);

    _nomControllermodify.text = _myuser.nom; //globaleUser.nom;
    _emailControllermodify.text = _myuser.email;
    _passwordControllermodify.text = _myuser.motdepasse;
    _teleControllermodify.text = _myuser.tele;
    _roleControllermodify.text = globalRole;
  }

  void getModifyDataFromControllers() {
    _dataTomodify.setId(globaleUser.id);
    _dataTomodify.setNom(_nomControllermodify.text);
    _dataTomodify.setTele(_teleControllermodify.text);
    _dataTomodify.setEmail(_emailControllermodify.text);
    if (_passwordControllermodify.text != _myuser.motdepasse) {
      _dataTomodify
          .setMotdepasse(getEncryptedPassword(_passwordControllermodify.text));
    } else {
      _dataTomodify.setMotdepasse(_passwordControllermodify.text);
    }
    _dataTomodify.setRole(globaleUser.role);
    if (_modifyImageChanged && globale_image == null) {
      _dataTomodify.setImage(id_image);
    } else {
      _dataTomodify.setImage(globaleUser.image);
    }
    setState(() {
      globaleUsername = _nomControllermodify.text;
      globaleUser.nom = _nomControllermodify.text;
    });
  }

  Widget getImageWidget() {
    if (globale_image == null && _image == null) {
      return Image.asset(
        'assets/default_user_icon.png',
        height: 100,
        width: 100,
      );
    } else if (_image == null) {
      return Image(
        image: globale_image,
        height: 100,
        width: 100,
      );
    } else {
      return Image.file(
        _image,
        height: 100,
        width: 100,
      );
    }
  }
}

Future<List<RoleJson>> getListRoles() async {
  List<RoleJson> rolelist = List<RoleJson>();
  var roles;
  await getCollectionRoles().then((value) => roles = value);
  for (var c in roles) {
    rolelist.add(RoleJson.fromJson(c));
  }
  return rolelist;
}
