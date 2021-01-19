
class Sensor {
  String name;
  int externalIdentfier;
  String locationName;
  double locationLat;
  double locationLon;
  int locationTimeZone;

  Sensor(String name, int externalIdentfier, String locationName, double locationLat, double locationLon, int locationTimeZone) {
    this.name = name;
    this.externalIdentfier = externalIdentfier;
    this.locationName = locationName;
    this.locationLat = locationLat;
    this.locationLon = locationLon;
    this.locationTimeZone = locationTimeZone;
  }
}