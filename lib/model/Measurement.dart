import 'package:Whiff/model/AirState.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:flutter/material.dart';
enum MeasurementLevel {
  good,
  moderate,
  bad,
  veryBad
}

extension MeasurementLevelExtension on MeasurementLevel {
   Color get levelColor {
      switch(this) {
        case MeasurementLevel.good:
          return ColorProvider.shared.measurumentGoodLevel;
        case MeasurementLevel.moderate:
          return ColorProvider.shared.measurumentModerateLevel;
        case MeasurementLevel.bad:
          return ColorProvider.shared.measurumentBadLevel;
        case MeasurementLevel.veryBad:
          return ColorProvider.shared.measurumentVeryBadLevel;
      }
   }
}



class Measurement {
  double temperature;
  double pm1Level;
  double pm10Level;
  double pm25level;
  double humidity;
  double formaldehyde;
  double co2level;
  DateTime date;

  Measurement(double pm1Level, double pm10Level, double pm25level,
      double humidity, double formaldehyde, double co2level, double temperature,
      DateTime date) {
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
    if (pm1Level == null || pm10Level == null || pm25level == null) {
      return AirState.unknown;
    } else {
      if (pm1Level < 25 && pm25level < 35 && pm10Level < 50) {
        return AirState.good;
      } else if (pm1Level <= 40 && pm25level <= 56 && pm10Level <= 80) {
        return AirState.moderate;
      } else if (pm1Level <= 50 && pm25level <= 70 && pm10Level <= 100) {
        return AirState.bad;
      } else {
        return AirState.veryBad;
      }
    }
  }

  MeasurementLevel pm1LevelNorm() {
    if (pm1Level < 25) {
      return MeasurementLevel.good;
    } else if (pm1Level <= 40) {
      return MeasurementLevel.moderate;
    } else if (pm1Level <= 50) {
      return MeasurementLevel.bad;
    } else {
      return MeasurementLevel.veryBad;
    }
  }

  MeasurementLevel pm25LevelNorm() {
    if (pm25level < 35) {
      return MeasurementLevel.good;
    } else if (pm25level <= 56) {
      return MeasurementLevel.moderate;
    } else if (pm25level <= 70) {
      return MeasurementLevel.bad;
    } else {
      return MeasurementLevel.veryBad;
    }
  }

  MeasurementLevel pm10LevelNorm() {
    if (pm10Level < 50) {
      return MeasurementLevel.good;
    } else if (pm10Level <= 80) {
      return MeasurementLevel.moderate;
    } else if (pm10Level <= 100) {
      return MeasurementLevel.bad;
    } else {
      return MeasurementLevel.veryBad;
    }
  }

  MeasurementLevel formaldehydeLevelNorm() {
    if (formaldehyde <= 50) {
      return MeasurementLevel.good;
    } else if (formaldehyde <= 120) {
      return MeasurementLevel.moderate;
    } else {
      return MeasurementLevel.veryBad;
    }
  }

  MeasurementLevel humidityNorm() {
    if (humidity >= 40 && humidity <= 60) {
      return MeasurementLevel.good;
    } else if (humidity >= 30 && humidity < 40) {
      return MeasurementLevel.moderate;
    } else {
      return MeasurementLevel.veryBad;
    }
  }


  MeasurementLevel co2LevelNorm() {
    if (co2level <= 900) {
      return MeasurementLevel.good;
    } else if (co2level >= 900 && co2level <= 1000) {
      return MeasurementLevel.moderate;
    } else {
      return MeasurementLevel.veryBad;
    }
  }
}