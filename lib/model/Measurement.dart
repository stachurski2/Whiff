
class Measurement {

  double pm1Level;
  double pm10Level;
  double pm25level;
  double humidity;
  double formaldehyde;
  double co2level;
  DateTime date;

  Measurement(double pm1Level, double pm10Level, double pm25level, double humidity, double formaldehyde, double co2level, DateTime date) {
    this.pm1Level = pm1Level;
    this.pm10Level = pm10Level;
    this.pm25level = pm25level;
    this.humidity = humidity;
    this.formaldehyde = formaldehyde;
    this.co2level = co2level;
    this.date = date;
  }
}