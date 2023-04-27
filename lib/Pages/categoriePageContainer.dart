import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_vente_app/Pages/produitPageContainer.dart';
import 'package:gestion_vente_app/model/categorie.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:provider/provider.dart';

class CategoriePageContainer extends StatefulWidget {
  @override
  _CategoriePageContainer createState() => _CategoriePageContainer();
}

class _CategoriePageContainer extends State<CategoriePageContainer>
    with SingleTickerProviderStateMixin {
  categorieContainerState categorieState;
  String textEditedVal;
  Categorie _dataToAdd = new Categorie();
  //search
  bool searchClicked = false;
  String _searchResult = '';
  List<CategorieJson> _filteredUser;
  List<CategorieJson> _listUser;
  TextEditingController _controller = TextEditingController();
  bool searshing = false;

  @override
  void initState() {
    super.initState();
    categorieState = categorieContainerState.showCats;
    CategoriepageProvider()
        .getUserData(context)
        .then((value) => _listUser = value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: case2(
            categorieState,
            {
              categorieContainerState.showCats: getTableWidget(),
              categorieContainerState.addCat: getAjoutCategorieWidget(),
              categorieContainerState.showProduit: ProduitPageContainer()
            },
            getTableWidget()));
  }

  Widget getTableWidget() {
    return ChangeNotifierProvider<CategoriepageProvider>(
      create: (context) => CategoriepageProvider(),
      child: Consumer<CategoriepageProvider>(
        // ignore: missing_return
        builder: (context, provider, child) {
          if (provider.categorielist == null) {
            provider.getData(context);
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!searshing) {
            _filteredUser = provider.categorielist;
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
                        rows: _filteredUser.isNotEmpty
                            ? _filteredUser
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
                                          deleteCategorie(getSubID(data.id))
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
                                                      "Categorie supprimer!",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  );
                                                });
                                            provider.getData(context);
                                            setState(() {
                                              _filteredUser =
                                                  provider.categorielist;
                                              _listUser = _filteredUser;
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
                          searchCategorie();
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
                                searchCategorie();
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
                  heroTag: "search_Categorie",
                  backgroundColor: Colors.amber[700],
                  child: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchClicked = !searchClicked;
                      _controller.clear();
                      _searchResult = '';
                      if (!searchClicked) searchCategorie();
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton(
                    heroTag: "add_Categorie",
                    child: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        categorieState = categorieContainerState.addCat;
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
                        'Produits',
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
                          categorieState = categorieContainerState.showProduit;
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

  void searchCategorie() {
    if (_searchResult.isEmpty) {
      searshing = false;
      CategoriepageProvider()
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
      String id, String mykey, String value, CategoriepageProvider provider) {
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
            modifyCategorieSingleVal(getSubID(id), mykey, textEditedVal)
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
                        "Categorie Modifier!!",
                        textAlign: TextAlign.center,
                      ),
                    );
                  });
              provider.getData(context);
              setState(() {
                if (!searshing) {
                  _filteredUser = provider.categorielist;
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

  Widget getAjoutCategorieWidget() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Text(
            "Ajouter Categorie",
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
                        categorieState = categorieContainerState.showCats;
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
                      addCategorie(_dataToAdd).whenComplete(() {
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
                                  "Categorie Ajouter!",
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

enum categorieContainerState {
  showCats,
  addCat,
  showProduit,
}

class CategoriepageProvider extends ChangeNotifier {
  List<CategorieJson> categorielist;

  Future getData(context) async {
    categorielist = List<CategorieJson>();
    var categories;
    await getCollectionCategories().then((value) => categories = value);

    for (var c in categories) {
      categorielist.add(CategorieJson.fromJson(c));
    }
    this.notifyListeners();
  }

  //
  Future<List<CategorieJson>> getUserData(context) async {
    categorielist = List<CategorieJson>();
    var categories;
    await getCollectionCategories().then((value) => categories = value);
    for (var c in categories) {
      categorielist.add(CategorieJson.fromJson(c));
    }
    return categorielist;
  }
}
