import 'package:gestion_vente_app/model/produit.dart';
import 'package:gestion_vente_app/model/vente.dart';

class Invoice {
  Vente vente;
  List<SelectedProduitModel> items;

  Invoice({this.vente, this.items});
}
