import 'dart:convert';

import 'package:gestion_vente_app/utility/mongodb.dart';
import 'package:gestion_vente_app/utility/utility.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Facture {
  String id;
  String total;
  String date;
  String commerciant;

  Map toJson() => {
        '_id': getId(),
        'total': getTotal(),
        'date': getDate(),
        'commerciant': getCommerciant()
      };

  String getId() {
    return this.id;
  }

  void setId(id) {
    this.id = id;
  }

  String getCommerciant() {
    return this.commerciant;
  }

  void setCommerciant(commerciant) {
    this.commerciant = commerciant;
  }

  String getTotal() {
    return this.total;
  }

  void setTotal(total) {
    this.total = total;
  }

  String getDate() {
    return this.date;
  }

  void setDate(date) {
    this.date = date;
  }
}

class FactureJson {
  String id;
  String total;
  String date;
  String commerciant;

  FactureJson.fromJson(Map<String, dynamic> json) {
    id = json['_id'].toString();
    total = json['total'] as String;
    date = json['date'] as String;
    commerciant = json['commerciant'] as String;
  }
}

Future<List<Map<String, dynamic>>> getCollectionFactures() async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('factures');
  var factures;
  if (globalRole.contains("administrateur")) {
    factures = await collection.find().toList();
  } else {
    factures = await collection
        .find(where.eq('commerciant', getSubID(globaleUser.id)))
        .toList();
  }

  return factures;
}

Future addFacture(Facture facture) async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('factures');

  var encoded = jsonEncode(facture);
  var doc = json.decode(encoded);
  await collection.insertOne(doc);
  print('facture saved');
}

Future<String> getVentesCount() async {
  var db = await DBSingleton.instance.database;

  DbCollection collection = db.collection('factures');
  var number;
  if (globalRole.contains("administrateur")) {
    number = await collection.count();
  } else {
    number = await collection
        .count(where.eq('commerciant', getSubID(globaleUser.id)));
  }

  return number.toString();
}
