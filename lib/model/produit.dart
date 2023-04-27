import 'dart:convert';

import 'package:gestion_vente_app/utility/mongodb.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:mongo_dart/mongo_dart.dart' as _Mongodb;
import 'package:mongo_dart/mongo_dart.dart';

class Produit {
  String id;
  String nom;
  String desc;
  String prix;
  String qte;
  String categorie;
  String fournisseur;

  Produit() {}

  Map toJson() => {
        'nom': getNom(),
        'desc': getDesc(),
        'prix': getPrix(),
        'qte': getQte(),
        'categorie': getCategorie(),
        'fournisseur': getFournisseur()
      };

  String getId() {
    return this.id;
  }

  void setId(code) {
    this.id = code;
  }

  String getNom() {
    return this.nom;
  }

  void setNom(nom) {
    this.nom = nom;
  }

  String getDesc() {
    return this.desc;
  }

  void setDesc(desc) {
    this.desc = desc;
  }

  String getPrix() {
    return this.prix;
  }

  void setPrix(prix) {
    this.prix = prix;
  }

  String getQte() {
    return this.qte;
  }

  void setQte(qte) {
    this.qte = qte;
  }

  String getCategorie() {
    return this.categorie;
  }

  void setCategorie(categorie) {
    this.categorie = categorie;
  }

  String getFournisseur() {
    return this.fournisseur;
  }

  void setFournisseur(fournisseur) {
    this.fournisseur = fournisseur;
  }
}

class ProduitJson {
  String id;
  String nom;
  String desc;
  String prix;
  String qte;
  String categorie;
  String fournisseur;

  ProduitJson.fromJson(Map<String, dynamic> json) {
    id = json['_id'].toString();
    nom = json['nom'] as String;
    desc = json['desc'] as String;
    prix = json['prix'] as String;
    qte = json['qte'] as String;
    categorie = json['categorie'] as String;
    fournisseur = json['fournisseur'] as String;
  }
}

//database
Future<List<Map<String, dynamic>>> getCollectionProduits() async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('produits');
  var clients = await collection.find().toList();

  return clients;
}

Future addProduit(Produit produit) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('produits');

  var encoded = jsonEncode(produit);
  var doc = json.decode(encoded);
  await collection.insertOne(doc);
  print('saved');
}

Future modifyProduitSingleVal(String id, String key, String val) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('produits');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.update(where.eq('_id', objId), {
    r'$set': {key: val}
  });
  print("modified");
}

Future modifyProduit(Produit produit) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('produits');
  ObjectId objId = _Mongodb.ObjectId.parse(getSubID(produit.getId()));

  var encoded = jsonEncode(produit);
  var doc = json.decode(encoded);

  await collection.update(where.eq('_id', objId), {r'$set': doc});
  print("modified");
}

Future deleteProduit(String id) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('produits');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.remove(await collection.findOne(where.eq('_id', objId)));
  print('data removed');
}

Future<Map<String, dynamic>> findProduit(String id) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('produits');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  var result = await collection.findOne(where.eq('_id', objId));

  return result;
}

class SelectedProduitModel {
  ProduitJson produit;
  int qte;
  bool isSelected;

  SelectedProduitModel(this.produit, this.qte, this.isSelected);
}
