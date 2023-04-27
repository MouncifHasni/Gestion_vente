import 'dart:convert';

import 'package:gestion_vente_app/utility/mongodb.dart';
import 'package:mongo_dart/mongo_dart.dart' as _Mongodb;
import 'package:mongo_dart/mongo_dart.dart';

class Role {
  String id;
  String nom;
  String desc;

  Role() {}

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

class RoleJson {
  String id;
  String nom;
  String desc;

  RoleJson.fromJson(Map<String, dynamic> json) {
    id = json['_id'].toString();
    nom = json['nom'] as String;
    desc = json['desc'] as String;
  }
}

//database
Future<List<Map<String, dynamic>>> getCollectionRoles() async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('roles');
  var roles = await collection.find().toList();

  return roles;
}

Future addRole(Role role) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('roles');

  var encoded = jsonEncode(role);
  var doc = json.decode(encoded);
  await collection.insertOne(doc);
  print('saved');
}

Future modifyRoleSingleVal(String id, String key, String val) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('roles');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.update(where.eq('_id', objId), {
    r'$set': {key: val}
  });
  print("modified");
}

Future deleteRole(String id) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('roles');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.remove(await collection.findOne(where.eq('_id', objId)));

  print('data removed');
}
