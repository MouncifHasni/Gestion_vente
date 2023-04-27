import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_vente_app/main.dart';
import 'package:gestion_vente_app/model/role.dart';
import 'package:gestion_vente_app/utility/theme.dart';
import 'package:gestion_vente_app/model/nav_model.dart';
import 'package:gestion_vente_app/utility/utility.dart';

import 'CollapsingListTile.dart';

class CollapsingNavDrawer extends StatefulWidget {
  final Function onSelectIndex;

  CollapsingNavDrawer({@required this.onSelectIndex});

  @override
  _CollapsingNavDrawer createState() => _CollapsingNavDrawer();
}

class _CollapsingNavDrawer extends State<CollapsingNavDrawer>
    with SingleTickerProviderStateMixin {
  double maxWidth = 230;
  double minWidth = 70;
  bool isCollapsed = false;
  //animation
  AnimationController _animationController;
  Animation<double> widthAnimation;
  Function myf;
  //selected item
  int currentSelectedIndex = 0;
  List<RoleJson> _listRoles;

  @override
  void initState() {
    super.initState();
    myf = widget.onSelectIndex;
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    widthAnimation = Tween<double>(begin: maxWidth, end: minWidth)
        .animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, widget) => getWidget(context, widget, myf));
  }

  Widget getWidget(context, widget, Function selectindex) {
    return Container(
      width: widthAnimation.value,
      color: drawarBackgroundColor,
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          ListTile(
            title: widthAnimation.value >= 220
                ? Text(globaleUsername.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600))
                : Text(""),
            leading: Container(
              child: CircleAvatar(
                radius: widthAnimation.value >= 220 ? 20 : 15,
                backgroundColor: Colors.transparent,
                child: globale_image == null
                    ? Image.asset(
                        "assets/default_user_icon.png",
                        height: 30,
                        width: 30,
                      )
                    : Image(
                        image: globale_image,
                        height: widthAnimation.value >= 220 ? 60 : 30,
                        width: widthAnimation.value >= 220 ? 60 : 30,
                      ),
              ),
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(
                  color: Colors.green,
                  width: 3.0,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
            height: 40,
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemBuilder: (context, counter) {
                return CollapsingListTile(
                  onTap: () {
                    if (counter == 6) {
                      Navigator.of(context).pushAndRemoveUntil(
                          new MaterialPageRoute(
                              builder: (context) => new LoginPage()),
                          (Route<dynamic> route) => false);
                      globale_image = null;
                    } else {
                      selectindex(context, counter);
                      setState(() {
                        currentSelectedIndex = counter;
                      });
                    }
                  },
                  isSelected: currentSelectedIndex == counter,
                  title: globalRole.contains("administrateur")
                      ? navlist[counter].title
                      : commerciantnavlist[counter].title,
                  icon: globalRole.contains("administrateur")
                      ? navlist[counter].icon
                      : commerciantnavlist[counter].icon,
                  animationController: _animationController,
                  isExpansionTile: counter == 2 ? true : false,
                );
              },
              itemCount: globalRole.contains("administrateur")
                  ? navlist.length
                  : commerciantnavlist.length,
            ),
          ),
          InkWell(
              onTap: () {
                setState(() {
                  isCollapsed = !isCollapsed;
                  isCollapsed
                      ? _animationController.forward()
                      : _animationController.reverse();
                });
              },
              child: AnimatedIcon(
                  icon: AnimatedIcons.close_menu,
                  progress: _animationController,
                  color: Colors.white,
                  size: 40)),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
