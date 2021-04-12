import 'package:Whiff/model/AirState.dart';

class Measurement {
 double temperature;
  double pm1Level;
  double pm10Level;
  double pm25level;
  double humidity;
  double formaldehyde;
  double co2level;
  DateTime date;

  Measurement(double pm1Level, double pm10Level, double pm25level, double humidity, double formaldehyde, double co2level, double temperature, DateTime date) {
    this.pm1Level = pm1Level;
    this.pm10Level = pm10Level;
    this.pm25level = pm25level;
    this.humidity = humidity;
    this.formaldehyde = formaldehyde;
    this.co2level = co2level;
    this.date = date;
     this.temperature = temperature;
  }

  AirState getState() {
    if(pm1Level == null || pm10Level == null || pm25level == null || humidity == null || formaldehyde == null || co2level == null || formaldehyde == null  ) {
      return AirState.unknown;
    } else {
      if(pm1Level < 25 && pm25level < 35 && pm10Level < 50 && formaldehyde <= 50 && humidity >= 40 &&  humidity <= 60 && co2level <= 900) {
        return AirState.good;
      } else if (pm1Level <= 40 && pm25level <=56 && pm10Level <= 80 && formaldehyde <= 120 && humidity <= 40 && humidity >= 30  && co2level <= 1000 ) {
        return AirState.moderate;
      } else if (pm1Level <= 50 && pm25level <= 70 && pm10Level <= 100 && formaldehyde <= 120 && humidity >= 30 && humidity <= 60 && co2level <= 1000) {
        return AirState.bad;
      } else {
        return AirState.veryBad;
      }
    }
  }
}