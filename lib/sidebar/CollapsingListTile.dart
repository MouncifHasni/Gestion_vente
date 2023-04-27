import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_vente_app/utility/theme.dart';

class CollapsingListTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final AnimationController animationController;
  final bool isSelected;
  final Function onTap;
  final bool isExpansionTile;

  CollapsingListTile(
      {@required this.title,
      @required this.icon,
      @required this.animationController,
      this.isSelected = false,
      this.onTap,
      this.isExpansionTile = false});

  @override
  _CollapsingListTile createState() => _CollapsingListTile();
}

class _CollapsingListTile extends State<CollapsingListTile> {
  Animation<double> widthAnimation;

  @override
  void initState() {
    super.initState();
    widthAnimation =
        Tween<double>(begin: 230, end: 70).animate(widget.animationController);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: widget.isSelected
                ? Colors.transparent.withOpacity(0.3)
                : Colors.transparent),
        width: widthAnimation.value,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: widget.isSelected ? selectedColor : Colors.white30,
              size: 33,
            ),
            SizedBox(
              width: 10,
            ),
            (widthAnimation.value >= 220)
                ? Text(
                    widget.title,
                    style: widget.isSelected
                        ? listTileSelectedTextStyle
                        : listTileDefaultTextStyle,
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
