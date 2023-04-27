import 'dart:convert';

import 'package:gestion_vente_app/utility/mongodb.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:mongo_dart/mongo_dart.dart' as _Mongodb;
import 'package:mongo_dart/mongo_dart.dart';

class Vente {
  String id;
  String facture;
  String client;
  String email;
  String adresse;
  String ville;
  String tele;
  String pays;
  String codepostale;
  String emailfacturation;
  String adressefacturation;
  String villefacturation;
  String telefacturation;
  String paysfacturation;
  String codepostalefacturation;
  List<Map<String, String>> produits;
  String facturation;
  String totale;

  Vente() {}

  Map toJson() => {
        '_id': getId(),
        'facture': getFacture(),
        'client': getClient(),
        'email': getEmail(),
        'adresse': getAdresse(),
        'ville': getVille(),
        'pays': getPays(),
        'codepostale': getCodepostale(),
        'tele': getTele(),
        'emailfacturation': getEmailfacturatil(),
        'adressefacturation': getAdressefacturatil(),
        'villefacturation': getVillefacturatil(),
        'paysfacturation': getPaysfacturatil(),
        'codepostalefacturation': getCodepostalefacturatil(),
        'telefacturation': getTelefacturatil(),
        'produits': produits,
        'facturation': getFacturation(),
        'totale': getTotale()
      };

  String getFacture() {
    return this.facture;
  }

  void setFacture(facture) {
    this.facture = facture;
  }

  String getClient() {
    return this.client;
  }

  void setClient(client) {
    this.client = client;
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

  String getVille() {
    return this.ville;
  }

  void setVille(ville) {
    this.ville = ville;
  }

  String getTele() {
    return this.tele;
  }

  void setTele(tele) {
    this.tele = tele;
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

  String getEmailfacturatil() {
    return this.emailfacturation;
  }

  void setEmailfacturatil(emailfacturatil) {
    this.emailfacturation = emailfacturatil;
  }

  String getAdressefacturatil() {
    return this.adressefacturation;
  }

  void setAdressefacturatil(adressefacturatil) {
    this.adressefacturation = adressefacturatil;
  }

  String getVillefacturatil() {
    return this.villefacturation;
  }

  void setVillefacturatil(villefacturatil) {
    this.villefacturation = villefacturatil;
  }

  String getTelefacturatil() {
    return this.telefacturation;
  }

  void setTelefacturatil(telefacturatil) {
    this.telefacturation = telefacturatil;
  }

  String getPaysfacturatil() {
    return this.paysfacturation;
  }

  void setPaysfacturatil(paysfacturatil) {
    this.paysfacturation = paysfacturatil;
  }

  String getCodepostalefacturatil() {
    return this.codepostalefacturation;
  }

  void setCodepostalefacturatil(codepostalefacturatil) {
    this.codepostalefacturation = codepostalefacturatil;
  }

  List<Map<String, String>> getProduits() {
    return this.produits;
  }

  void setProduits(produits) {
    this.produits = produits;
  }

  String getFacturation() {
    return this.facturation;
  }

  void setFacturation(facturation) {
    this.facturation = facturation;
  }

  String getTotale() {
    return this.totale;
  }

  void setTotale(totale) {
    this.totale = totale;
  }

  String getId() {
    return this.id;
  }

  void setId(code) {
    this.id = code;
  }
}

class VenteJson {
  String id;
  String facture;
  String client;
  String email;
  String adresse;
  String ville;
  String tele;
  String pays;
  String codepostale;
  String emailfacturation;
  String adressefacturation;
  String villefacturation;
  String telefacturation;
  String paysfacturation;
  String codepostalefacturation;
  List<Map<String, String>> produits;
  String facturation;
  String totale;

  VenteJson.fromJson(Map<String, dynamic> json) {
    id = json['_id'].toString();
    facture = json['facture'] as String;
    client = json['client'] as String;
    email = json['email'] as String;
    adresse = json['adresse'] as String;
    ville = json['ville'] as String;
    pays = json['pays'] as String;
    tele = json['tele'] as String;
    codepostale = json['codepostale'] as String;
    emailfacturation = json['emailfacturation'] as String;
    adressefacturation = json['adressefacturation'] as String;
    villefacturation = json['villefacturation'] as String;
    paysfacturation = json['paysfacturation'] as String;
    codepostalefacturation = json['codepostalefacturation'] as String;
    telefacturation = json['telefacturation'] as String;
    facturation = json['facturation'] as String;
    totale = json['totale'] as String;
    produits = new List<Map<String, String>>();
    json["produits"].toList().forEach((e) {
      Map<String, String> map = new Map<String, String>();
      map.putIfAbsent("produit", () => e["produit"]);
      map.putIfAbsent("qte", () => e["qte"]);
      produits.add(map);
    });
  }
}

//database

Future<List<dynamic>> getCollectionVentes() async {
  var db = await DBSingleton.instance.database;

  ObjectId objId = _Mongodb.ObjectId.parse(getSubID(globaleUser.id));

  DbCollection collection = db.collection('utilisateurs');
  var result = await collection.findOne(where.eq('_id', objId));

  //var clients = await collection.findOne({"nom": globaleUsername});

  //UtilisateurJson ventes = UtilisateurJson.fromJson(clients);
  return result["ventes"];
}

Future addVente(Vente vente) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');

  ObjectId objId = _Mongodb.ObjectId.parse(getSubID(globaleUser.id));
  var encoded = jsonEncode(vente);
  var doc = json.decode(encoded);
  var user = await collection.findOne(where.eq('_id', objId));

  if (user["ventes"] == null) {
    await collection.update(where.eq('_id', objId), {
      r'$set': {
        "ventes": [doc]
      }
    });
  } else {
    await collection.update(where.eq('_id', objId), {
      r'$push': {"ventes": doc}
    });
  }

  print('saved');
}

Future modifyVente(Vente vente) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');
  ObjectId objId = _Mongodb.ObjectId.parse(getSubID(globaleUser.id));

  var encoded = jsonEncode(vente);
  var doc = json.decode(encoded);

  await collection.update(where.eq('_id', objId).eq('ventes._id', vente.id), {
    r'$set': {'ventes.' r'$': doc}
  });

  print("modified");
}

Future addFactureVente(String facture, String venteId) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');
  ObjectId objId = _Mongodb.ObjectId.parse(getSubID(globaleUser.id));

  await collection.update(where.eq('_id', objId).eq('ventes._id', venteId), {
    r'$set': {'ventes.' r'$.facture': facture}
  });

  print("modified");
}

Future deleteVente(String id) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');

  ObjectId objId = _Mongodb.ObjectId.parse(getSubID(globaleUser.id));

  await collection.update(where.eq('_id', objId), {
    r'$pull': {
      "ventes": {'_id': id}
    }
  });

  print('data removed');
}
