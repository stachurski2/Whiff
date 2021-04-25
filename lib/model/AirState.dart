import 'package:Whiff/helpers/app_localizations.dart';
import 'package:flutter/material.dart';

enum AirState {
  good,
  moderate,
  bad,
  veryBad,
  unknown
}

extension AirStateExtension on AirState {
  String string(BuildContext context) {
    switch(this) {
      case AirState.good:
        return AppLocalizations.of(context).translate("measurement_state_good");
      case AirState.moderate:
        return AppLocalizations.of(context).translate("measurement_state_moderate");
      case AirState.bad:
        return AppLocalizations.of(context).translate("measurement_state_bad");
      case AirState.veryBad:
        return AppLocalizations.of(context).translate("measurement_state_very_bad");
      case AirState.unknown:
        return AppLocalizations.of(context).translate("measurement_state_unknown");
    }
  }
}
