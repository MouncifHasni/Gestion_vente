import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_vente_app/model/client.dart';
import 'package:gestion_vente_app/model/facture.dart';
import 'package:gestion_vente_app/model/invoice.dart';
import 'package:gestion_vente_app/model/produit.dart';
import 'package:gestion_vente_app/model/vente.dart';
import 'package:gestion_vente_app/utility/pdfInvoiceApi.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:provider/provider.dart';

class VentesPageCotainer extends StatefulWidget {
  @override
  _VentesPageCotainer createState() => _VentesPageCotainer();
}

class _VentesPageCotainer extends State<VentesPageCotainer>
    with SingleTickerProviderStateMixin {
  VenteContainerState VenteState;
  SelectProductsParent parentSelectProductState;
  String textEditedVal;
  Vente _dataTomodify = new Vente();
  Vente _dataToAdd = new Vente();
  //search
  bool searchClicked = false;
  String _searchResult = '';
  List<VenteJson> _filteredUser;
  List<VenteJson> _listUser;
  TextEditingController _controller = TextEditingController();
  bool searshing = false;
  List<ClientJson> _listClients;
  List<ClientJson> _listClientsFiltred;
  String prix_totale = '0';
  bool _facturationisChecked = false;

  @override
  void initState() {
    super.initState();
    getClientsList().then((value) {
      _listClients = value;
      _listClientsFiltred = value;
    });
    ProduitpageProvider().getUserData(context).then((value) {
      _listproduitSelect = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: case2(
            VenteState,
            {
              VenteContainerState.showVentes: getTableWidget(),
              VenteContainerState.addVente: getAjoutVenteWidget(),
              VenteContainerState.modifyVente:
                  getmodifyVenteWidget(_dataTomodify),
              VenteContainerState.selectProduits: getSelectProductWidget()
            },
            getTableWidget()));
  }

  Widget getTableWidget() {
    return ChangeNotifierProvider<VentepageProvider>(
      create: (context) => VentepageProvider(),
      child: Consumer<VentepageProvider>(
        // ignore: missing_return
        builder: (context, provider, child) {
          if (provider.ventelist == null) {
            provider.getData(context);
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!searshing) {
            _filteredUser = provider.ventelist;
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
                            label: Text('ID'),
                          ),
                          DataColumn(
                            label: Text('Facturer'),
                          ),
                          DataColumn(
                            label: Text('Client'),
                          ),
                          DataColumn(
                            label: Text('Facturation'),
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
                            label: Text('Totale'),
                          ),
                          DataColumn(
                            label: Text(''),
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
                                        setModifyWidgetData(data);
                                        VenteState =
                                            VenteContainerState.modifyVente;
                                      });
                                    },
                                  )),
                                  DataCell(Text(data.id)),
                                  DataCell(data.facture != null
                                      ? Icon(
                                          Icons.download_done_rounded,
                                          color: Colors.green,
                                        )
                                      : Text('')),
                                  DataCell(Text(getNomClientfromID(
                                      _listClients, data.client))),
                                  DataCell(Text(data.facturation)),
                                  DataCell(Text(data.adresse)),
                                  DataCell(Text(data.ville)),
                                  DataCell(Text(data.pays)),
                                  DataCell(Text(data.totale)),
                                  DataCell(IconButton(
                                    icon: Icon(Icons.delete),
                                    hoverColor: Colors.transparent,
                                    color: Colors.red,
                                    iconSize: 17,
                                    onPressed: () {
                                      deleteVente(data.id).whenComplete(() {
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
                                                  "Vente supprimer!",
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            });
                                        provider.getData(context);
                                        setState(() {
                                          _filteredUser = provider.ventelist;
                                          _listUser = _filteredUser;
                                        });
                                      });
                                    },
                                  )),
                                  DataCell(IconButton(
                                    icon: Icon(FontAwesomeIcons.fileInvoice),
                                    hoverColor: Colors.transparent,
                                    color: Colors.green,
                                    iconSize: 17,
                                    onPressed: () async {
                                      Vente vente = new Vente();
                                      vente.id = data.id;
                                      vente.adresse = data.adresse;
                                      vente.ville = data.ville;
                                      vente.pays = data.pays;
                                      vente.codepostale = data.codepostale;
                                      vente.client = getNomClientfromID(
                                          _listClients, data.client);
                                      vente.tele = data.tele;
                                      vente.email = data.email;
                                      vente.emailfacturation =
                                          data.emailfacturation;
                                      vente.telefacturation =
                                          data.telefacturation;
                                      vente.adressefacturation =
                                          data.adressefacturation;
                                      vente.villefacturation =
                                          data.villefacturation;
                                      vente.paysfacturation =
                                          data.paysfacturation;
                                      vente.codepostalefacturation =
                                          data.codepostalefacturation;
                                      vente.facturation =
                                          data.facturation.isEmpty
                                              ? formatDate(DateTime.now(),
                                                  [dd, '-', mm, '-', yyyy])
                                              : data.facturation;
                                      vente.totale = data.totale;
                                      List<SelectedProduitModel> items =
                                          getListSelectedProducts_s(
                                              _listproduitSelect,
                                              data.produits);

                                      Invoice invoice = new Invoice(
                                          vente: vente, items: items);
                                      await genererFacture(invoice);
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
                          searchVente();
                        });
                      },
                      decoration: new InputDecoration(
                          hintText: "Entrer ID",
                          suffixIcon: IconButton(
                            icon: Icon(FontAwesomeIcons.search),
                            iconSize: 17,
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            hoverColor: Colors.transparent,
                            color: Colors.grey[800],
                            onPressed: () {
                              setState(() {
                                searchVente();
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
                  heroTag: "search_Vente",
                  backgroundColor: Colors.amber[700],
                  child: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchClicked = !searchClicked;
                      _controller.clear();
                      _searchResult = '';
                      if (!searchClicked) searchVente();
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton(
                    heroTag: "add_Vente",
                    child: Icon(Icons.add),
                    onPressed: () {
                      clearModifyPageContollers();
                      setState(() {
                        VenteState = VenteContainerState.addVente;
                      });
                    }),
              )
            ],
          );
        },
      ),
    );
  }

  void searchVente() {
    if (_searchResult.isEmpty) {
      searshing = false;
      VentepageProvider()
          .getUserData(context)
          .then((value) => _listUser = value)
          .whenComplete(() => _filteredUser = _listUser);
    } else {
      searshing = true;
      _filteredUser = _listUser
          .where((element) => element.id.startsWith(_searchResult))
          .toList();
    }
  }

  Widget getmodifyVenteWidget(Vente data) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: ListView(
          children: [
            Center(
              child: Text(
                "Modifier Vente",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Container(
                  color: Colors.white,
                  width: getWidgetWidth(280),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    enabled: false,
                    controller: _clientControllermodify,
                    decoration: InputDecoration(
                      labelText: "Client",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.plusCircle,
                    color: Colors.orange[900],
                  ),
                  iconSize: 17,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            StatefulBuilder(builder: (context, setState) {
                              return AlertDialog(
                                  contentPadding:
                                      EdgeInsets.only(left: 25, right: 25),
                                  title:
                                      Center(child: Text("Choisir un client")),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  content: Container(
                                    padding: EdgeInsets.only(top: 5),
                                    height: MediaQuery.of(context).size.height *
                                        0.5,
                                    width: 300,
                                    child: ListView.builder(
                                      itemCount: _listClientsFiltred.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index == 0) {
                                          return Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                3, 3, 3, 3),
                                            child: Column(
                                              children: [
                                                TextField(
                                                  controller:
                                                      _searchNomClient_controller,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      searchClient();
                                                    });
                                                  },
                                                  decoration:
                                                      new InputDecoration(
                                                          hintText:
                                                              "Entrer Nom",
                                                          suffixIcon:
                                                              IconButton(
                                                            icon: Icon(
                                                                FontAwesomeIcons
                                                                    .search),
                                                            iconSize: 17,
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    5, 5, 5, 5),
                                                            hoverColor: Colors
                                                                .transparent,
                                                            color: Colors
                                                                .grey[800],
                                                            onPressed: () {
                                                              setState(() {
                                                                searchClient();
                                                              });
                                                            },
                                                          )),
                                                ),
                                                SizedBox(
                                                  height: 6,
                                                ),
                                                Container(
                                                  width: 350,
                                                  child: ElevatedButton(
                                                      child: Text(
                                                        '${_listClientsFiltred[index].nom} ${_listClientsFiltred[index].prenom}',
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .resolveWith<
                                                                      Color>(
                                                        (Set<MaterialState>
                                                            states) {
                                                          if (states.contains(
                                                              MaterialState
                                                                  .hovered))
                                                            return Colors.green;
                                                          return Colors
                                                                  .orangeAccent[
                                                              700]; // Use the component's default.
                                                        },
                                                      )),
                                                      onPressed: () {
                                                        setSelectedClientData(
                                                            _listClients[index],
                                                            1);
                                                        Navigator.of(context)
                                                            .pop();
                                                      }),
                                                )
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  3, 3, 3, 0),
                                              child: ElevatedButton(
                                                  child: Text(
                                                    '${_listClients[index].nom} ${_listClients[index].prenom}',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .resolveWith<
                                                                  Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .hovered))
                                                        return Colors.green;
                                                      return Colors
                                                              .orangeAccent[
                                                          700]; // Use the component's default.
                                                    },
                                                  )),
                                                  onPressed: () {
                                                    setSelectedClientData(
                                                        _listClients[index], 1);

                                                    Navigator.of(context).pop();
                                                  }));
                                        }
                                      },
                                    ),
                                  ));
                            }));
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  color: Colors.white,
                  width: getWidgetWidth(280),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Ajouter des produits",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.plusCircle,
                    color: Colors.orange[900],
                  ),
                  iconSize: 17,
                  onPressed: () {
                    setState(() {
                      parentSelectProductState =
                          SelectProductsParent.modifyVente;
                      VenteState = VenteContainerState.selectProduits;
                    });
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  color: Colors.white,
                  width: getWidgetWidth(280),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    controller: _dateControllermodify,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Date facturation",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.calendarTimes,
                    color: Colors.orange[900],
                  ),
                  iconSize: 17,
                  onPressed: () {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2018),
                            lastDate: DateTime(2030))
                        .then((value) {
                      if (value != null) {
                        DateTime _fromDate = DateTime.now();
                        _fromDate = value;
                        final String date =
                            formatDate(_fromDate, [dd, '-', mm, '-', yyyy]);
                        setState(() {
                          _dateControllermodify.text = date;
                        });
                      }
                    });
                  },
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            ExpansionPanelList(
              children: [
                ExpansionPanel(
                    headerBuilder: (context, isOpen) {
                      return Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Livraison :",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Column(
                        children: [
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
                                child: Container(
                                  color: Colors.white,
                                  width: getWidgetWidth(610) + 7,
                                  child: TextField(
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
                              Expanded(
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
                                  child: TextField(
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
                                  child: TextField(
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
                        ],
                      ),
                    ),
                    isExpanded: _isOpen[0]),
                ExpansionPanel(
                    headerBuilder: (context, isOpen) {
                      return Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Facturation :",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Column(
                        children: [
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
                                    controller:
                                        _teleControllerFacturationmodify,
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
                                child: Container(
                                  color: Colors.white,
                                  width: getWidgetWidth(610) + 7,
                                  child: TextField(
                                    keyboardType: TextInputType.text,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    controller:
                                        _adresseControllerFacturationmodify,
                                    decoration: InputDecoration(
                                        labelText: "Adresse",
                                        suffixIcon: Icon(
                                          FontAwesomeIcons.addressBook,
                                          size: 17,
                                        )),
                                  ),
                                ),
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
                                    controller:
                                        _emailControllerFacturationmodify,
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
                                child: Container(
                                  color: Colors.white,
                                  width: getWidgetWidth(280),
                                  child: TextField(
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    controller:
                                        _villeControllerFacturationmodify,
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
                                    controller:
                                        _paysControllerFacturationmodify,
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
                                    controller:
                                        _codepostaleControllerFacturationmodify,
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
                        ],
                      ),
                    ),
                    isExpanded: _isOpen[1])
              ],
              expansionCallback: (index, isOpen) => setState(() {
                _isOpen[index] = !isOpen;
              }),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "List des produits/services :",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            showSelectedProductsWidget(),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  margin: EdgeInsets.only(right: 10),
                  child: Text("Totale : ${prix_totale} Dhs",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
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
                          VenteState = VenteContainerState.showVentes;
                        });
                      }),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: getWidgetHeight(40),
                  width: getWidgetWidth(200),
                  child: ElevatedButton(
                      child: Text('Facturer'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: () async {
                        await genererFacture(getFactureData());
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
                        if (_dataTomodify.getFacture() == null ||
                            _dataTomodify.getFacture().isEmpty) {
                          getModifyDataFromControllers();
                          modifyVente(_dataTomodify)
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
                                        "Vente Modifier!",
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }));
                        } else {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(milliseconds: 800), () {
                                  Navigator.of(context).pop(true);
                                });
                                return AlertDialog(
                                  title: Image.asset(
                                    'assets/remove.png',
                                    height: 50,
                                    width: 50,
                                  ),
                                  content: Text(
                                    "Vente déjà facturer",
                                    textAlign: TextAlign.center,
                                  ),
                                );
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

  //Controllers for add data
  final _dateController = TextEditingController();
  final _clientController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleController = TextEditingController();
  final _villeController = TextEditingController();
  final _paysController = TextEditingController();
  final _codepostaleController = TextEditingController();
  final _adresseController = TextEditingController();
  final _villeControllerFacturation = TextEditingController();
  final _emailControllerFacturation = TextEditingController();
  final _teleControllerFacturation = TextEditingController();
  final _paysControllerFacturation = TextEditingController();
  final _codepostaleControllerFacturation = TextEditingController();
  final _adresseControllerFacturation = TextEditingController();

  //controllers for modify data
  final _dateControllermodify = TextEditingController();
  final _clientControllermodify = TextEditingController();
  final _emailControllermodify = TextEditingController();
  final _teleControllermodify = TextEditingController();
  final _villeControllermodify = TextEditingController();
  final _paysControllermodify = TextEditingController();
  final _codepostaleControllermodify = TextEditingController();
  final _adresseControllermodify = TextEditingController();
  final _villeControllerFacturationmodify = TextEditingController();
  final _emailControllerFacturationmodify = TextEditingController();
  final _teleControllerFacturationmodify = TextEditingController();
  final _paysControllerFacturationmodify = TextEditingController();
  final _codepostaleControllerFacturationmodify = TextEditingController();
  final _adresseControllerFacturationmodify = TextEditingController();

  //expansion
  List<bool> _isOpen = [false, false];
  TextEditingController _searchNomClient_controller = TextEditingController();

  Widget getAjoutVenteWidget() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: ListView(
          children: [
            Center(
              child: Text(
                "Ajouter Vente",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Container(
                  color: Colors.white,
                  width: getWidgetWidth(280),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    enabled: false,
                    controller: _clientController,
                    decoration: InputDecoration(
                      labelText: "Client",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.plusCircle,
                    color: Colors.orange[900],
                  ),
                  iconSize: 17,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            StatefulBuilder(builder: (context, setState) {
                              return AlertDialog(
                                  contentPadding:
                                      EdgeInsets.only(left: 25, right: 25),
                                  title:
                                      Center(child: Text("Choisir un client")),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  content: Container(
                                    padding: EdgeInsets.only(top: 5),
                                    height: MediaQuery.of(context).size.height *
                                        0.5,
                                    width: 300,
                                    child: ListView.builder(
                                      itemCount: _listClientsFiltred.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index == 0) {
                                          return Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                3, 3, 3, 3),
                                            child: Column(
                                              children: [
                                                TextField(
                                                  controller:
                                                      _searchNomClient_controller,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      searchClient();
                                                    });
                                                  },
                                                  decoration:
                                                      new InputDecoration(
                                                          hintText:
                                                              "Entrer Nom",
                                                          suffixIcon:
                                                              IconButton(
                                                            icon: Icon(
                                                                FontAwesomeIcons
                                                                    .search),
                                                            iconSize: 17,
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    5, 5, 5, 5),
                                                            hoverColor: Colors
                                                                .transparent,
                                                            color: Colors
                                                                .grey[800],
                                                            onPressed: () {
                                                              setState(() {
                                                                searchClient();
                                                              });
                                                            },
                                                          )),
                                                ),
                                                SizedBox(
                                                  height: 6,
                                                ),
                                                Container(
                                                  width: 350,
                                                  child: ElevatedButton(
                                                      child: Text(
                                                        '${_listClientsFiltred[index].nom} ${_listClientsFiltred[index].prenom}',
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .resolveWith<
                                                                      Color>(
                                                        (Set<MaterialState>
                                                            states) {
                                                          if (states.contains(
                                                              MaterialState
                                                                  .hovered))
                                                            return Colors.green;
                                                          return Colors
                                                                  .orangeAccent[
                                                              700]; // Use the component's default.
                                                        },
                                                      )),
                                                      onPressed: () {
                                                        setSelectedClientData(
                                                            _listClients[index],
                                                            0);
                                                        Navigator.of(context)
                                                            .pop();
                                                      }),
                                                )
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  3, 3, 3, 0),
                                              child: ElevatedButton(
                                                  child: Text(
                                                    '${_listClients[index].nom} ${_listClients[index].prenom}',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .resolveWith<
                                                                  Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .hovered))
                                                        return Colors.green;
                                                      return Colors
                                                              .orangeAccent[
                                                          700]; // Use the component's default.
                                                    },
                                                  )),
                                                  onPressed: () {
                                                    setSelectedClientData(
                                                        _listClients[index], 0);
                                                    Navigator.of(context).pop();
                                                  }));
                                        }
                                      },
                                    ),
                                  ));
                            }));
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  color: Colors.white,
                  width: getWidgetWidth(280),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Ajouter des produits",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.plusCircle,
                    color: Colors.orange[900],
                  ),
                  iconSize: 17,
                  onPressed: () {
                    setState(() {
                      parentSelectProductState = SelectProductsParent.addVente;
                      VenteState = VenteContainerState.selectProduits;
                    });
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  color: Colors.white,
                  width: getWidgetWidth(280),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    controller: _dateController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Date facturation",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.calendarTimes,
                    color: Colors.orange[900],
                  ),
                  iconSize: 17,
                  onPressed: () {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2018),
                            lastDate: DateTime(2030))
                        .then((value) {
                      if (value != null) {
                        DateTime _fromDate = DateTime.now();
                        _fromDate = value;
                        final String date =
                            formatDate(_fromDate, [dd, '-', mm, '-', yyyy]);
                        setState(() {
                          _dateController.text = date;
                        });
                      }
                    });
                  },
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            ExpansionPanelList(
              children: [
                ExpansionPanel(
                    headerBuilder: (context, isOpen) {
                      return Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Livraison :",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Column(
                        children: [
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
                        ],
                      ),
                    ),
                    isExpanded: _isOpen[0]),
                ExpansionPanel(
                    headerBuilder: (context, isOpen) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Facturation : (comme la livraison) ",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Checkbox(
                              value: _facturationisChecked,
                              onChanged: (value) {
                                setState(() {
                                  _facturationisChecked = value;
                                  updateFacturationData();
                                });
                              })
                        ],
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  width: getWidgetWidth(280),
                                  child: TextField(
                                    enabled: !_facturationisChecked,
                                    keyboardType: TextInputType.text,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    controller: _teleControllerFacturation,
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
                                child: Container(
                                  color: Colors.white,
                                  width: getWidgetWidth(610) + 7,
                                  child: TextField(
                                    enabled: !_facturationisChecked,
                                    keyboardType: TextInputType.text,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    controller: _adresseControllerFacturation,
                                    decoration: InputDecoration(
                                        labelText: "Adresse",
                                        suffixIcon: Icon(
                                          FontAwesomeIcons.addressBook,
                                          size: 17,
                                        )),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  width: getWidgetWidth(330),
                                  child: TextField(
                                    enabled: !_facturationisChecked,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    controller: _emailControllerFacturation,
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
                                child: Container(
                                  color: Colors.white,
                                  width: getWidgetWidth(280),
                                  child: TextField(
                                    enabled: !_facturationisChecked,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    controller: _villeControllerFacturation,
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
                                    enabled: !_facturationisChecked,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    controller: _paysControllerFacturation,
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
                                    enabled: !_facturationisChecked,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    controller:
                                        _codepostaleControllerFacturation,
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
                        ],
                      ),
                    ),
                    isExpanded: _isOpen[1])
              ],
              expansionCallback: (index, isOpen) => setState(() {
                _isOpen[index] = !isOpen;
              }),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "List des produits/services :",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            showSelectedProductsWidget(),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  margin: EdgeInsets.only(right: 10),
                  child: Text("Totale : ${prix_totale} Dhs",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
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
                          VenteState = VenteContainerState.showVentes;
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
                        addVente(_dataToAdd).whenComplete(() {
                          _dataToAdd.produits.forEach((e) {
                            String qte_left = '';
                            _listproduitSelect.forEach((element) {
                              if (element.produit.id.contains(e["produit"])) {
                                qte_left = (int.parse(element.produit.qte) -
                                        int.parse(e["qte"]))
                                    .toString();
                              }
                            });
                            modifyProduitSingleVal(
                                e["produit"], "qte", qte_left);
                          });
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
                                    "Vente Ajouter!",
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

  void searchClient() {
    if (_searchNomClient_controller.text.isEmpty) {
      _listClientsFiltred = _listClients;
    } else {
      _listClientsFiltred = _listClients
          .where((e) => e.nom.startsWith(_searchNomClient_controller.text))
          .toList();
      if (_listClientsFiltred.length == 0) _listClientsFiltred = _listClients;
    }
  }

  Widget showSelectedProductsWidget() {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingTextStyle:
                TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
            columns: [
              DataColumn(
                label: Text('Nom'),
              ),
              DataColumn(
                label: Text('Prix (Dhs)'),
              ),
              DataColumn(
                label: Text('Qte'),
              ),
              DataColumn(
                label: Text('Total (Dhs)'),
              ),
              DataColumn(
                label: Text(''),
              ),
            ],
            rows: _selectedProductslist
                .map((data) => DataRow(cells: [
                      DataCell(Text(data.produit.nom)),
                      DataCell(Text(data.produit.prix)),
                      DataCell(
                        Text(data.qte.toString()),
                      ),
                      DataCell(Text((data.qte * int.parse(data.produit.prix))
                          .toString())),
                      DataCell(IconButton(
                        icon: Icon(Icons.delete),
                        hoverColor: Colors.transparent,
                        color: Colors.red,
                        iconSize: 17,
                        onPressed: () {
                          setState(() {
                            _selectedProductslist.remove(data);
                            if (_first) {
                              SelectedProduitModel datatoRemove;
                              _filtredlistproduitSelect.forEach((element) {
                                if (element.produit.id == data.produit.id) {
                                  datatoRemove = element;
                                  return;
                                }
                              });
                              _filtredlistproduitSelect[
                                      _filtredlistproduitSelect
                                          .indexOf(datatoRemove)]
                                  .isSelected = false;
                              _filtredlistproduitSelect[
                                      _filtredlistproduitSelect
                                          .indexOf(datatoRemove)]
                                  .qte = 0;
                            }
                          });
                          getTotalePrice();
                        },
                      ))
                    ]))
                .toList(),
          ),
        ),
      ),
    );
  }

  //selectedProducts
  List<SelectedProduitModel> _filtredlistproduitSelect;
  List<SelectedProduitModel> _listproduitSelect;
  bool searshing_product = false;
  String _searchResult_product = '';
  bool searchClicked_product = false;
  TextEditingController _controllerSearchProduct = TextEditingController();
  bool _first = false;
  List<SelectedProduitModel> _selectedProductslist =
      new List<SelectedProduitModel>();

  Widget getSelectProductWidget() {
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
          if (!_first) {
            _filtredlistproduitSelect = provider.produitlist;
            updateListSelectProducts();
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
                        showCheckboxColumn: true,
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
                            label: Text('Prix (Dhs)'),
                          ),
                          DataColumn(
                            label: Text('Qte (Stock)'),
                          ),
                          DataColumn(
                            label: Text('Qte'),
                          ),
                        ],
                        rows: _filtredlistproduitSelect
                            .map((data) => DataRow(
                                    selected: data.isSelected,
                                    onSelectChanged: (value) {
                                      if (data.produit.qte != "0") {
                                        setState(() {
                                          onSelectproduct(value, data);
                                          data.isSelected = value;
                                          value ? data.qte++ : data.qte = 0;
                                          if (searshing_product == false)
                                            _listproduitSelect =
                                                _filtredlistproduitSelect;
                                        });
                                      }
                                    },
                                    cells: [
                                      DataCell(Text(data.produit.nom)),
                                      DataCell(Text(data.produit.desc)),
                                      DataCell(Text(data.produit.prix)), //
                                      DataCell(Text(
                                        data.produit.qte == "0"
                                            ? "0 (indisponible)"
                                            : data.produit.qte,
                                        style: TextStyle(
                                            color: data.produit.qte == "0"
                                                ? Colors.red
                                                : null,
                                            fontWeight: data.produit.qte == "0"
                                                ? FontWeight.bold
                                                : null),
                                      )),
                                      DataCell(SizedBox(
                                        width: 160,
                                        child: ListTile(
                                          title: Text(data.qte.toString()),
                                          trailing: IconButton(
                                            icon: Icon(
                                              FontAwesomeIcons.plusCircle,
                                              color: Colors.blue,
                                            ),
                                            iconSize: 17,
                                            hoverColor: Colors.transparent,
                                            onPressed: () {
                                              if (data.isSelected) {
                                                setState(() {
                                                  if (checkQteStock(data))
                                                    data.qte++;
                                                  updateSelectedProductQte(
                                                      data);
                                                  if (searshing_product ==
                                                      false)
                                                    _listproduitSelect =
                                                        _filtredlistproduitSelect;
                                                });
                                              }
                                            },
                                          ),
                                          leading: IconButton(
                                            icon: Icon(
                                              FontAwesomeIcons.minusCircle,
                                              color: Colors.blue,
                                            ),
                                            iconSize: 17,
                                            hoverColor: Colors.transparent,
                                            onPressed: () {
                                              if (data.isSelected) {
                                                setState(() {
                                                  if (data.qte > 1) data.qte--;
                                                  updateSelectedProductQte(
                                                      data);
                                                  if (searshing_product ==
                                                      false)
                                                    _listproduitSelect =
                                                        _filtredlistproduitSelect;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      )),
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
                  right: searchClicked_product ? 70 : -210,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    color: Colors.grey[300],
                    width: 210,
                    height: 40,
                    child: TextField(
                      controller: _controllerSearchProduct,
                      onChanged: (val) {
                        setState(() {
                          _searchResult_product = val;
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
                      searchClicked_product = !searchClicked_product;
                      _controllerSearchProduct.clear();
                      _searchResult_product = '';
                      if (!searchClicked_product) searchProduit();
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: SizedBox(
                  height: getWidgetHeight(50),
                  width: getWidgetWidth(150),
                  child: ElevatedButton(
                      child: Text(
                        'Fermer',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed))
                            return Colors.green[900];
                          return Colors.green; // Use the component's default.
                        },
                      )),
                      onPressed: () {
                        getTotalePrice();
                        setState(() {
                          parentSelectProductState ==
                                  SelectProductsParent.addVente
                              ? VenteState = VenteContainerState.addVente
                              : VenteState = VenteContainerState.modifyVente;
                        });
                      }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void searchProduit() {
    if (_searchResult_product.isEmpty) {
      searshing_product = false;
      _filtredlistproduitSelect = _listproduitSelect;
    } else {
      searshing_product = true;
      _filtredlistproduitSelect = _listproduitSelect
          .where((element) =>
              element.produit.nom.startsWith(_searchResult_product))
          .toList();
    }
  }

  void getTotalePrice() {
    int prix = 0;
    _selectedProductslist.forEach((e) {
      prix = e.qte * int.parse(e.produit.prix) + prix;
    });
    setState(() {
      prix_totale = prix.toString();
    });
  }

  void onSelectproduct(bool val, SelectedProduitModel produit) {
    setState(() {
      if (val) {
        _selectedProductslist.add(produit);
        print(_selectedProductslist.length);
      } else {
        SelectedProduitModel dataToRemove;
        _selectedProductslist.forEach((element) {
          if (element.produit.id == produit.produit.id) {
            dataToRemove = element;
            return;
          }
        });
        _selectedProductslist.remove(dataToRemove);
        print(_selectedProductslist.length);
      }
    });
  }

  double getWidgetWidth(double nb) {
    return MediaQuery.of(context).size.width * nb / 1265;
  }

  double getWidgetHeight(double nb) {
    return MediaQuery.of(context).size.height * nb / 646;
  }

  void updateListSelectProducts() {
    _selectedProductslist.forEach((selectedData) {
      _filtredlistproduitSelect.forEach((element) {
        if (element.produit.id.contains(selectedData.produit.id)) {
          _filtredlistproduitSelect[_filtredlistproduitSelect.indexOf(element)]
              .isSelected = true;
          _filtredlistproduitSelect[_filtredlistproduitSelect.indexOf(element)]
              .qte = selectedData.qte;
        }
      });
    });
    _first = true;
  }

  void updateSelectedProductQte(SelectedProduitModel produit) {
    _selectedProductslist.forEach((element) {
      if (element.produit.id == produit.produit.id) {
        element.qte = produit.qte;
      }
    });
  }

  void setSelectedClientData(ClientJson data, int state) {
    switch (state) {
      case 0:
        _clientController.text = data.nom + " " + data.prenom;
        _adresseController.text = data.adresselivraison;
        _emailController.text = data.email;
        _teleController.text = data.tele;
        _villeController.text = data.villelivraison;
        _paysController.text = data.payslivraison;
        _codepostaleController.text = data.codepostalelivraison;
        updateFacturationData();
        break;
      case 1:
        _clientControllermodify.text = data.nom + " " + data.prenom;
        _adresseControllermodify.text = data.adresselivraison;
        _emailControllermodify.text = data.email;
        _teleControllermodify.text = data.tele;
        _villeControllermodify.text = data.villelivraison;
        _paysControllermodify.text = data.payslivraison;
        _codepostaleControllermodify.text = data.codepostalelivraison;
        break;
      default:
    }
  }

  void getDataFromControllers() {
    _dataToAdd.setId(getRandomString(9));
    _dataToAdd.setAdresse(_adresseController.text);
    _dataToAdd.setCodepostale(_codepostaleController.text);
    _dataToAdd.setEmail(_emailController.text);
    _dataToAdd.setPays(_paysController.text);
    _dataToAdd.setTele(_teleController.text);
    _dataToAdd.setVille(_villeController.text);
    _dataToAdd.setAdressefacturatil(_adresseControllerFacturation.text);
    _dataToAdd.setCodepostalefacturatil(_codepostaleControllerFacturation.text);
    _dataToAdd.setEmailfacturatil(_emailControllerFacturation.text);
    _dataToAdd.setPaysfacturatil(_paysControllerFacturation.text);
    _dataToAdd.setTelefacturatil(_teleControllerFacturation.text);
    _dataToAdd.setVillefacturatil(_villeControllerFacturation.text);
    _dataToAdd.setFacturation(_dateController.text.isEmpty
        ? formatDate(DateTime.now(), [dd, '-', mm, '-', yyyy])
        : _dateController.text);
    _dataToAdd.setTotale(prix_totale);
    _dataToAdd.setClient(getSubID(
        getIdClientFromNom(_listClientsFiltred, _clientController.text)));

    List<Map<String, String>> _produitlist = new List<Map<String, String>>();

    _selectedProductslist.forEach((e) {
      Map<String, String> map = new Map<String, String>();
      map.putIfAbsent("produit", () => getSubID(e.produit.id));
      map.putIfAbsent("qte", () => e.qte.toString());
      _produitlist.add(map);
    });

    _dataToAdd.setProduits(_produitlist);
  }

  void clearAddPageControllers() {
    _emailController.clear();
    _teleController.clear();
    _villeController.clear();
    _paysController.clear();
    _codepostaleController.clear();
    _adresseController.clear();
    _emailControllerFacturation.clear();
    _teleControllerFacturation.clear();
    _villeControllerFacturation.clear();
    _paysControllerFacturation.clear();
    _codepostaleControllerFacturation.clear();
    _adresseControllerFacturation.clear();
    _clientController.clear();
    _searchNomClient_controller.clear();
    setState(() {
      _selectedProductslist.clear();
      prix_totale = "0";
    });
  }

  void clearModifyPageContollers() {
    setState(() {
      _filtredlistproduitSelect = _listproduitSelect;
      _selectedProductslist.clear();
      prix_totale = "0";
    });
  }

  void setModifyWidgetData(VenteJson data) {
    _dataTomodify.setId(data.id);
    if (data.facture != null) {
      if (data.facture.isNotEmpty) {
        _dataTomodify.setFacture(data.facture);
      }
    }
    _dateControllermodify.text = data.facturation;
    _clientControllermodify.text =
        getNomClientfromID(_listClients, data.client);
    _emailControllermodify.text = data.email;
    _teleControllermodify.text = data.tele;
    _villeControllermodify.text = data.ville;
    _paysControllermodify.text = data.pays;
    _codepostaleControllermodify.text = data.codepostale;
    _adresseControllermodify.text = data.adresse;
    _villeControllerFacturationmodify.text = data.villefacturation;
    _emailControllerFacturationmodify.text = data.emailfacturation;
    _teleControllerFacturationmodify.text = data.telefacturation;
    _paysControllerFacturationmodify.text = data.paysfacturation;
    _codepostaleControllerFacturationmodify.text = data.codepostalefacturation;
    _adresseControllerFacturationmodify.text = data.adressefacturation;
    prix_totale = data.totale;
    _selectedProductslist = getListSelectedProducts(data.produits);
  }

  Invoice getFactureData() {
    Vente vente = new Vente();
    vente.id = _dataTomodify.getId();
    vente.adresse = _adresseControllermodify.text;
    vente.ville = _villeControllermodify.text;
    vente.pays = _paysControllermodify.text;
    vente.codepostale = _codepostaleControllermodify.text;
    vente.client = _clientControllermodify.text;
    vente.tele = _teleControllermodify.text;
    vente.email = _emailControllermodify.text;
    vente.emailfacturation = _emailControllerFacturationmodify.text;
    vente.telefacturation = _teleControllerFacturationmodify.text;
    vente.adressefacturation = _adresseControllerFacturationmodify.text;
    vente.villefacturation = _villeControllerFacturationmodify.text;
    vente.paysfacturation = _paysControllerFacturationmodify.text;
    vente.codepostalefacturation = _codepostaleControllerFacturationmodify.text;
    vente.facturation = _dateControllermodify.text.isEmpty
        ? formatDate(DateTime.now(), [dd, '-', mm, '-', yyyy])
        : _dateControllermodify.text;
    vente.totale = prix_totale;
    Invoice invoice = new Invoice(vente: vente, items: _selectedProductslist);
    return invoice;
  }

  void updateFacturationData() {
    if (_facturationisChecked) {
      _emailControllerFacturation.text = _emailController.text;
      _teleControllerFacturation.text = _teleController.text;
      _villeControllerFacturation.text = _villeController.text;
      _paysControllerFacturation.text = _paysController.text;
      _codepostaleControllerFacturation.text = _codepostaleController.text;
      _adresseControllerFacturation.text = _adresseController.text;
    } else {
      _emailControllerFacturation.clear();
      _teleControllerFacturation.clear();
      _villeControllerFacturation.clear();
      _paysControllerFacturation.clear();
      _codepostaleControllerFacturation.clear();
      _adresseControllerFacturation.clear();
    }
  }

  void getModifyDataFromControllers() {
    _dataTomodify.setAdresse(_adresseControllermodify.text);
    _dataTomodify.setCodepostale(_codepostaleControllermodify.text);
    _dataTomodify.setEmail(_emailControllermodify.text);
    _dataTomodify.setPays(_paysControllermodify.text);
    _dataTomodify.setTele(_teleControllermodify.text);
    _dataTomodify.setVille(_villeControllermodify.text);
    _dataTomodify
        .setAdressefacturatil(_adresseControllerFacturationmodify.text);
    _dataTomodify
        .setCodepostalefacturatil(_codepostaleControllerFacturationmodify.text);
    _dataTomodify.setEmailfacturatil(_emailControllerFacturationmodify.text);
    _dataTomodify.setPaysfacturatil(_paysControllerFacturationmodify.text);
    _dataTomodify.setTelefacturatil(_teleControllerFacturationmodify.text);
    _dataTomodify.setVillefacturatil(_villeControllerFacturationmodify.text);
    _dataTomodify.setFacturation(_dateControllermodify.text.isEmpty
        ? formatDate(DateTime.now(), [dd, '-', mm, '-', yyyy])
        : _dateControllermodify.text);
    _dataTomodify.setTotale(prix_totale);
    _dataTomodify.setClient(getSubID(
        getIdClientFromNom(_listClientsFiltred, _clientControllermodify.text)));

    List<Map<String, String>> _produitlist = new List<Map<String, String>>();

    _selectedProductslist.forEach((e) {
      Map<String, String> map = new Map<String, String>();
      map.putIfAbsent("produit", () => getSubID(e.produit.id));
      map.putIfAbsent("qte", () => e.qte.toString());
      _produitlist.add(map);
    });

    _dataTomodify.setProduits(_produitlist);
  }

  Future genererFacture(Invoice invoice) async {
    final file = await PdfInvoiceApi.generate(invoice);
    if (file != null) {
      if (invoice.vente.facture == null || invoice.vente.facture.isEmpty) {
        String idFacture = getRandomString(8);
        addFactureVente(idFacture, invoice.vente.id);
        Facture facture = new Facture();
        facture.setId(idFacture);
        facture.setTotal(invoice.vente.totale);
        facture.setDate(invoice.vente.facturation);
        facture.setCommerciant(getSubID(globaleUser.id));
        addFacture(facture);
      }
      PdfApi.openFile(file);
    }
  }

  bool checkQteStock(SelectedProduitModel produit) {
    if (int.parse(produit.produit.qte) > produit.qte) {
      return true;
    }
    return false;
  }

  Future<List<ClientJson>> getClientsList() async {
    List<ClientJson> clientlist = new List<ClientJson>();
    var clients;
    await getCollectionClients().then((value) => clients = value);
    for (var c in clients) {
      clientlist.add(ClientJson.fromJson(c));
    }
    return clientlist;
  }

  Future<List<SelectedProduitModel>> getProductsList() async {
    List<SelectedProduitModel> listselectedProducts =
        List<SelectedProduitModel>();

    var produits;
    await getCollectionProduits().then((value) => produits = value);
    for (var c in produits) {
      SelectedProduitModel model =
          new SelectedProduitModel(ProduitJson.fromJson(c), 0, false);
      listselectedProducts.add(model);
    }
    return listselectedProducts;
  }
}

enum VenteContainerState { showVentes, addVente, modifyVente, selectProduits }
enum SelectProductsParent { addVente, modifyVente }

class VentepageProvider extends ChangeNotifier {
  List<VenteJson> ventelist;

  Future getData(context) async {
    ventelist = List<VenteJson>();
    var ventes;
    await getCollectionVentes().then((value) => ventes = value);
    if (ventes != null) {
      for (var c in ventes) {
        ventelist.add(VenteJson.fromJson(c));
      }
    }

    this.notifyListeners();
  }

  //
  Future<List<VenteJson>> getUserData(context) async {
    ventelist = List<VenteJson>();
    var ventes;
    await getCollectionVentes().then((value) => ventes = value);

    if (ventes != null) {
      for (var c in ventes) {
        ventelist.add(VenteJson.fromJson(c));
      }
    }
    return ventelist;
  }
}

class ProduitpageProvider extends ChangeNotifier {
  List<SelectedProduitModel> produitlist;

  Future getData(context) async {
    produitlist = List<SelectedProduitModel>();
    var produits;
    await getCollectionProduits().then((value) => produits = value);

    for (var c in produits) {
      SelectedProduitModel model =
          new SelectedProduitModel(ProduitJson.fromJson(c), 0, false);
      produitlist.add(model);
    }
    this.notifyListeners();
  }

  //
  Future<List<SelectedProduitModel>> getUserData(context) async {
    produitlist = List<SelectedProduitModel>();
    var produits;
    await getCollectionProduits().then((value) => produits = value);
    for (var c in produits) {
      SelectedProduitModel model =
          new SelectedProduitModel(ProduitJson.fromJson(c), 0, false);
      produitlist.add(model);
    }
    return produitlist;
  }
}
