import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_vente_app/Pages/parametersPageContainer.dart';
import 'package:gestion_vente_app/Pages/produitPageContainer.dart';
import 'package:gestion_vente_app/Pages/statistiquesPageContainer.dart';
import 'package:gestion_vente_app/Pages/utilisateursContainerPage.dart';
import 'package:gestion_vente_app/sidebar/CollapsingNavDrawer.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'clientsPageContainer.dart';
import 'dashboardPageContainer.dart';
import 'fournisseurContainerPage.dart';
import 'ventesPageCotainer.dart';

class Main_page extends StatefulWidget {
  @override
  _Main_page createState() => _Main_page();
}

class _Main_page extends State<Main_page> {
  int index = 0;
  List<Widget> navlist = [
    DashboardPageContainer(),
    ProduitPageContainer(),
    ClientsPageContainer(),
    FournisseurContainerPage(),
    UtilisateurPageContainer(),
    ParametersPageContainer()
  ];
  List<Widget> commerciantnavlist = [
    DashboardPageContainer(),
    VentesPageCotainer(),
    ProduitPageContainer(),
    ClientsPageContainer(),
    FournisseurContainerPage(),
    ParametersPageContainer()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CollapsingNavDrawer(onSelectIndex: (ctx, i) {
            setState(() {
              index = i;
            });
          }),
          Expanded(
            flex: 1,
            child: Container(
              child: globalRole.contains("administrateur")
                  ? navlist[index]
                  : commerciantnavlist[index],
            ),
          )
        ],
      ),
    );
  }
}

class CollapsingNavDrawerr extends StatelessWidget {
  final Function onTap;
  CollapsingNavDrawerr({this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context, 1),
      child: new ListTile(
        title: new Text(
          'Home',
          style: new TextStyle(color: Colors.white),
        ),
        leading: Icon(
          Icons.home,
          color: Colors.brown,
        ),
        hoverColor: Colors.grey,
      ),
    );
  }
}
