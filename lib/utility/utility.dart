import 'dart:math';

import 'package:encrypt/encrypt.dart' as _encrypt;
import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:gestion_vente_app/model/categorie.dart';
import 'package:gestion_vente_app/model/client.dart';
import 'package:gestion_vente_app/model/fournisseur.dart';
import 'package:gestion_vente_app/model/produit.dart';
import 'package:gestion_vente_app/model/role.dart';
import 'package:gestion_vente_app/model/utilisateur.dart';

TValue case2<TOptionType, TValue>(
  TOptionType selectedOption,
  Map<TOptionType, TValue> branches, [
  TValue defaultValue = null,
]) {
  if (!branches.containsKey(selectedOption)) {
    return defaultValue;
  }

  return branches[selectedOption];
}

String getSubID(String val) {
  var result = val.substring(10, 34);
  return result;
}

String globalRole = '';
String globaleUsername = '';
ImageProvider globale_image;
UtilisateurJson globaleUser;

String getIdFournisseur(List<FournisseurJson> listfournisseur, String val) {
  val = val.replaceAll(new RegExp(r"\s+\b|\b\s"), "").toLowerCase();

  for (FournisseurJson data in listfournisseur) {
    String concat = (data.nom + data.prenom).toLowerCase();
    concat = concat.toLowerCase();

    if (concat.contains(val)) {
      return getSubID(data.id);
    }
  }
  return null;
}

String getNometPrenomFournisseur(
    List<FournisseurJson> listfournisseur, String id) {
  for (FournisseurJson data in listfournisseur) {
    if (data.id.contains(id)) {
      String concat = (data.nom + ' ' + data.prenom);
      return concat;
    }
  }
  return null;
}

//Categories
String getIdCategorie(List<CategorieJson> listcats, String val) {
  for (CategorieJson data in listcats) {
    if (data.nom.toLowerCase().contains(val.toLowerCase())) {
      return getSubID(data.id);
    }
  }
  return null;
}

String getNomCategorie(List<CategorieJson> listcats, String id) {
  for (CategorieJson data in listcats) {
    if (data.id.contains(id)) {
      return data.nom;
    }
  }
  return null;
}

//Roles
String getIdRole(List<RoleJson> listroles, String val) {
  for (RoleJson data in listroles) {
    if (data.nom.toLowerCase().contains(val.toLowerCase())) {
      return getSubID(data.id);
    }
  }
  return null;
}

String getNomRole(List<RoleJson> listroles, String id) {
  for (RoleJson data in listroles) {
    if (data.id.contains(id)) {
      return data.nom;
    }
  }
  return null;
}

//Client

String getIdClientFromNom(List<ClientJson> listclients, String val) {
  for (ClientJson data in listclients) {
    if (val.contains(data.nom) && val.contains(data.prenom)) {
      return data.id;
    }
  }
}

String getNomClientfromID(List<ClientJson> listclients, String val) {
  for (ClientJson data in listclients) {
    if (data.id.contains(val)) {
      return data.nom + " " + data.prenom;
    }
  }
}

//Produits
List<SelectedProduitModel> getListSelectedProducts(
    List<Map<String, String>> listproduits) {
  List<SelectedProduitModel> result = new List<SelectedProduitModel>();
  ProduitJson produit;

  listproduits.forEach((e) {
    findProduit(e["produit"].toString()).then((value) {
      produit = ProduitJson.fromJson(value);
      SelectedProduitModel model =
          new SelectedProduitModel(produit, int.parse(e["qte"]), true);
      result.add(model);
    });
  });
  return result;
}

List<SelectedProduitModel> getListSelectedProducts_s(
    List<SelectedProduitModel> listproduits,
    List<Map<String, String>> myproducts) {
  List<SelectedProduitModel> result = new List<SelectedProduitModel>();

  listproduits.forEach((e) {
    myproducts.forEach((element) {
      if (e.produit.id.contains(element["produit"])) {
        SelectedProduitModel model = new SelectedProduitModel(
            e.produit, int.parse(element["qte"]), true);
        result.add(model);
      }
    });
  });
  return result;
}

//Get random ID
String getRandomString(int length) {
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

//Encryption

String getEncryptedPassword(String text) {
  final key = _encrypt.Key.fromLength(16);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));

  final result = encrypter.encrypt(text, iv: iv);
  return result.base64;
}

String getDecryptedPassword(String password) {
  final key = _encrypt.Key.fromLength(16);
  final iv = IV.fromLength(16);
  final _encrypter = Encrypter(AES(key));

  final result = _encrypter.decrypt64(password, iv: iv);
  return result;
}
