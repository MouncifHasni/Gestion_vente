import 'dart:convert';

import 'package:gestion_vente_app/utility/mongodb.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:mongo_dart/mongo_dart.dart' as _Mongodb;
import 'package:mongo_dart/mongo_dart.dart';

class Client {
  String id;
  String nom;
  String prenom;
  String email;
  String adresse;
  String adresselivraison;
  String tele;
  String ville;
  String villelivraison;
  String payslivraison;
  String pays;
  String codepostale;
  String codepostalelivraison;
  String numcomptebancaire;

  Client() {}

  Map toJson() => {
        'nom': getNom(),
        'prenom': getPrenom(),
        'email': getEmail(),
        'tele': getTele(),
        'adresse': getAdresse(),
        'ville': getVille(),
        'pays': getPays(),
        'payslivraison': getPayslivraison(),
        'codepostale': getCodepostale(),
        'villelivraison': getVillelivraison(),
        'codepostalelivraison': getCodepostalelivraison(),
        'adresselivraison': getAdresselivraison(),
        'numcomptebancaire': getNumcomptebancaire()
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

  String getAdresselivraison() {
    return this.adresselivraison;
  }

  void setAdresselivraison(adresselivraison) {
    this.adresselivraison = adresselivraison;
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

  String getVillelivraison() {
    return this.villelivraison;
  }

  void setVillelivraison(String villelivraison) {
    this.villelivraison = villelivraison;
  }

  String getPayslivraison() {
    return this.payslivraison;
  }

  void setPayslivraison(payslivraison) {
    this.payslivraison = payslivraison;
  }

  String getCodepostalelivraison() {
    return this.codepostalelivraison;
  }

  void setCodepostalelivraison(codepostallivraison) {
    this.codepostalelivraison = codepostallivraison;
  }

  String getNumcomptebancaire() {
    return this.numcomptebancaire;
  }

  void setNumcomptebancaire(String numcomptebancaire) {
    this.numcomptebancaire = numcomptebancaire;
  }
}

class ClientJson {
  String id;
  String nom;
  String prenom;
  String email;
  String adresse;
  String adresselivraison;
  String tele;
  String ville;
  String pays;
  String codepostale;
  String villelivraison;
  String payslivraison;
  String codepostalelivraison;
  String numcomptebancaire;

  ClientJson.fromJson(Map<String, dynamic> json) {
    id = json['_id'].toString();
    nom = json['nom'] as String;
    prenom = json['prenom'] as String;
    adresse = json['adresse'] as String;
    adresselivraison = json['adresselivraison'] as String;
    email = json['email'] as String;
    tele = json['tele'] as String;
    pays = json['pays'] as String;
    codepostale = json['codepostale'] as String;
    ville = json['ville'] as String;
    villelivraison = json['villelivraison'] as String;
    payslivraison = json['payslivraison'] as String;
    codepostalelivraison = json['codepostalelivraison'] as String;
    numcomptebancaire = json['numcomptebancaire'] as String;
  }
}

//Database
Future<List<Map<String, dynamic>>> getCollectionClients() async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('clients');
  var clients = await collection.find().toList();

  return clients;
}

Future addClient(Client client) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('clients');

  var encoded = jsonEncode(client);
  var doc = json.decode(encoded);
  await collection.insertOne(doc);
  print('client saved');
}

Future modifyClientSingleVal(String id, String key, String val) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('clients');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.update(where.eq('_id', objId), {
    r'$set': {key: val}
  });
  print("modified");
}

Future modifyClient(Client client) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('clients');
  ObjectId objId = _Mongodb.ObjectId.parse(getSubID(client.getId()));

  var encoded = jsonEncode(client);
  var doc = json.decode(encoded);

  await collection.update(where.eq('_id', objId), {r'$set': doc});
  print("modified");
}

Future deleteClient(String id) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('clients');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.remove(await collection.findOne(where.eq('_id', objId)));

  print('data removed');
}

Future<String> getClientsCount() async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('clients');
  var number = await collection.count();

  return number.toString();
}
