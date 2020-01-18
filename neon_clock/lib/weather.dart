// Copyright 2020 Ben Brosius. Adapted from code by the Chromium team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

class Weather {
  AssetImage getImageForWeatherCondition(
      WeatherCondition condition, DateTime time) {
    AssetImage weatherImage = AssetImage('icons/neon_sunny.png');

    switch (condition) {
      case WeatherCondition.cloudy:
        if (time.hour > 19) {
          weatherImage = AssetImage('icons/neon_night_cloudy.png');
        } else {
          weatherImage = AssetImage('icons/neon_cloudy.png');
        }
        break;
      case WeatherCondition.foggy:
        weatherImage = AssetImage('icons/neon_foggy.png');
        break;
      case WeatherCondition.rainy:
        weatherImage = AssetImage('icons/neon_rainy.png');
        break;
      case WeatherCondition.snowy:
        weatherImage = AssetImage('icons/neon_snow.png');
        break;
      case WeatherCondition.sunny:
        if (time.hour > 19) {
          weatherImage = AssetImage('icons/neon_clear_night.png');
        } else {
          weatherImage = AssetImage('icons/neon_sunny.png');
        }
        break;
      case WeatherCondition.thunderstorm:
        weatherImage = AssetImage('icons/neon_lightning.png');
        break;
      case WeatherCondition.windy:
        weatherImage = AssetImage('icons/neon_windy.png');
        break;
    }

    return weatherImage;
  }

  String getAccessibilityForTempUnit(TemperatureUnit unit) {
    if (unit == TemperatureUnit.fahrenheit) {
      return "degrees fahrenheit";
    } else {
      return "degrees celcius";
    }
  }
}
