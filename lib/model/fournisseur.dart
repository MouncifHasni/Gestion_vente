import 'dart:convert';

import 'package:gestion_vente_app/utility/mongodb.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/mongo_dart.dart' as _Mongodb;

class Fournisseur {
  String id;
  String nom;
  String prenom;
  String email;
  String adresse;
  String tele;
  String ville;
  String pays;
  String codepostale;

  Fournisseur() {}

  Map toJson() => {
        'nom': getNom(),
        'prenom': getPrenom(),
        'email': getEmail(),
        'tele': getTele(),
        'adresse': getAdresse(),
        'ville': getVille(),
        'pays': getPays(),
        'codepostale': getCodepostale(),
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

  String getPrenom() {
    return this.prenom;
  }

  void setPrenom(prenom) {
    this.prenom = prenom;
  }

  String getEmail() {
    return this.email;
  }

  void setEmail(email) {
    this.email = email;
  }

  String getAdresse() {
    return this.adresse;
  }

  void setAdresse(adresse) {
    this.adresse = adresse;
  }

  String getTele() {
    return this.tele;
  }

  void setTele(tele) {
    this.tele = tele;
  }

  String getVille() {
    return this.ville;
  }

  void setVille(ville) {
    this.ville = ville;
  }

  String getPays() {
    return this.pays;
  }

  void setPays(pays) {
    this.pays = pays;
  }

  String getCodepostale() {
    return this.codepostale;
  }

  void setCodepostale(codepostale) {
    this.codepostale = codepostale;
  }
}

class FournisseurJson {
  String id;
  String nom;
  String prenom;
  String email;
  String adresse;
  String tele;
  String ville;
  String pays;
  String codepostale;

  FournisseurJson.fromJson(Map<String, dynamic> json) {
    id = json['_id'].toString();
    nom = json['nom'] as String;
    prenom = json['prenom'] as String;
    adresse = json['adresse'] as String;
    email = json['email'] as String;
    tele = json['tele'] as String;
    pays = json['pays'] as String;
    codepostale = json['codepostale'] as String;
    ville = json['ville'] as String;
  }
}

Future<List<Map<String, dynamic>>> getCollectionFournisseurs() async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('fournisseurs');
  var fournisseurs = await collection.find().toList();
  return fournisseurs;
}

Future addFournisseur(Fournisseur fournisseur) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('fournisseurs');

  var encoded = jsonEncode(fournisseur);
  var doc = json.decode(encoded);
  await collection.insertOne(doc);
  print('client saved');
}

Future modifyFournisseurSingleVal(String id, String key, String val) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('fournisseurs');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.update(where.eq('_id', objId), {
    r'$set': {key: val}
  });
  print("modified");
}

Future modifyFournisseur(Fournisseur fournisseur) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('fournisseurs');
  ObjectId objId = _Mongodb.ObjectId.parse(getSubID(fournisseur.getId()));

  var encoded = jsonEncode(fournisseur);
  var doc = json.decode(encoded);

  await collection.update(where.eq('_id', objId), {r'$set': doc});
  print("modified");
}

Future deleteFournisseur(String id) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('fournisseurs');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.remove(await collection.findOne(where.eq('_id', objId)));

  print('data removed');
}

Future<String> getFournisseursCount() async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('fournisseurs');
  var number = await collection.count();

  return number.toString();
}
