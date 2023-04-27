import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_vente_app/model/fournisseur.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:provider/provider.dart';

class FournisseurContainerPage extends StatefulWidget {
  @override
  _FournisseurContainerPage createState() => _FournisseurContainerPage();
}

class _FournisseurContainerPage extends State<FournisseurContainerPage>
    with SingleTickerProviderStateMixin {
  fournisseurContainerState fournisseurState;
  String textEditedVal;
  Fournisseur _dataTomodify = new Fournisseur();
  Fournisseur _dataToAdd = new Fournisseur();
  //search
  bool searchClicked = false;
  String _searchResult = '';
  List<FournisseurJson> _filteredUser;
  List<FournisseurJson> _listUser;
  TextEditingController _controller = TextEditingController();
  bool searshing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setdataToModify(null);
    fournisseurState = fournisseurContainerState.showFournisseur;
    FournisseurpageProvider()
        .getUserData(context)
        .then((value) => _listUser = value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: case2(
            fournisseurState,
            {
              fournisseurContainerState.showFournisseur: getTableWidget(),
              fournisseurContainerState.addFournisseur:
                  getAjoutFournisseurWidget(),
              fournisseurContainerState.modifyFournisseur:
                  getmodifyFournisseurWidget(_dataTomodify)
            },
            getTableWidget()));
  }

  Widget getTableWidget() {
    return ChangeNotifierProvider<FournisseurpageProvider>(
      create: (context) => FournisseurpageProvider(),
      child: Consumer<FournisseurpageProvider>(
        // ignore: missing_return
        builder: (context, provider, child) {
          if (provider.fourniseeurlist == null) {
            provider.getData(context);
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!searshing) {
            _filteredUser = provider.fourniseeurlist;
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
                          DataColumn(
                            label: Text('Nom'),
                          ),
                          DataColumn(
                            label: Text('Prenom'),
                          ),
                          DataColumn(
                            label: Text('Email'),
                          ),
                          DataColumn(
                            label: Text('Tele'),
                          ),
                          DataColumn(
                            label: Text('Adresse'),
                          ),
                          DataColumn(
                            label: Text('Ville'),
                          ),
                          DataColumn(
                            label: Text('Pays'),
                          ),
                          DataColumn(
                            label: Text('CodePostale'),
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
                                    onPressed: () {
                                      setState(() {
                                        setdataToModify(data);
                                        setModifyControllersData(data);
                                        fournisseurState =
                                            fournisseurContainerState
                                                .modifyFournisseur;
                                      });
                                    },
                                  )),
                                  DataCell(modifyinputField(
                                      data.id, 'nom', data.nom, provider)),
                                  DataCell(modifyinputField(data.id, 'prenom',
                                      data.prenom, provider)),
                                  DataCell(modifyinputField(data.id, 'email',
                                      data.email, provider)), //
                                  DataCell(modifyinputField(
                                      data.id, 'tele', data.tele, provider)),
                                  DataCell(modifyinputField(data.id, 'adresse',
                                      data.adresse, provider)),
                                  DataCell(modifyinputField(
                                      data.id, 'ville', data.ville, provider)),
                                  DataCell(modifyinputField(
                                      data.id, 'pays', data.pays, provider)),
                                  DataCell(modifyinputField(
                                      data.id,
                                      'codepostale',
                                      data.codepostale,
                                      provider)),
                                  DataCell(IconButton(
                                    icon: Icon(Icons.delete),
                                    hoverColor: Colors.transparent,
                                    color: Colors.red,
                                    iconSize: 17,
                                    onPressed: () {
                                      deleteFournisseur(getSubID(data.id))
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
                                                  "Fournisseur supprimer!",
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            });
                                        provider.getData(context);
                                        setState(() {
                                          _filteredUser =
                                              provider.fourniseeurlist;
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
                          searchFournisseur();
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
                                searchFournisseur();
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
                  heroTag: "search_client",
                  backgroundColor: Colors.amber[700],
                  child: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchClicked = !searchClicked;
                      _controller.clear();
                      _searchResult = '';
                      if (!searchClicked) searchFournisseur();
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton(
                    heroTag: "add_client",
                    child: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        fournisseurState =
                            fournisseurContainerState.addFournisseur;
                      });
                    }),
              )
            ],
          );
        },
      ),
    );
  }

  void searchFournisseur() {
    if (_searchResult.isEmpty) {
      searshing = false;
      FournisseurpageProvider()
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
      String id, String mykey, String value, FournisseurpageProvider provider) {
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
            modifyFournisseurSingleVal(getSubID(id), mykey, textEditedVal)
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
                        "Fournisseur Modifier!!",
                        textAlign: TextAlign.center,
                      ),
                    );
                  });
              provider.getData(context);
              setState(() {
                if (!searshing) {
                  _filteredUser = provider.fourniseeurlist;
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

  Widget getmodifyFournisseurWidget(Fournisseur data) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Modifier Fournisseur",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w600),
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
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _nomControllermodify,
                      decoration: InputDecoration(
                          labelText: "Nom",
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
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _prenomControllermodify,
                      decoration: InputDecoration(
                          labelText: "Prenom",
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
                    width: getWidgetWidth(330),
                    child: TextFormField(
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
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    width: getWidgetWidth(280),
                    child: TextFormField(
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
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    width: getWidgetWidth(610) + 7,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _adresseControllermodify,
                      decoration: InputDecoration(
                          labelText: "Adresse",
                          suffixIcon: Icon(
                            FontAwesomeIcons.addressBook,
                            size: 17,
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
                  child: Container(
                    color: Colors.white,
                    width: getWidgetWidth(280),
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _villeControllermodify,
                      decoration: InputDecoration(
                          labelText: "Ville",
                          suffixIcon: Icon(
                            Icons.location_city,
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
                    width: getWidgetWidth(305),
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _paysControllermodify,
                      decoration: InputDecoration(
                          labelText: "Pays",
                          suffixIcon: Icon(
                            FontAwesomeIcons.city,
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
                    width: getWidgetWidth(305),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _codepostaleControllermodify,
                      decoration: InputDecoration(
                          labelText: "Code Postale",
                          suffixIcon: Icon(
                            FontAwesomeIcons.addressBook,
                            size: 17,
                          )),
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
                          fournisseurState =
                              fournisseurContainerState.showFournisseur;
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
                        getModifyDataFromControllers();
                        modifyFournisseur(_dataTomodify)
                            .whenComplete(() => showDialog(
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
                                      "Fournisseur Modifier!",
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }));
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

  //Controllers for add data
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleController = TextEditingController();
  final _villeController = TextEditingController();
  final _paysController = TextEditingController();
  final _codepostaleController = TextEditingController();
  final _adresseController = TextEditingController();

  //controllers for modify data
  final _nomControllermodify = TextEditingController();
  final _prenomControllermodify = TextEditingController();
  final _emailControllermodify = TextEditingController();
  final _teleControllermodify = TextEditingController();
  final _villeControllermodify = TextEditingController();
  final _paysControllermodify = TextEditingController();
  final _codepostaleControllermodify = TextEditingController();
  final _adresseControllermodify = TextEditingController();

  Widget getAjoutFournisseurWidget() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Ajouter Fournisseur",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w600),
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
                      controller: _prenomController,
                      decoration: InputDecoration(
                          labelText: "Prenom",
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
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
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
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    width: getWidgetWidth(610) + 7,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _adresseController,
                      decoration: InputDecoration(
                          labelText: "Adresse",
                          suffixIcon: Icon(
                            FontAwesomeIcons.addressBook,
                            size: 17,
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
                  child: Container(
                    color: Colors.white,
                    width: getWidgetWidth(280),
                    child: TextField(
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _villeController,
                      decoration: InputDecoration(
                          labelText: "Ville",
                          suffixIcon: Icon(
                            Icons.location_city,
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
                    width: getWidgetWidth(305),
                    child: TextField(
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _paysController,
                      decoration: InputDecoration(
                          labelText: "Pays",
                          suffixIcon: Icon(
                            FontAwesomeIcons.city,
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
                    width: getWidgetWidth(305),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _codepostaleController,
                      decoration: InputDecoration(
                          labelText: "Code Postale",
                          suffixIcon: Icon(
                            FontAwesomeIcons.addressBook,
                            size: 17,
                          )),
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
                          fournisseurState =
                              fournisseurContainerState.showFournisseur;
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
                        addFournisseur(_dataToAdd).whenComplete(() {
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
                                    "Fournisseur Ajouter!",
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

  void setdataToModify(FournisseurJson data) {
    String val = '';
    if (data == null) {
      _dataTomodify.setNom(val);
      _dataTomodify.setPrenom(val);
      _dataTomodify.setAdresse(val);
      _dataTomodify.setCodepostale(val);
      _dataTomodify.setEmail(val);
      _dataTomodify.setPays(val);
      _dataTomodify.setTele(val);
      _dataTomodify.setVille(val);
    } else {
      _dataTomodify.setId(data.id);
      _dataTomodify.setNom(data.nom);
      _dataTomodify.setPrenom(data.prenom);
      _dataTomodify.setAdresse(data.adresse);
      _dataTomodify.setCodepostale(data.codepostale);
      _dataTomodify.setEmail(data.email);
      _dataTomodify.setPays(data.pays);
      _dataTomodify.setTele(data.tele);
      _dataTomodify.setVille(data.ville);
    }
  }

  void getDataFromControllers() {
    _dataToAdd.setNom(_nomController.text);
    _dataToAdd.setPrenom(_prenomController.text);
    _dataToAdd.setAdresse(_adresseController.text);
    _dataToAdd.setCodepostale(_codepostaleController.text);
    _dataToAdd.setEmail(_emailController.text);
    _dataToAdd.setPays(_paysController.text);
    _dataToAdd.setTele(_teleController.text);
    _dataToAdd.setVille(_villeController.text);
  }

  void clearAddPageControllers() {
    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
    _teleController.clear();
    _villeController.clear();
    _paysController.clear();
    _codepostaleController.clear();
    _adresseController.clear();
  }

  void setModifyControllersData(FournisseurJson data) {
    _nomControllermodify.text = data.nom;
    _prenomControllermodify.text = data.prenom;
    _emailControllermodify.text = data.email;
    _teleControllermodify.text = data.tele;
    _villeControllermodify.text = data.ville;
    _paysControllermodify.text = data.pays;
    _codepostaleControllermodify.text = data.codepostale;
    _adresseControllermodify.text = data.adresse;
  }

  void getModifyDataFromControllers() {
    _dataTomodify.setNom(_nomControllermodify.text);
    _dataTomodify.setPrenom(_prenomControllermodify.text);
    _dataTomodify.setAdresse(_adresseControllermodify.text);
    _dataTomodify.setCodepostale(_codepostaleControllermodify.text);
    _dataTomodify.setEmail(_emailControllermodify.text);
    _dataTomodify.setPays(_paysControllermodify.text);
    _dataTomodify.setTele(_teleControllermodify.text);
    _dataTomodify.setVille(_villeControllermodify.text);
  }
}

enum fournisseurContainerState {
  showFournisseur,
  addFournisseur,
  modifyFournisseur
}

class FournisseurpageProvider extends ChangeNotifier {
  List<FournisseurJson> fourniseeurlist;

  Future getData(context) async {
    fourniseeurlist = List<FournisseurJson>();
    var fournisseurs;
    await getCollectionFournisseurs().then((value) => fournisseurs = value);

    for (var c in fournisseurs) {
      fourniseeurlist.add(FournisseurJson.fromJson(c));
    }
    this.notifyListeners();
  }

  //
  Future<List<FournisseurJson>> getUserData(context) async {
    fourniseeurlist = List<FournisseurJson>();
    var fournisseurs;
    await getCollectionFournisseurs().then((value) => fournisseurs = value);
    for (var c in fournisseurs) {
      fourniseeurlist.add(FournisseurJson.fromJson(c));
    }
    return fourniseeurlist;
  }
}
