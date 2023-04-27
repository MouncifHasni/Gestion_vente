import 'dart:convert';

import 'package:gestion_vente_app/utility/mongodb.dart';
import 'package:mongo_dart/mongo_dart.dart' as _Mongodb;
import 'package:mongo_dart/mongo_dart.dart';

class Categorie {
  String id;
  String nom;
  String desc;

  Categorie() {}

  Map toJson() => {'nom': getNom(), 'desc': getDesc()};

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
}

class CategorieJson {
  String id;
  String nom;
  String desc;

  CategorieJson.fromJson(Map<String, dynamic> json) {
    id = json['_id'].toString();
    nom = json['nom'] as String;
    desc = json['desc'] as String;
  }
}

//database
Future<List<Map<String, dynamic>>> getCollectionCategories() async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('categories');
  var categories = await collection.find().toList();

  return categories;
}

Future addCategorie(Categorie categorie) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('categories');

  var encoded = jsonEncode(categorie);
  var doc = json.decode(encoded);
  await collection.insertOne(doc);
  print('saved');
}

Future modifyCategorieSingleVal(String id, String key, String val) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('categories');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.update(where.eq('_id', objId), {
    r'$set': {key: val}
  });
  print("modified");
}

Future deleteCategorie(String id) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('categories');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.remove(await collection.findOne(where.eq('_id', objId)));

  print('data removed');
}
