import 'dart:convert';

import 'package:gestion_vente_app/model/vente.dart';
import 'package:gestion_vente_app/utility/mongodb.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:mongo_dart/mongo_dart.dart' as _Mongodb;
import 'package:mongo_dart/mongo_dart.dart';

class Utilisateur {
  String id;
  String nom;
  String motdepasse;
  String email;
  String tele;
  String role;
  String image;
  String statut;
  List<VenteJson> ventes;
  String cle;

  Categorie() {}

  Map toJson() => {
        'nom': getNom(),
        'motdepasse': getMotdepasse(),
        'email': getEmail(),
        'role': getRole(),
        'image': getImage(),
        'statut': getStatut(),
        'tele': getTele(),
        'ventes': getVentes(),
      };

  String getId() {
    return this.id;
  }

  void setId(code) {
    this.id = code;
  }

  List<VenteJson> getVentes() {
    return this.ventes;
  }

  void setVentes(ventes) {
    this.ventes = ventes;
  }

  String getMotdepasse() {
    return this.motdepasse;
  }

  void setMotdepasse(motdepasse) {
    this.motdepasse = motdepasse;
  }

  String getStatut() {
    return this.statut;
  }

  void setStatut(statut) {
    this.statut = statut;
  }

  String getNom() {
    return this.nom;
  }

  void setNom(nom) {
    this.nom = nom;
  }

  String getEmail() {
    return this.email;
  }

  void setEmail(email) {
    this.email = email;
  }

  String getRole() {
    return this.role;
  }

  void setRole(role) {
    this.role = role;
  }

  String getImage() {
    return this.image;
  }

  void setImage(image) {
    this.image = image;
  }

  String getTele() {
    return this.tele;
  }

  void setTele(tele) {
    this.tele = tele;
  }
}

class UtilisateurJson {
  String id;
  String nom;
  String motdepasse;
  String email;
  String tele;
  String role;
  String image;
  String statut;
  List<VenteJson> ventes;

  UtilisateurJson.fromJson(Map<String, dynamic> json) {
    id = json['_id'].toString();
    nom = json['nom'] as String;
    motdepasse = json['motdepasse'] as String;
    email = json['email'] as String;
    role = json['role'] as String;
    image = json['image'] as String;
    tele = json['tele'] as String;
    statut = json['statut'] as String;
    ventes = new List<VenteJson>();
    if (json["ventes"] != null) {
      json["ventes"].toList().forEach((e) {
        ventes.add(new VenteJson.fromJson(e));
      });
    }
  }
}

//database
Future<List<Map<String, dynamic>>> getCollectionUtilisateur() async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');
  var utilisateur = await collection.find().toList();

  return utilisateur;
}

Future<UtilisateurJson> getSingleUser() async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');
  ObjectId objId = _Mongodb.ObjectId.parse(getSubID(globaleUser.id));
  var data = await collection.findOne(where.eq('_id', objId));
  UtilisateurJson result = UtilisateurJson.fromJson(data);
  return result;
}

Future addUtilisateur(Utilisateur utilisateur) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');
  var user = await collection.findOne(where.eq('nom', utilisateur.nom));
  if (user == null) {
    var encoded = jsonEncode(utilisateur);
    var doc = json.decode(encoded);
    await collection.insertOne(doc);
    print('saved');
  }
}

Future modifyUtilisateuringleVal(String id, String key, String val) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.update(where.eq('_id', objId), {
    r'$set': {key: val}
  });
  print("modified");
}

Future modifyUtilisateur(Utilisateur utilisateur) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');
  ObjectId objId = _Mongodb.ObjectId.parse(getSubID(utilisateur.getId()));

  var encoded = jsonEncode(utilisateur);
  var doc = json.decode(encoded);

  await collection.update(where.eq('_id', objId), {
    r'$set': {
      "nom": utilisateur.getNom(),
      "motdepasse": utilisateur.getMotdepasse(),
      "email": utilisateur.getEmail(),
      "role": utilisateur.getRole(),
      "image": utilisateur.getImage(),
      "tele": utilisateur.getTele()
    }
  });
  print("modified");
}

Future deleteUtilisateur(String id) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.remove(await collection.findOne(where.eq('_id', objId)));

  print('data removed');
}
