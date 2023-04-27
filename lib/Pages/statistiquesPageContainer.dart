import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_vente_app/model/chartmodel.dart';
import 'package:gestion_vente_app/model/facture.dart';
import 'package:intl/intl.dart';

class StatistiquesPageContainer extends StatefulWidget {
  @override
  _StatistiquesPageContainer createState() => _StatistiquesPageContainer();
}

class _StatistiquesPageContainer extends State<StatistiquesPageContainer> {
  List<FactureJson> _listfactures;
  List<ChartModel> _listrevenue = [];
  double _maxRevenue = 20000;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fillListRevenue(_selectedDate.year);
    getFacturesData().then((value) {
      _listfactures = value;
      setState(() {
        setModelChartList(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15,
        ),
        Center(
          child: Text(
            "Statistiques",
            style: TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 38),
              child: Text("Revenue (Dhs)",
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.calendarAlt,
                color: Colors.green,
              ),
              iconSize: 17,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Choisir l'année"),
                      content: Container(
                        // Need to use container to add size constraint.
                        width: 300,
                        height: 300,
                        child: YearPicker(
                          firstDate: DateTime(DateTime.now().year - 10, 1),
                          lastDate: DateTime(DateTime.now().year + 100, 1),
                          initialDate: DateTime.now(),
                          // save the selected date to _selectedDate DateTime variable.
                          // It's used to set the previous selected date when
                          // re-showing the dialog.
                          selectedDate: _selectedDate,
                          onChanged: (DateTime dateTime) {
                            // close the dialog when year is selected.
                            Navigator.pop(context);
                            setState(() {
                              _selectedDate = dateTime;
                              setModelChartByPeriode();
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        _buildChart(),
      ],
    ));
  }

  List<Color> _listcolors = [Colors.green[400], Colors.green];

  Widget _buildChart() {
    return Container(
      height: 350,
      margin: EdgeInsets.only(right: 30, left: 12),
      child: BarChart(
        BarChartData(
          maxY: _maxRevenue,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
              show: true,
              leftTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) {
                    switch (value.toInt()) {
                      case 0:
                        return '0';
                      case 5000:
                        return '5k';
                      case 10000:
                        return '10K';
                      case 15000:
                        return '15k';
                      case 20000:
                        return '20K';
                      case 25000:
                        return '25k';
                      case 30000:
                        return '30K';
                      case 35000:
                        return '35k';
                      case 40000:
                        return '40K';
                      default:
                    }
                  }),
              bottomTitles: SideTitles(
                  margin: 10.0,
                  showTitles: true,
                  rotateAngle: 0,
                  getTitles: (double value) {
                    switch (value.toInt()) {
                      case 1:
                        return 'Janvier';
                      case 2:
                        return 'Février';
                      case 3:
                        return 'Mars';
                      case 4:
                        return 'Avril';
                      case 5:
                        return 'Mai';
                      case 6:
                        return 'Juin';
                      case 7:
                        return 'Juillet';
                      case 8:
                        return 'Août';
                      case 9:
                        return 'Septembre';
                      case 10:
                        return 'Octobre';
                      case 11:
                        return 'Novembre';
                      case 12:
                        return 'Décembre';
                      default:
                        return '';
                    }
                  })),
          barGroups: _listrevenue
              .asMap()
              .map((key, value) => MapEntry(
                  value.mois,
                  BarChartGroupData(x: value.mois, barRods: [
                    BarChartRodData(y: value.revenue, colors: _listcolors)
                  ])))
              .values
              .toList(),
        ),
      ),
    );
  }

  void fillListRevenue(int year) {
    for (int i = 1; i <= 12; i++) {
      ChartModel model = new ChartModel(revenue: 0, mois: i);
      model.setYear(year);
      _listrevenue.add(model);
    }
  }

  void setModelChartList(List<FactureJson> factures) {
    factures.forEach((element) {
      DateTime date = new DateFormat("dd-MM-yyyy").parse(element.date);
      setState(() {
        if (date.year == 2021) {
          _listrevenue
              .elementAt(date.month - 1)
              .setRevenue(double.parse(element.total));
        }
      });
    });
    setMaxRevenue();
  }

  /*factures.forEach((element) {
      DateTime date = new DateFormat("dd-MM-yyyy").parse(element.date);
      setState(() {
        _listrevenue
            .elementAt(date.month - 1)
            .setRevenue(double.parse(element.total));
      });
    });
    setMaxRevenue();
  */

  void setModelChartByPeriode() {
    _listrevenue.clear();
    fillListRevenue(_selectedDate.year);
    _listfactures.forEach((element) {
      DateTime date = new DateFormat("dd-MM-yyyy").parse(element.date);
      setState(() {
        if (date.year == _selectedDate.year) {
          _listrevenue
              .elementAt(date.month - 1)
              .setRevenue(double.parse(element.total));
        }
      });
    });
    setMaxRevenue();
  }

  void setMaxRevenue() {
    _maxRevenue = 20000;
    _listrevenue.forEach((element) {
      if (element.revenue > _maxRevenue)
        setState(() {
          _maxRevenue = element.revenue + 5000;
        });
    });
  }

  Future<List<FactureJson>> getFacturesData() async {
    List<FactureJson> facturelist = List<FactureJson>();
    var factures;
    await getCollectionFactures().then((value) => factures = value);

    for (var c in factures) {
      facturelist.add(FactureJson.fromJson(c));
    }
    return facturelist;
  }
}
