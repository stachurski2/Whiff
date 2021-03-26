
enum MeasurementType {
   temperature,
   pm1level,
   pm10level,
   pm25level,
   humidity,
   formaldehyde,
   co2level,
}


extension MeasurementTypeExtension on MeasurementType {

  static List<MeasurementType> allTypes() {
    return [MeasurementType.temperature, MeasurementType.pm1level,MeasurementType.pm10level,MeasurementType.pm25level,MeasurementType.humidity,MeasurementType.formaldehyde,MeasurementType.co2level, ].toList();
  }

  String stringName() {
    switch(this) {
     case MeasurementType.temperature:
       return "measurement_type_temperature";
     case MeasurementType.pm1level:
       return "measurement_type_pm1level";
      case MeasurementType.pm10level:
        return "measurement_type_pm10level";
      case MeasurementType.pm25level:
        return "measurement_type_pm25level";
      case MeasurementType.humidity:
        return "measurement_type_humidity";
      case MeasurementType.formaldehyde:
         return "measurement_type_formaldehyde";
      case MeasurementType.co2level:
         return "measurement_type_co2level";
    }
  }

    String unitName() {
      switch(this) {
       case MeasurementType.temperature:
         return "measurement_type_temperature_unit";
       case MeasurementType.pm1level:
         return "measurement_type_pm1level_unit";
        case MeasurementType.pm10level:
          return "measurement_type_pm10level_unit";
        case MeasurementType.pm25level:
          return "measurement_type_pm25level_unit";
        case MeasurementType.humidity:
          return "measurement_type_humidity_unit";
        case MeasurementType.formaldehyde:
           return "measurement_type_formaldehyde_unit";
        case MeasurementType.co2level:
           return "measurement_type_co2level_unit";
      }
    }
}

