import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestion_vente_app/model/role.dart';
import 'package:gestion_vente_app/model/utilisateur.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/mongo_dart.dart' as _Mongodb;

class DBSingleton {
  static final DBSingleton _dbSingleton = DBSingleton._internal();
  static DBSingleton get instance => _dbSingleton;
  static Db _db;

  factory DBSingleton() {
    return _dbSingleton;
  }
  DBSingleton._internal();

  Future<Db> get database async {
    if (_db != null) return _db;

    // if _database is null we instantiate it
    print("initializing db");
    /*_db = await Db.create(
        'mongodb+srv://admin:admin@cluster0.n6qtk.mongodb.net/gestiondesventes?retryWrites=true&w=majority');*/ //Atlas mongoDB
    _db = Db(
        'mongodb://127.0.0.1:27017/gestiondesventes'); //votre base de donnée en localhost
    try {
      await _db.open();
    } catch (e) {
      print(e);
    }
    print("db inizialized");
    return _db;
  }
}

//authentification
Future<String> getUserAuthentification(String username, String password) async {
  var db = await DBSingleton.instance.database;

  if (db.isConnected) {
    DbCollection collection = db.collection('utilisateurs');

    var user = await collection.findOne(where.eq('nom', username));

    if (user != null) {
      if (getDecryptedPassword(user["motdepasse"].toString()) == password) {
        if (user['statut'] == '0') return getSubID(user["_id"].toString());

        if (user["image"].toString().length > 4) {
          globaleUser = UtilisateurJson.fromJson(user);
          var roles;
          await getCollectionRoles().then((value) => roles = value);

          for (var c in roles) {
            RoleJson data = RoleJson.fromJson(c);
            if (data.id.contains(globaleUser.role)) {
              globalRole = data.nom;
            }
          }
          return "ok" + user["image"].toString();
        } else {
          globaleUser = UtilisateurJson.fromJson(user);
          var roles;
          await getCollectionRoles().then((value) => roles = value);

          for (var c in roles) {
            RoleJson data = RoleJson.fromJson(c);
            if (data.id.contains(globaleUser.role)) {
              globalRole = data.nom;
            }
          }
          return "ok";
        }
      } else {
        return '';
      }
    } else {
      return '';
    }
  } else {
    return null;
  }
}

/*
Future<String> getUserAuthentification(String username, String password) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');

  var user = await collection
      .findOne(where.eq('nom', username).eq('motdepasse', password));
  if (user != null) {
    if (user['statut'] == '0') return getSubID(user["_id"].toString());

    if (user["image"].toString().length > 4) {
      globaleUser = UtilisateurJson.fromJson(user);
      var roles;
      await getCollectionRoles().then((value) => roles = value);

      for (var c in roles) {
        RoleJson data = RoleJson.fromJson(c);
        if (data.id.contains(globaleUser.role)) {
          globalRole = data.nom;
        }
      }
      return "ok" + user["image"].toString();
    } else {
      globaleUser = UtilisateurJson.fromJson(user);
      var roles;
      await getCollectionRoles().then((value) => roles = value);

      for (var c in roles) {
        RoleJson data = RoleJson.fromJson(c);
        if (data.id.contains(globaleUser.role)) {
          globalRole = data.nom;
        }
      }
      return "ok";
    }
  } else {
    return '';
  }
}
*/

Future<void> changeUserPassword(String id, String password) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('utilisateurs');
  ObjectId objId = _Mongodb.ObjectId.parse(id);

  await collection.update(where.eq('_id', objId), {
    r'$set': {'motdepasse': password, 'statut': '1'}
  });
}

Future<ImageProvider> readImage(String id) async {
  var _db = await DBSingleton.instance.database;
  GridFS bucket = await GridFS(_db, "image");

  var img = await bucket.chunks.findOne({"_id": id});

  return MemoryImage(base64Decode(img["data"]));
}
