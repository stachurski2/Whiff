
class Sensor {
  String name;
  int externalIdentfier;
  String locationName;
  double locationLat;
  double locationLon;
  int locationTimeZone;
  bool isInsideBuilding;

  Sensor(String name, int externalIdentfier, String locationName, double locationLat, double locationLon, int locationTimeZone, bool isInsideBuilding) {
    this.name = name;
    this.externalIdentfier = externalIdentfier;
    this.locationName = locationName;
    this.locationLat = locationLat;
    this.locationLon = locationLon;
    this.locationTimeZone = locationTimeZone;
    this.isInsideBuilding = isInsideBuilding;
  }
}