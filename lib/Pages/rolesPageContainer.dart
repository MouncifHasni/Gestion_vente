import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_vente_app/Pages/utilisateursContainerPage.dart';
import 'package:gestion_vente_app/model/role.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:provider/provider.dart';

class RolePageContainer extends StatefulWidget {
  @override
  _RolePageContainer createState() => _RolePageContainer();
}

class _RolePageContainer extends State<RolePageContainer>
    with SingleTickerProviderStateMixin {
  roleContainerState roleState;
  String textEditedVal;
  Role _dataToAdd = new Role();
  //search
  bool searchClicked = false;
  String _searchResult = '';
  List<RoleJson> _filtredRoles;
  List<RoleJson> _listRoles;
  TextEditingController _controller = TextEditingController();
  bool searshing = false;

  @override
  void initState() {
    super.initState();
    roleState = roleContainerState.showRoles;
    rolepageProvider().getUserData(context).then((value) => _listRoles = value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: case2(
            roleState,
            {
              roleContainerState.showRoles: getTableWidget(),
              roleContainerState.addRole: getAjoutroleWidget(),
              roleContainerState.showUtilisateurs: UtilisateurPageContainer()
            },
            getTableWidget()));
  }

  Widget getTableWidget() {
    return ChangeNotifierProvider<rolepageProvider>(
      create: (context) => rolepageProvider(),
      child: Consumer<rolepageProvider>(
        // ignore: missing_return
        builder: (context, provider, child) {
          if (provider.rolelist == null) {
            provider.getData(context);
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!searshing) {
            _filtredRoles = provider.rolelist;
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
                            label: Text('Nom'),
                          ),
                          DataColumn(
                            label: Text('Desc'),
                          ),
                          DataColumn(
                            label: Text(''),
                          ),
                        ],
                        rows: _filtredRoles.isNotEmpty
                            ? _filtredRoles
                                .map((data) => DataRow(cells: [
                                      DataCell(modifyinputField(
                                          data.id, 'nom', data.nom, provider)),
                                      DataCell(modifyinputField(data.id, 'desc',
                                          data.desc, provider)),
                                      DataCell(IconButton(
                                        icon: Icon(Icons.delete),
                                        hoverColor: Colors.transparent,
                                        color: Colors.red,
                                        iconSize: 17,
                                        onPressed: () {
                                          deleteRole(getSubID(data.id))
                                              .whenComplete(() {
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (context) {
                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 600),
                                                      () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  });
                                                  return AlertDialog(
                                                    title: Image.asset(
                                                      'assets/success.png',
                                                      height: 50,
                                                      width: 50,
                                                    ),
                                                    content: Text(
                                                      "role supprimer!",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  );
                                                });
                                            provider.getData(context);
                                            setState(() {
                                              _filtredRoles = provider.rolelist;
                                              _listRoles = _filtredRoles;
                                            });
                                          });
                                        },
                                      ))
                                    ]))
                                .toList()
                            : [],
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
                          searchrole();
                        });
                      },
                      decoration: new InputDecoration(
                          hintText: "Entrer le nom de role",
                          suffixIcon: IconButton(
                            icon: Icon(FontAwesomeIcons.search),
                            iconSize: 17,
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            hoverColor: Colors.transparent,
                            color: Colors.grey[800],
                            onPressed: () {
                              setState(() {
                                searchrole();
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
                  heroTag: "search_role",
                  backgroundColor: Colors.amber[700],
                  child: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchClicked = !searchClicked;
                      _controller.clear();
                      _searchResult = '';
                      if (!searchClicked) searchrole();
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton(
                    heroTag: "add_role",
                    child: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        roleState = roleContainerState.addRole;
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
                        'Utilisateurs',
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
                          roleState = roleContainerState.showUtilisateurs;
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

  void searchrole() {
    if (_searchResult.isEmpty) {
      searshing = false;
      rolepageProvider()
          .getUserData(context)
          .then((value) => _listRoles = value)
          .whenComplete(() => _filtredRoles = _listRoles);
    } else {
      searshing = true;
      _filtredRoles = _listRoles
          .where((element) => element.nom.startsWith(_searchResult))
          .toList();
    }
  }

  Widget modifyinputField(
      String id, String mykey, String value, rolepageProvider provider) {
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
            modifyRoleSingleVal(getSubID(id), mykey, textEditedVal)
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
                        "Role Modifier!!",
                        textAlign: TextAlign.center,
                      ),
                    );
                  });
              provider.getData(context);
              setState(() {
                if (!searshing) {
                  _filtredRoles = provider.rolelist;
                  _listRoles = _filtredRoles;
                }
              });
            });
            textEditedVal = null;
          }
        },
      )),
    );
  }

  Widget getAjoutroleWidget() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Text(
            "Ajouter role",
            style: TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),
          ),
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
                        labelText: "Nom",
                        suffixIcon: Icon(
                          FontAwesomeIcons.edit,
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
                    controller: _descController,
                    decoration: InputDecoration(
                        labelText: "Desc",
                        suffixIcon: Icon(
                          FontAwesomeIcons.edit,
                          size: 17,
                        )),
                  ),
                ),
              ),
              SizedBox(
                width: 7,
              ),
            ],
          ),
          SizedBox(
            height: 10,
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
                        roleState = roleContainerState.showRoles;
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
                    onPressed: () {
                      getDataFromControllers();
                      addRole(_dataToAdd).whenComplete(() {
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
                                  "Role Ajouter!",
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
        ]));
  }

  double getWidgetWidth(double nb) {
    return MediaQuery.of(context).size.width * nb / 1265;
  }

  double getWidgetHeight(double nb) {
    return MediaQuery.of(context).size.height * nb / 646;
  }

  //Controllers for add data
  final _nomController = TextEditingController();
  final _descController = TextEditingController();

  void getDataFromControllers() {
    _dataToAdd.setNom(_nomController.text.toLowerCase());
    _dataToAdd.setDesc(_descController.text.toLowerCase());
  }

  void clearAddPageControllers() {
    _nomController.clear();
    _descController.clear();
  }
}

enum roleContainerState {
  showRoles,
  addRole,
  showUtilisateurs,
}

class rolepageProvider extends ChangeNotifier {
  List<RoleJson> rolelist;

  Future getData(context) async {
    rolelist = List<RoleJson>();
    var roles;
    await getCollectionRoles().then((value) => roles = value);

    for (var c in roles) {
      rolelist.add(RoleJson.fromJson(c));
    }
    this.notifyListeners();
  }

  //
  Future<List<RoleJson>> getUserData(context) async {
    rolelist = List<RoleJson>();
    var roles;
    await getCollectionRoles().then((value) => roles = value);
    for (var c in roles) {
      rolelist.add(RoleJson.fromJson(c));
    }
    return rolelist;
  }
}
