import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_vente_app/Pages/rolesPageContainer.dart';
import 'package:gestion_vente_app/model/role.dart';
import 'package:gestion_vente_app/model/utilisateur.dart';
import 'package:gestion_vente_app/utility/mongodb.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:mongo_dart/mongo_dart.dart' as _MongoDb;
import 'package:provider/provider.dart';

class UtilisateurPageContainer extends StatefulWidget {
  @override
  _UtilisateurPageContainer createState() => _UtilisateurPageContainer();
}

class _UtilisateurPageContainer extends State<UtilisateurPageContainer>
    with SingleTickerProviderStateMixin {
  utilisateurContainerState UtilisateurState;
  String textEditedVal;
  Utilisateur _dataTomodify = new Utilisateur();
  Utilisateur _dataToAdd = new Utilisateur();
  //search
  bool searchClicked = false;
  String _searchResult = '';
  List<UtilisateurJson> _filteredUser;
  List<UtilisateurJson> _listUser;
  TextEditingController _controller = TextEditingController();
  bool searshing = false;
  String _roleValueChoose;
  String _roleValueChoosemodify;
  List<RoleJson> _listRoles;
  bool _showpassword = false;
  //image
  File _image;
  String id_image = null;
  var _cmpressed_image;
  _MongoDb.GridFS bucket;
  ImageProvider imageprovider;
  bool _modifyImageChanged = false;

  Future<void> readImage(String id) async {
    var _db = await DBSingleton.instance.database;
    bucket = await _MongoDb.GridFS(_db, "image");

    var img = await bucket.chunks.findOne({"_id": id});
    setState(() {
      imageprovider = MemoryImage(base64Decode(img["data"]));
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
  }

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
  }

  @override
  void initState() {
    super.initState();
    UtilisateurpageProvider()
        .getRolesData(context)
        .then((value) => _listRoles = value);
    UtilisateurState = utilisateurContainerState.showUtilisateur;
    UtilisateurpageProvider()
        .getUserData(context)
        .then((value) => _listUser = value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: case2(
            UtilisateurState,
            {
              utilisateurContainerState.showUtilisateur: getTableWidget(),
              utilisateurContainerState.addUtilisateur:
                  getAjoutUtilisateurWidget(),
              utilisateurContainerState.modifyUtilisateur:
                  getmodifyUtilisateurWidget(_dataTomodify),
              utilisateurContainerState.showRoles: RolePageContainer()
            },
            getTableWidget()));
  }

  Widget getTableWidget() {
    return ChangeNotifierProvider<UtilisateurpageProvider>(
      create: (context) => UtilisateurpageProvider(),
      child: Consumer<UtilisateurpageProvider>(
        // ignore: missing_return
        builder: (context, provider, child) {
          if (provider.utilisateurlist == null) {
            provider.getData(context);
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!searshing) {
            _filteredUser = provider.utilisateurlist;
          }
          return Stack(
            alignment: Alignment.bottomRight,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingTextStyle: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold),
                        columns: [
                          DataColumn(
                            label: Text(
                              '',
                            ),
                          ),
                          /*DataColumn(
                            label: Text('Image'),
                          ),*/
                          DataColumn(
                            label: Text('Nom'),
                          ),
                          DataColumn(
                            label: Text('Email'),
                          ),
                          DataColumn(
                            label: Text('Tele'),
                          ),
                          DataColumn(
                            label: Text('Role'),
                          ),
                          DataColumn(
                            label: Text(''),
                          ),
                        ],
                        rows: _filteredUser
                            .map((data) => DataRow(cells: [
                                  DataCell(IconButton(
                                    icon: Icon(Icons.edit),
                                    hoverColor: Colors.transparent,
                                    color: Colors.blue,
                                    iconSize: 17,
                                    onPressed: () async {
                                      if (data.image != null &&
                                          data.image.isNotEmpty)
                                        await readImage(data.image);
                                      setState(() {
                                        _modifyImageChanged = false;
                                        _dataTomodify
                                            .setMotdepasse(data.motdepasse);
                                        _dataTomodify.setId(data.id);
                                        setModifyControllersData(data);
                                        UtilisateurState =
                                            utilisateurContainerState
                                                .modifyUtilisateur;
                                      });
                                    },
                                  )),
                                  DataCell(modifyinputField(
                                      data.id, 'nom', data.nom, provider)),
                                  DataCell(modifyinputField(
                                      data.id, 'email', data.email, provider)),
                                  DataCell(modifyinputField(
                                      data.id, 'tele', data.tele, provider)),
                                  DataCell(
                                      Text(getNomRole(_listRoles, data.role))),
                                  DataCell(IconButton(
                                    icon: Icon(Icons.delete),
                                    hoverColor: Colors.transparent,
                                    color: Colors.red,
                                    iconSize: 17,
                                    onPressed: () {
                                      deleteUtilisateur(getSubID(data.id))
                                          .whenComplete(() {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) {
                                              Future.delayed(
                                                  Duration(milliseconds: 600),
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
                                                  "Utilisateur supprimer!",
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            });
                                        provider.getData(context);
                                        setState(() {
                                          _filteredUser =
                                              provider.utilisateurlist;
                                          _listUser = _filteredUser;
                                        });
                                      });
                                    },
                                  ))
                                ]))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                  duration: Duration(milliseconds: 600),
                  bottom: 80,
                  right: searchClicked ? 70 : -210,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    color: Colors.grey[300],
                    width: 210,
                    height: 40,
                    child: TextField(
                      controller: _controller,
                      onChanged: (val) {
                        setState(() {
                          _searchResult = val;
                          searchUtilisateur();
                        });
                      },
                      decoration: new InputDecoration(
                          hintText: "Entrer Nom",
                          suffixIcon: IconButton(
                            icon: Icon(FontAwesomeIcons.search),
                            iconSize: 17,
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            hoverColor: Colors.transparent,
                            color: Colors.grey[800],
                            onPressed: () {
                              setState(() {
                                searchUtilisateur();
                              });
                            },
                          )),
                    ),
                  )),
              Positioned(
                  bottom: 80,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    color: Colors.white,
                    width: 55,
                    height: 40,
                  )),
              Positioned(
                bottom: 72,
                right: 10,
                child: FloatingActionButton(
                  heroTag: "search_utilisateur",
                  backgroundColor: Colors.amber[700],
                  child: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchClicked = !searchClicked;
                      _controller.clear();
                      _searchResult = '';
                      if (!searchClicked) searchUtilisateur();
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton(
                    heroTag: "add_utilisateur",
                    child: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        UtilisateurState =
                            utilisateurContainerState.addUtilisateur;
                      });
                    }),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: SizedBox(
                  height: getWidgetHeight(50),
                  width: getWidgetWidth(150),
                  child: ElevatedButton(
                      child: Text(
                        'Roles',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed))
                            return Colors.green;
                          return Colors.orangeAccent[
                              700]; // Use the component's default.
                        },
                      )),
                      onPressed: () {
                        setState(() {
                          UtilisateurState =
                              utilisateurContainerState.showRoles;
                        });
                      }),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void searchUtilisateur() {
    if (_searchResult.isEmpty) {
      searshing = false;
      UtilisateurpageProvider()
          .getUserData(context)
          .then((value) => _listUser = value)
          .whenComplete(() => _filteredUser = _listUser);
    } else {
      searshing = true;
      _filteredUser = _listUser
          .where((element) => element.nom.startsWith(_searchResult))
          .toList();
    }
  }

  Widget modifyinputField(
      String id, String mykey, String value, UtilisateurpageProvider provider) {
    return TextFormField(
      key: Key(value),
      initialValue: value,
      onChanged: (val) {
        textEditedVal = val;
      },
      decoration: InputDecoration(
          suffixIcon: IconButton(
        icon: Icon(
          FontAwesomeIcons.save,
        ),
        iconSize: 17,
        hoverColor: Colors.transparent,
        onPressed: () {
          //modifier les données
          if (textEditedVal != null) {
            modifyUtilisateuringleVal(getSubID(id), mykey, textEditedVal)
                .whenComplete(() {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    Future.delayed(Duration(milliseconds: 500), () {
                      Navigator.of(context).pop(true);
                    });
                    return AlertDialog(
                      title: Image.asset(
                        'assets/success.png',
                        height: 50,
                        width: 50,
                      ),
                      content: Text(
                        "Utilisateur Modifier!!",
                        textAlign: TextAlign.center,
                      ),
                    );
                  });
              provider.getData(context);
              setState(() {
                if (!searshing) {
                  _filteredUser = provider.utilisateurlist;
                  _listUser = _filteredUser;
                }
              });
            });
            textEditedVal = null;
          }
        },
      )),
    );
  }

  Widget getmodifyUtilisateurWidget(Utilisateur data) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Modifier Utilisateur",
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
                getImageWidget(data.image),
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
                    child: DropdownButton(
                      itemHeight: 66,
                      isExpanded: true,
                      hint: Text('Choisire un role'),
                      value: _roleValueChoosemodify,
                      onChanged: (newVal) {
                        setState(() {
                          _roleValueChoosemodify = newVal;
                        });
                      },
                      items: _listRoles != null
                          ? _listRoles
                              .map((data) => DropdownMenuItem(
                                  value: data.nom, child: Text(data.nom)))
                              .toList()
                          : null,
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
                  width: getWidgetWidth(200),
                  child: ElevatedButton(
                      child: Text('Fermer'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey[500]),
                      ),
                      onPressed: () {
                        setState(() {
                          _modifyImageChanged = false;
                          imageprovider = null;
                          _image = null;
                          UtilisateurState =
                              utilisateurContainerState.showUtilisateur;
                        });
                      }),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: getWidgetHeight(40),
                  width: getWidgetWidth(250),
                  child: ElevatedButton(
                      child: Text('Enregistrer'),
                      style: ButtonStyle(),
                      onPressed: () async {
                        if (_modifyImageChanged == true &&
                            imageprovider == null) {
                          await uploadImageToDB();
                        } else if (_modifyImageChanged &&
                            imageprovider != null) {
                          await modifyImage(data.image);
                        }
                        getModifyDataFromControllers();
                        modifyUtilisateur(_dataTomodify).whenComplete(() {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(milliseconds: 500), () {
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

  Widget getImageWidget(String id) {
    if (_image != null) {
      return Image.file(
        _image,
        height: 80,
        width: 80,
      );
    } else if (imageprovider != null) {
      return Image(
        image: imageprovider,
        height: 80,
        width: 80,
      );
    }
    return Image.asset(
      'assets/default_user_icon.png',
      height: 80,
      width: 80,
    );
  }

  //Controllers for add data
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleController = TextEditingController();
  final _passwordController = TextEditingController();

  //controllers for modify data
  final _nomControllermodify = TextEditingController();
  final _emailControllermodify = TextEditingController();
  final _teleControllermodify = TextEditingController();
  final _passwordControllermodify = TextEditingController();

  Widget getAjoutUtilisateurWidget() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Ajouter Utilisateur",
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
                _image == null
                    ? Image.asset(
                        'assets/default_user_icon.png',
                        height: 80,
                        width: 80,
                      )
                    : Image.file(
                        _image,
                        height: 80,
                        width: 80,
                      ),
                Positioned(
                  bottom: 5,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      //pick Image
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
                      controller: _nomController,
                      decoration: InputDecoration(
                          labelText: "Nom d'utilisateur",
                          suffixIcon: Icon(
                            FontAwesomeIcons.user,
                            size: 17,
                          )),
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
                      controller: _passwordController,
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
                      controller: _emailController,
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
                      controller: _teleController,
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
                    child: DropdownButton(
                      itemHeight: 66,
                      isExpanded: true,
                      hint: Text('Choisire un role'),
                      value: _roleValueChoose,
                      onChanged: (newVal) {
                        setState(() {
                          _roleValueChoose = newVal;
                        });
                      },
                      items: _listRoles != null
                          ? _listRoles
                              .map((data) => DropdownMenuItem(
                                  value: data.nom, child: Text(data.nom)))
                              .toList()
                          : null,
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
                  width: getWidgetWidth(200),
                  child: ElevatedButton(
                      child: Text('Fermer'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey[500]),
                      ),
                      onPressed: () {
                        clearAddPageControllers();
                        setState(() {
                          UtilisateurState =
                              utilisateurContainerState.showUtilisateur;
                        });
                      }),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: getWidgetHeight(40),
                  width: getWidgetWidth(250),
                  child: ElevatedButton(
                      child: Text('Enregistrer'),
                      style: ButtonStyle(),
                      onPressed: () async {
                        if (_image != null) await uploadImageToDB();
                        getDataFromControllers();
                        addUtilisateur(_dataToAdd).whenComplete(() {
                          clearAddPageControllers();
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(milliseconds: 500), () {
                                  Navigator.of(context).pop(true);
                                });
                                return AlertDialog(
                                  title: Image.asset(
                                    'assets/success.png',
                                    height: 50,
                                    width: 50,
                                  ),
                                  content: Text(
                                    "Utilisateur Ajouter!",
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              });
                        });
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

  void getDataFromControllers() {
    _dataToAdd.setNom(_nomController.text);
    _dataToAdd.setTele(_teleController.text);
    _dataToAdd.setEmail(_emailController.text);
    _dataToAdd.setMotdepasse(getEncryptedPassword(_passwordController.text));
    _dataToAdd.setStatut('0');
    _dataToAdd.setRole(getIdRole(_listRoles, _roleValueChoose));
    _dataToAdd.setImage(id_image);
    _dataToAdd.setVentes(null);
  }

  void clearAddPageControllers() {
    _nomController.clear();
    _emailController.clear();
    _teleController.clear();
    _passwordController.clear();
    setState(() {
      id_image = null;
      _image = null;
      _roleValueChoose = null;
      imageprovider = null;
    });
  }

  void setModifyControllersData(UtilisateurJson data) {
    _nomControllermodify.text = data.nom;
    _emailControllermodify.text = data.email;
    _teleControllermodify.text = data.tele;
    _passwordControllermodify.text = data.motdepasse;
    setState(() {
      _roleValueChoosemodify = getNomRole(_listRoles, data.role);
    });
  }

  void getModifyDataFromControllers() {
    _dataTomodify.setStatut("1");
    _dataTomodify.setNom(_nomControllermodify.text);
    _dataTomodify.setTele(_teleControllermodify.text);
    _dataTomodify.setEmail(_emailControllermodify.text);
    if (_passwordControllermodify.text != _dataTomodify.getMotdepasse()) {
      _dataTomodify
          .setMotdepasse(getEncryptedPassword(_passwordControllermodify.text));
    } else {
      _dataTomodify.setMotdepasse(_passwordControllermodify.text);
    }
    _dataTomodify.setRole(getIdRole(_listRoles, _roleValueChoosemodify));
    if (_modifyImageChanged && imageprovider == null)
      _dataTomodify.setImage(id_image);
  }
}

enum utilisateurContainerState {
  showUtilisateur,
  addUtilisateur,
  modifyUtilisateur,
  showRoles
}

class UtilisateurpageProvider extends ChangeNotifier {
  List<UtilisateurJson> utilisateurlist;
  List<RoleJson> roleslist;

  Future getData(context) async {
    utilisateurlist = List<UtilisateurJson>();
    var utilisateurs;
    await getCollectionUtilisateur().then((value) => utilisateurs = value);

    for (var c in utilisateurs) {
      utilisateurlist.add(UtilisateurJson.fromJson(c));
    }
    this.notifyListeners();
  }

  //
  Future<List<UtilisateurJson>> getUserData(context) async {
    utilisateurlist = List<UtilisateurJson>();
    var utilisateurs;
    await getCollectionUtilisateur().then((value) => utilisateurs = value);
    for (var c in utilisateurs) {
      utilisateurlist.add(UtilisateurJson.fromJson(c));
    }
    return utilisateurlist;
  }

  Future<List<RoleJson>> getRolesData(context) async {
    roleslist = List<RoleJson>();
    var roles;
    await getCollectionRoles().then((value) => roles = value);
    for (var c in roles) {
      roleslist.add(RoleJson.fromJson(c));
    }
    return roleslist;
  }
}
