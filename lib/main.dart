import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_vente_app/Pages/main_page.dart';
import 'package:gestion_vente_app/utility/mongodb.dart';
import 'package:gestion_vente_app/utility/utility.dart';

import 'utility/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des ventes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showpassword = false;

  void onLogInBtnClicked() async {
    String result;
    if (checkControllers()) {
      showLoaderDialog(context);
      getUserAuthentification(
              _usernameController.text.toLowerCase(), _passwordController.text)
          .then((value) => result = value)
          .whenComplete(() {
        Navigator.pop(context);
        if (result != null) {
          if (result.isNotEmpty) {
            if (result.startsWith("ok")) {
              globaleUsername = _usernameController.text;
              if (result.length > 4) {
                readImage(result.substring(2)).then((value) {
                  setState(() {
                    globale_image = value;
                  });
                }).whenComplete(() {
                  Navigator.of(context).pushAndRemoveUntil(
                      new MaterialPageRoute(
                          builder: (context) => new Main_page()),
                      (Route<dynamic> route) => false);
                });
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                    new MaterialPageRoute(
                        builder: (context) => new Main_page()),
                    (Route<dynamic> route) => false);
              }
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                  new MaterialPageRoute(
                      builder: (context) => new ChangePasswordPage(id: result)),
                  (Route<dynamic> route) => false);
            }
          } else {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  Future.delayed(Duration(milliseconds: 1000), () {
                    Navigator.of(context).pop(true);
                  });
                  return AlertDialog(
                    title: Image.asset(
                      'assets/remove.png',
                      height: 50,
                      width: 50,
                    ),
                    content: Text(
                      "Nom ou mot de passe est incorrect!",
                      textAlign: TextAlign.center,
                    ),
                  );
                });
          }
        } else {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Image.asset(
                    'assets/remove.png',
                    height: 50,
                    width: 50,
                  ),
                  content: Text(
                    "Vérifier votre connection!",
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _reset();
                        },
                        child: Text("Fermer"))
                  ],
                );
              });
        }
      });
    }
  }

  void _reset() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => LoginPage(),
      ),
    );
  }

  bool checkControllers() {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            Future.delayed(Duration(milliseconds: 1000), () {
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
              title: Image.asset(
                'assets/remove.png',
                height: 50,
                width: 50,
              ),
              content: Text(
                "Vous devez remplir tous les champs",
                textAlign: TextAlign.center,
              ),
            );
          });
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: drawarBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: getWidgetHeight(70),
          ),
          CircleAvatar(
            child: Icon(
              FontAwesomeIcons.user,
              size: 40,
            ),
            radius: 40,
            backgroundColor: Colors.white,
          ),
          SizedBox(
            height: getWidgetHeight(20),
          ),
          Container(
            width: getWidgetWidth(350),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                SizedBox(
                  height: getWidgetHeight(30),
                ),
                Text(
                  "Connexion",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: getWidgetHeight(30),
                ),
                Container(
                  width: getWidgetWidth(300),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                        labelText: "Nom d'utilisateur",
                        suffixIcon: Icon(
                          FontAwesomeIcons.user,
                          size: 17,
                        )),
                  ),
                ),
                Container(
                  width: getWidgetWidth(300),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_showpassword,
                    decoration: InputDecoration(
                        labelText: "Mot de passe",
                        suffixIcon: IconButton(
                          icon: Icon(
                            this._showpassword
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                            size: 17,
                          ),
                          onPressed: () {
                            setState(() {
                              this._showpassword = !this._showpassword;
                            });
                          },
                        )),
                  ),
                ),
                /*Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Mot de passe oublié?',
                            style: TextStyle(color: Colors.blue),
                          ),
                        )
                      ],
                    )),*/
                SizedBox(
                  height: getWidgetHeight(15),
                ),
                SizedBox(
                  width: getWidgetWidth(300),
                  height: getWidgetHeight(35),
                  child: ElevatedButton(
                      child: Text('Se connecter'),
                      style: ButtonStyle(),
                      onPressed: () => onLogInBtnClicked()),
                ),
                SizedBox(height: 10),
                /*InkWell(
                  onTap: () {},
                  child: Text('Sign Up Now',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.normal)),
                ),*/
                SizedBox(
                  height: getWidgetHeight(10),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  double getWidgetWidth(double nb) {
    return MediaQuery.of(context).size.width * nb / 1265;
  }

  double getWidgetHeight(double nb) {
    return MediaQuery.of(context).size.height * nb / 646;
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7),
              child: Text("Chargement en cours...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  final String id;

  ChangePasswordPage({@required this.id});

  @override
  _ChangePasswordPage createState() => _ChangePasswordPage();
}

class _ChangePasswordPage extends State<ChangePasswordPage> {
  final _comfirmpasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showpassword = false;

  void onSubmitClicked() async {
    if (checkPasswordMatches()) {
      changeUserPassword(
              widget.id, getEncryptedPassword(_passwordController.text))
          .whenComplete(() {
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (context) => new LoginPage()),
            (Route<dynamic> route) => false);
      });
    }
  }

  bool checkPasswordMatches() {
    if (_comfirmpasswordController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            Future.delayed(Duration(milliseconds: 1000), () {
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
              title: Image.asset(
                'assets/remove.png',
                height: 50,
                width: 50,
              ),
              content: Text(
                "Entrer un mot de passe!",
                textAlign: TextAlign.center,
              ),
            );
          });
      return false;
    } else {
      if (_comfirmpasswordController.text == _passwordController.text) {
        return true;
      } else {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.of(context).pop(true);
              });
              return AlertDialog(
                title: Image.asset(
                  'assets/remove.png',
                  height: 50,
                  width: 50,
                ),
                content: Text(
                  "Mot de passe n'est pas convenable!",
                  textAlign: TextAlign.center,
                ),
              );
            });
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: drawarBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: getWidgetHeight(70),
          ),
          CircleAvatar(
            child: Icon(
              FontAwesomeIcons.user,
              size: 40,
            ),
            radius: 40,
            backgroundColor: Colors.white,
          ),
          SizedBox(
            height: getWidgetHeight(20),
          ),
          Container(
            width: getWidgetWidth(350),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                SizedBox(
                  height: getWidgetHeight(30),
                ),
                Text(
                  "Changer mot de passe",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: getWidgetHeight(30),
                ),
                Container(
                  width: getWidgetWidth(300),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        labelText: "Mot de passe",
                        suffixIcon: Icon(
                          FontAwesomeIcons.user,
                          size: 17,
                        )),
                  ),
                ),
                Container(
                  width: getWidgetWidth(300),
                  child: TextField(
                    controller: _comfirmpasswordController,
                    obscureText: !_showpassword,
                    decoration: InputDecoration(
                        labelText: "Comfirmer mot de passe",
                        suffixIcon: IconButton(
                          icon: Icon(
                            this._showpassword
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                            size: 17,
                          ),
                          onPressed: () {
                            setState(() {
                              this._showpassword = !this._showpassword;
                            });
                          },
                        )),
                  ),
                ),
                SizedBox(
                  height: getWidgetHeight(15),
                ),
                SizedBox(
                  width: getWidgetWidth(300),
                  height: getWidgetHeight(35),
                  child: ElevatedButton(
                      child: Text('Valider'),
                      style: ButtonStyle(),
                      onPressed: () => onSubmitClicked()),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        new MaterialPageRoute(
                            builder: (context) => new LoginPage()),
                        (Route<dynamic> route) => false);
                  },
                  child: Text('Se connecter?',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal)),
                ),
                SizedBox(
                  height: getWidgetHeight(10),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  double getWidgetWidth(double nb) {
    return MediaQuery.of(context).size.width * nb / 1265;
  }

  double getWidgetHeight(double nb) {
    return MediaQuery.of(context).size.height * nb / 646;
  }
}
