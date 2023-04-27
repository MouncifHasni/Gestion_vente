import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_vente_app/Pages/categoriePageContainer.dart';
import 'package:gestion_vente_app/model/categorie.dart';
import 'package:gestion_vente_app/model/fournisseur.dart';
import 'package:gestion_vente_app/model/produit.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:provider/provider.dart';

class ProduitPageContainer extends StatefulWidget {
  @override
  _ProduitPageContainer createState() => _ProduitPageContainer();
}

class _ProduitPageContainer extends State<ProduitPageContainer>
    with SingleTickerProviderStateMixin {
  produitContainerState ProduitState;
  String textEditedVal;
  Produit _dataTomodify = new Produit();
  Produit _dataToAdd = new Produit();
  //search
  bool searchClicked = false;
  String _searchResult = '';
  List<ProduitJson> _filteredUser;
  List<ProduitJson> _listUser;
  TextEditingController _controller = TextEditingController();
  bool searshing = false;
  //lists
  List<FournisseurJson> _listFournisseur;
  String _fournisseurValueChoose;
  String _fournisseurValueChoosemodify;
  List<CategorieJson> _listcategories;
  String _categorieValueChoose;
  String _categorieValueChoosemodify;

  @override
  void initState() {
    ProduitpageProvider()
        .getFournisseursData(context)
        .then((value) => _listFournisseur = value);
    ProduitpageProvider()
        .getCategoriessData(context)
        .then((value) => _listcategories = value);
    super.initState();
    setdataToModify(null);
    ProduitState = produitContainerState.showProduit;
    ProduitpageProvider()
        .getUserData(context)
        .then((value) => _listUser = value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: case2(
            ProduitState,
            {
              produitContainerState.showProduit: getTableWidget(),
              produitContainerState.addProduit: getAjoutProduitWidget(),
              produitContainerState.modifyProduit:
                  getmodifyProduitWidget(_dataTomodify),
              produitContainerState.showCats: CategoriePageContainer()
            },
            getTableWidget()));
  }

  Widget getTableWidget() {
    return ChangeNotifierProvider<ProduitpageProvider>(
      create: (context) => ProduitpageProvider(),
      child: Consumer<ProduitpageProvider>(
        // ignore: missing_return
        builder: (context, provider, child) {
          if (provider.produitlist == null) {
            provider.getData(context);
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!searshing) {
            _filteredUser = provider.produitlist;
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
                            label: Text('Desc'),
                          ),
                          DataColumn(
                            label: Text('Prix (Dhs)'),
                          ),
                          DataColumn(
                            label: Text('Qte'),
                          ),
                          DataColumn(
                            label: Text('Categorie'),
                          ),
                          DataColumn(
                            label: Text('Fournisseur'),
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
                                        ProduitState =
                                            produitContainerState.modifyProduit;
                                      });
                                    },
                                  )),
                                  DataCell(modifyinputField(
                                      data.id, 'nom', data.nom, provider)),
                                  DataCell(modifyinputField(
                                      data.id, 'desc', data.desc, provider)),
                                  DataCell(modifyinputField(
                                      data.id, 'prix', data.prix, provider)), //
                                  DataCell(modifyinputField(
                                      data.id, 'qte', data.qte, provider)),
                                  DataCell(Text(getNomCategorie(
                                          _listcategories, data.categorie)
                                      .toLowerCase())),
                                  DataCell(Text(getNometPrenomFournisseur(
                                          _listFournisseur, data.fournisseur)
                                      .toLowerCase())),
                                  DataCell(IconButton(
                                    icon: Icon(Icons.delete),
                                    hoverColor: Colors.transparent,
                                    color: Colors.red,
                                    iconSize: 17,
                                    onPressed: () {
                                      deleteProduit(getSubID(data.id))
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
                                                  "Produit supprimer!",
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            });
                                        provider.getData(context);
                                        setState(() {
                                          _filteredUser = provider.produitlist;
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
                          searchProduit();
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
                                searchProduit();
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
                  heroTag: "search_produit",
                  backgroundColor: Colors.amber[700],
                  child: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchClicked = !searchClicked;
                      _controller.clear();
                      _searchResult = '';
                      if (!searchClicked) searchProduit();
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton(
                    heroTag: "add_produit",
                    child: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        ProduitState = produitContainerState.addProduit;
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
                        'Categories',
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
                          ProduitState = produitContainerState.showCats;
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

  void searchProduit() {
    if (_searchResult.isEmpty) {
      searshing = false;
      ProduitpageProvider()
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
      String id, String mykey, String value, ProduitpageProvider provider) {
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
            modifyProduitSingleVal(getSubID(id), mykey, textEditedVal)
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
                        "Produit Modifier!!",
                        textAlign: TextAlign.center,
                      ),
                    );
                  });
              provider.getData(context);
              setState(() {
                if (!searshing) {
                  _filteredUser = provider.produitlist;
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

  Widget getmodifyProduitWidget(Produit data) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Text(
            "Modifier Produit",
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
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    controller: _nomControllermodify,
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
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    controller: _descControllermodify,
                    decoration: InputDecoration(
                        labelText: "desc",
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
                  width: getWidgetWidth(330),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    controller: _prixControllermodify,
                    decoration: InputDecoration(
                        labelText: "Prix",
                        suffixIcon: Icon(
                          FontAwesomeIcons.dollarSign,
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
                    controller: _qteControllermodify,
                    decoration: InputDecoration(
                        labelText: "Qte",
                        suffixIcon: Icon(
                          Icons.production_quantity_limits,
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
                  //height: 69,
                  width: getWidgetWidth(610) + 7,
                  child: DropdownButton(
                    itemHeight: 66,
                    isExpanded: true,
                    hint: Text('Choisire une categorie'),
                    value: _categorieValueChoosemodify,
                    onChanged: (newVal) {
                      setState(() {
                        _categorieValueChoosemodify = newVal;
                      });
                    },
                    items: _listcategories != null
                        ? _listcategories
                            .map((data) => DropdownMenuItem(
                                value: data.nom, child: Text(data.nom)))
                            .toList()
                        : null,
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
                    child: DropdownButton(
                      isExpanded: true,
                      itemHeight: 66,
                      hint: Text('Choisire un fournisseur'),
                      value: _fournisseurValueChoosemodify,
                      onChanged: (newVal) {
                        setState(() {
                          _fournisseurValueChoosemodify = newVal;
                        });
                      },
                      items: _listFournisseur != null
                          ? _listFournisseur
                              .map((data) => DropdownMenuItem(
                                  value: data.nom + ' ' + data.prenom,
                                  child: Text(data.nom + ' ' + data.prenom)))
                              .toList()
                          : null,
                    )),
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
                        ProduitState = produitContainerState.showProduit;
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
                      modifyProduit(_dataTomodify)
                          .whenComplete(() => showDialog(
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
                                    "Produit Modifier!",
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
          )
        ]));
  }

  //Controllers for add data
  final _nomController = TextEditingController();
  final _descController = TextEditingController();
  final _prixController = TextEditingController();
  final _qteController = TextEditingController();

  //controllers for modify data
  final _nomControllermodify = TextEditingController();
  final _prixControllermodify = TextEditingController();
  final _qteControllermodify = TextEditingController();
  final _descControllermodify = TextEditingController();

  Widget getAjoutProduitWidget() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Text(
            "Ajouter Produit",
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
              Expanded(
                child: Container(
                  color: Colors.white,
                  width: getWidgetWidth(330),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    controller: _prixController,
                    decoration: InputDecoration(
                        labelText: "Prix",
                        suffixIcon: Icon(
                          FontAwesomeIcons.dollarSign,
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
                    controller: _qteController,
                    decoration: InputDecoration(
                        labelText: "Qte",
                        suffixIcon: Icon(
                          Icons.production_quantity_limits,
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
                    hint: Text('Choisire une categorie'),
                    value: _categorieValueChoose,
                    onChanged: (newVal) {
                      setState(() {
                        _categorieValueChoose = newVal;
                      });
                    },
                    items: _listcategories != null
                        ? _listcategories
                            .map((data) => DropdownMenuItem(
                                value: data.nom, child: Text(data.nom)))
                            .toList()
                        : null,
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
                      isExpanded: true,
                      itemHeight: 66,
                      hint: Text('Choisire un fournisseur'),
                      value: _fournisseurValueChoose,
                      onChanged: (newVal) {
                        setState(() {
                          _fournisseurValueChoose = newVal;
                        });
                      },
                      items: _listFournisseur != null
                          ? _listFournisseur
                              .map((data) => DropdownMenuItem(
                                  value: data.nom + ' ' + data.prenom,
                                  child: Text(data.nom + ' ' + data.prenom)))
                              .toList()
                          : null,
                    )),
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
                        ProduitState = produitContainerState.showProduit;
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
                      addProduit(_dataToAdd).whenComplete(() {
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
                                  "Produit Ajouter!",
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

  void setdataToModify(ProduitJson data) {
    String val = '';
    if (data == null) {
      _dataTomodify.setNom(val);
      _dataTomodify.setDesc(val);
      _dataTomodify.setPrix(val);
      _dataTomodify.setQte(val);
      _dataTomodify.setCategorie(val);
      _dataTomodify.setFournisseur(val);
    } else {
      _dataTomodify.setId(data.id);
      _dataTomodify.setNom(data.nom);
      _dataTomodify.setDesc(data.desc);
      _dataTomodify.setPrix(data.prix);
      _dataTomodify.setQte(data.qte);
      _dataTomodify.setCategorie(data.categorie);
      _dataTomodify.setFournisseur(data.fournisseur);
    }
  }

  void getDataFromControllers() {
    _dataToAdd.setNom(_nomController.text.toLowerCase());
    _dataToAdd.setDesc(_descController.text.toLowerCase());
    _dataToAdd.setPrix(_prixController.text);
    _dataToAdd
        .setCategorie(getIdCategorie(_listcategories, _categorieValueChoose));
    _dataToAdd.setQte(_qteController.text);
    _dataToAdd.setFournisseur(
        getIdFournisseur(_listFournisseur, _fournisseurValueChoose));
  }

  void clearAddPageControllers() {
    _nomController.clear();
    _descController.clear();
    _prixController.clear();
    _qteController.clear();
    setState(() {
      _fournisseurValueChoose = null;
      _categorieValueChoose = null;
    });
  }

  void setModifyControllersData(ProduitJson data) {
    _nomControllermodify.text = data.nom;
    _descControllermodify.text = data.desc;
    _prixControllermodify.text = data.prix;
    _qteControllermodify.text = data.qte;
    setState(() {
      _fournisseurValueChoosemodify =
          getNometPrenomFournisseur(_listFournisseur, data.fournisseur);
      _categorieValueChoosemodify =
          getNomCategorie(_listcategories, data.categorie);
    });
  }

  void getModifyDataFromControllers() {
    _dataTomodify.setNom(_nomControllermodify.text);
    _dataTomodify.setDesc(_descControllermodify.text);
    _dataTomodify.setPrix(_prixControllermodify.text);
    _dataTomodify.setQte(_qteControllermodify.text);
    _dataTomodify.setFournisseur(
        getIdFournisseur(_listFournisseur, _fournisseurValueChoosemodify));
    _dataTomodify.setCategorie(
        getIdCategorie(_listcategories, _categorieValueChoosemodify));
  }
}

enum produitContainerState {
  showProduit,
  addProduit,
  modifyProduit,
  showCats,
}

class ProduitpageProvider extends ChangeNotifier {
  List<ProduitJson> produitlist;
  List<FournisseurJson> fourniseeurlist;
  List<CategorieJson> categorielist;

  Future getData(context) async {
    produitlist = List<ProduitJson>();
    var produits;
    await getCollectionProduits().then((value) => produits = value);

    for (var c in produits) {
      produitlist.add(ProduitJson.fromJson(c));
    }
    this.notifyListeners();
  }

  //
  Future<List<ProduitJson>> getUserData(context) async {
    produitlist = List<ProduitJson>();
    var produits;
    await getCollectionProduits().then((value) => produits = value);
    for (var c in produits) {
      produitlist.add(ProduitJson.fromJson(c));
    }
    return produitlist;
  }

  Future<List<FournisseurJson>> getFournisseursData(context) async {
    fourniseeurlist = List<FournisseurJson>();
    var fournisseurs;
    await getCollectionFournisseurs().then((value) => fournisseurs = value);
    for (var c in fournisseurs) {
      fourniseeurlist.add(FournisseurJson.fromJson(c));
    }
    return fourniseeurlist;
  }

  Future<List<CategorieJson>> getCategoriessData(context) async {
    categorielist = List<CategorieJson>();
    var categories;
    await getCollectionCategories().then((value) => categories = value);
    for (var c in categories) {
      categorielist.add(CategorieJson.fromJson(c));
    }
    return categorielist;
  }
}
