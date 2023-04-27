import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Nav_model {
  String title;
  IconData icon;
  Nav_model({this.title, this.icon});
}

List<Nav_model> navlist = [
  Nav_model(title: "tableau de bord", icon: Icons.dashboard),
  Nav_model(
      title: "Produits & Services", icon: Icons.home_repair_service_sharp),
  Nav_model(title: "Clients", icon: Icons.badge),
  Nav_model(title: "Fournisseurs", icon: Icons.airport_shuttle_sharp),
  Nav_model(title: "Utilisateurs", icon: Icons.assignment_ind_outlined),
  Nav_model(title: "Paramètres de profile", icon: Icons.settings_outlined),
  Nav_model(title: "Se déconnecter", icon: Icons.logout),
];

List<Nav_model> commerciantnavlist = [
  Nav_model(title: "tableau de bord", icon: Icons.dashboard),
  Nav_model(title: "Ventes", icon: FontAwesomeIcons.salesforce),
  Nav_model(
      title: "Produits & Services", icon: Icons.home_repair_service_sharp),
  Nav_model(title: "Clients", icon: Icons.badge),
  Nav_model(title: "Fournisseurs", icon: Icons.airport_shuttle_sharp),
  Nav_model(title: "Paramètres de profile", icon: Icons.settings_outlined),
  Nav_model(title: "Se déconnecter", icon: Icons.logout),
];
