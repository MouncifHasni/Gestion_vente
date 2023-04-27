class ChartModel {
  double revenue;
  int mois;
  int year;

  ChartModel({this.revenue, this.mois});

  double getRevenue() {
    return this.revenue;
  }

  void setRevenue(revenue) {
    if (this.revenue == null)
      this.revenue = revenue;
    else
      this.revenue += revenue;
  }

  int getMois() {
    return this.mois;
  }

  void setMois(mois) {
    this.mois = mois;
  }

  int getYear() {
    return this.year;
  }

  void setYear(year) {
    this.year = year;
  }
}
