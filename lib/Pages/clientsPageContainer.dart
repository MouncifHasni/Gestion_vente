import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_vente_app/model/client.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:provider/provider.dart';

class ClientsPageContainer extends StatefulWidget {
  @override
  _ClientsPageContainer createState() => _ClientsPageContainer();
}

class _ClientsPageContainer extends State<ClientsPageContainer>
    with SingleTickerProviderStateMixin {
  clientContainerState clientState;
  String textEditedVal;
  Client _dataTomodify = new Client();
  Client _dataToAdd = new Client();
  //search
  bool searchClicked = false;
  String _searchResult = '';
  List<ClientJson> _filteredUser;
  List<ClientJson> _listUser;
  TextEditingController _controller = TextEditingController();
  bool searshing = false;

  @override
  Future<void> initState() {
    super.initState();
    setdataToModify(null);
    clientState = clientContainerState.showClients;
    ClientpageProvider()
        .getUserData(context)
        .then((value) => _listUser = value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: case2(
            clientState,
            {
              clientContainerState.showClients: getTableWidget(),
              clientContainerState.addClient: getAjoutClientWidget(),
              clientContainerState.modifyClient:
                  getmodifyClientWidget(_dataTomodify)
            },
            getTableWidget()));
  }

  Widget getTableWidget() {
    return ChangeNotifierProvider<ClientpageProvider>(
      create: (context) => ClientpageProvider(),
      child: Consumer<ClientpageProvider>(
        // ignore: missing_return
        builder: (context, provider, child) {
          if (provider.clientlist == null) {
            provider.getData(context);
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!searshing) {
            _filteredUser = provider.clientlist;
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
                                        clientState =
                                            clientContainerState.modifyClient;
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
                                      deleteClient(getSubID(data.id))
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
                                                  "Client supprimer!",
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            });
                                        provider.getData(context);
                                        setState(() {
                                          _filteredUser = provider.clientlist;
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
                          searchClient();
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
                                searchClient();
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
                      if (!searchClicked) searchClient();
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
                        clientState = clientContainerState.addClient;
                      });
                    }),
              )
            ],
          );
        },
      ),
    );
  }

  void searchClient() {
    if (_searchResult.isEmpty) {
      searshing = false;
      ClientpageProvider()
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
      String id, String mykey, String value, ClientpageProvider provider) {
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
            modifyClientSingleVal(getSubID(id), mykey, textEditedVal)
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
                        "Client Modifier!!",
                        textAlign: TextAlign.center,
                      ),
                    );
                  });
              provider.getData(context);
              setState(() {
                if (!searshing) {
                  _filteredUser = provider.clientlist;
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

  Widget getmodifyClientWidget(Client data) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Modifier Client",
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Livraison :",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 5,
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
                      controller: _villelivraisonControllermodify,
                      decoration: InputDecoration(
                          labelText: "Ville Livraison",
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
                      controller: _payslivraisonControllermodify,
                      decoration: InputDecoration(
                          labelText: "Pays Livraison",
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
                      //initialValue: data.getCodepostalelivraison(),
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      controller: _codepostalelivraisonControllermodify,
                      decoration: InputDecoration(
                          labelText: "Code Postale Livraison",
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
                Container(
                  color: Colors.white,
                  width: getWidgetWidth(653),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    controller: _adresselivraisonControllermodify,
                    decoration: InputDecoration(
                        labelText: "Adresse Livraion",
                        suffixIcon: Icon(
                          FontAwesomeIcons.addressBook,
                          size: 17,
                        )),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Paiment :",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 7,
            ),
            Row(
              children: [
                Container(
                  color: Colors.white,
                  width: getWidgetWidth(323),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    controller: _comptebancaireControllermodify,
                    decoration: InputDecoration(
                        labelText: "Num Compte Bancaire",
                        suffixIcon: Icon(
                          Icons.account_balance,
                          size: 17,
                        )),
                  ),
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
                          clientState = clientContainerState.showClients;
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
                        modifyClient(_dataTomodify)
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
                                      "Client Modifier!",
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
  final _villelivraisonController = TextEditingController();
  final _paysController = TextEditingController();
  final _payslivraisonController = TextEditingController();
  final _codepostaleController = TextEditingController();
  final _codepostalelivraisonController = TextEditingController();
  final _adresseController = TextEditingController();
  final _adresselivraisonController = TextEditingController();
  final _comptebancaireController = TextEditingController();

  //controllers for modify data
  final _nomControllermodify = TextEditingController();
  final _prenomControllermodify = TextEditingController();
  final _emailControllermodify = TextEditingController();
  final _teleControllermodify = TextEditingController();
  final _villeControllermodify = TextEditingController();
  final _villelivraisonControllermodify = TextEditingController();
  final _paysControllermodify = TextEditingController();
  final _payslivraisonControllermodify = TextEditingController();
  final _codepostaleControllermodify = TextEditingController();
  final _codepostalelivraisonControllermodify = TextEditingController();
  final _adresseControllermodify = TextEditingController();
  final _adresselivraisonControllermodify = TextEditingController();
  final _comptebancaireControllermodify = TextEditingController();

  Widget getAjoutClientWidget() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Ajouter Client",
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Livraison :",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 5,
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
                      controller: _villelivraisonController,
                      decoration: InputDecoration(
                          labelText: "Ville Livraison",
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
                      controller: _payslivraisonController,
                      decoration: InputDecoration(
                          labelText: "Pays Livraison",
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
                      controller: _codepostalelivraisonController,
                      decoration: InputDecoration(
                          labelText: "Code Postale Livraison",
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
                Container(
                  color: Colors.white,
                  width: getWidgetWidth(653),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    controller: _adresselivraisonController,
                    decoration: InputDecoration(
                        labelText: "Adresse Livraion",
                        suffixIcon: Icon(
                          FontAwesomeIcons.addressBook,
                          size: 17,
                        )),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Paiment :",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 7,
            ),
            Row(
              children: [
                Container(
                  color: Colors.white,
                  width: getWidgetWidth(323),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    controller: _comptebancaireController,
                    decoration: InputDecoration(
                        labelText: "Num Compte Bancaire",
                        suffixIcon: Icon(
                          Icons.account_balance,
                          size: 17,
                        )),
                  ),
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
                          clientState = clientContainerState.showClients;
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
                        addClient(_dataToAdd).whenComplete(() {
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
                                    "Client Ajouter!",
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

  void setdataToModify(ClientJson data) {
    String val = '';
    if (data == null) {
      _dataTomodify.setNom(val);
      _dataTomodify.setPrenom(val);
      _dataTomodify.setAdresse(val);
      _dataTomodify.setAdresselivraison(val);
      _dataTomodify.setCodepostale(val);
      _dataTomodify.setEmail(val);
      _dataTomodify.setPays(val);
      _dataTomodify.setTele(val);
      _dataTomodify.setVille(val);
      _dataTomodify.setVillelivraison(val);
      _dataTomodify.setPayslivraison(val);
      _dataTomodify.setCodepostalelivraison(val);
      _dataTomodify.setNumcomptebancaire(val);
    } else {
      _dataTomodify.setId(data.id);
      _dataTomodify.setNom(data.nom);
      _dataTomodify.setPrenom(data.prenom);
      _dataTomodify.setAdresse(data.adresse);
      _dataTomodify.setAdresselivraison(data.adresselivraison);
      _dataTomodify.setCodepostale(data.codepostale);
      _dataTomodify.setEmail(data.email);
      _dataTomodify.setPays(data.pays);
      _dataTomodify.setTele(data.tele);
      _dataTomodify.setVille(data.ville);
      _dataTomodify.setVillelivraison(data.villelivraison);
      _dataTomodify.setPayslivraison(data.payslivraison);
      _dataTomodify.setCodepostalelivraison(data.codepostalelivraison);
      _dataTomodify.setNumcomptebancaire(data.numcomptebancaire);
    }
  }

  void getDataFromControllers() {
    _dataToAdd.setNom(_nomController.text);
    _dataToAdd.setPrenom(_prenomController.text);
    _dataToAdd.setAdresse(_adresseController.text);
    _dataToAdd.setAdresselivraison(_adresselivraisonController.text);
    _dataToAdd.setCodepostale(_codepostaleController.text);
    _dataToAdd.setEmail(_emailController.text);
    _dataToAdd.setPays(_paysController.text);
    _dataToAdd.setTele(_teleController.text);
    _dataToAdd.setVille(_villeController.text);
    _dataToAdd.setVillelivraison(_villelivraisonController.text);
    _dataToAdd.setPayslivraison(_payslivraisonController.text);
    _dataToAdd.setCodepostalelivraison(_codepostalelivraisonController.text);
    _dataToAdd.setNumcomptebancaire(_comptebancaireController.text);
  }

  void clearAddPageControllers() {
    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
    _teleController.clear();
    _villeController.clear();
    _villelivraisonController.clear();
    _paysController.clear();
    _payslivraisonController.clear();
    _codepostaleController.clear();
    _codepostalelivraisonController.clear();
    _adresseController.clear();
    _adresselivraisonController.clear();
    _comptebancaireController.clear();
  }

  void setModifyControllersData(ClientJson data) {
    _nomControllermodify.text = data.nom;
    _prenomControllermodify.text = data.prenom;
    _emailControllermodify.text = data.email;
    _teleControllermodify.text = data.tele;
    _villeControllermodify.text = data.ville;
    _villelivraisonControllermodify.text = data.villelivraison;
    _paysControllermodify.text = data.pays;
    _payslivraisonControllermodify.text = data.payslivraison;
    _codepostaleControllermodify.text = data.codepostale;
    _codepostalelivraisonControllermodify.text = data.codepostalelivraison;
    _adresseControllermodify.text = data.adresse;
    _adresselivraisonControllermodify.text = data.adresselivraison;
    _comptebancaireControllermodify.text = data.numcomptebancaire;
  }

  void getModifyDataFromControllers() {
    _dataTomodify.setNom(_nomControllermodify.text);
    _dataTomodify.setPrenom(_prenomControllermodify.text);
    _dataTomodify.setAdresse(_adresseControllermodify.text);
    _dataTomodify.setAdresselivraison(_adresselivraisonControllermodify.text);
    _dataTomodify.setCodepostale(_codepostaleControllermodify.text);
    _dataTomodify.setEmail(_emailControllermodify.text);
    _dataTomodify.setPays(_paysControllermodify.text);
    _dataTomodify.setTele(_teleControllermodify.text);
    _dataTomodify.setVille(_villeControllermodify.text);
    _dataTomodify.setVillelivraison(_villelivraisonControllermodify.text);
    _dataTomodify.setPayslivraison(_payslivraisonControllermodify.text);
    _dataTomodify
        .setCodepostalelivraison(_codepostalelivraisonControllermodify.text);
    _dataTomodify.setNumcomptebancaire(_comptebancaireControllermodify.text);
  }
}

enum clientContainerState { showClients, addClient, modifyClient }

class ClientpageProvider extends ChangeNotifier {
  List<ClientJson> clientlist;

  Future getData(context) async {
    clientlist = List<ClientJson>();
    var clients;
    await getCollectionClients().then((value) => clients = value);

    for (var c in clients) {
      clientlist.add(ClientJson.fromJson(c));
    }
    this.notifyListeners();
  }

  //
  Future<List<ClientJson>> getUserData(context) async {
    clientlist = List<ClientJson>();
    var clients;
    await getCollectionClients().then((value) => clients = value);
    for (var c in clients) {
      clientlist.add(ClientJson.fromJson(c));
    }
    return clientlist;
  }
}
