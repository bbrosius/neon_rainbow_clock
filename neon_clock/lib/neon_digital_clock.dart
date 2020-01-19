// Copyright 2020 Ben Brosius. Adapted from code by the Chromium team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:neon_rainbow_clock/weather.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A neon digital clock that animates through the colors of the rainbow.
class NeonDigitalClock extends StatefulWidget {
  const NeonDigitalClock(this.model);

  final ClockModel model;

  @override
  _NeonDigitalClockState createState() => _NeonDigitalClockState();
}

class _NeonDigitalClockState extends State<NeonDigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  AssetImage _weatherImage = AssetImage('icons/neon_sunny.png');
  int _colorIndex = -1;
  Color _baseColor;
  Color _glowColor;
  final Duration _colorAnimationDuration = Duration(seconds: 55);

  List<Color> _rainbowColors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.indigoAccent,
    Colors.purpleAccent
  ];

  List<Color> _rainbowGlow = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple
  ];

  @override
  void initState() {
    super.initState();

    _baseColor = _rainbowColors[0];
    _glowColor = _rainbowGlow[0];

    _updateTextStyles();
    widget.model.addListener(_updateModel);

    _updateTime();
    _updateModel();
  }

  void _updateTextStyles() {}

  @override
  void didUpdateWidget(NeonDigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _weatherImage = Weather().getImageForWeatherCondition(
          widget.model.weatherCondition, _dateTime);
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();

      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _timerElapsed,
      );
    });
  }

  void _timerElapsed() {
    _colorIndex++;
    if (_colorIndex > 6) {
      _colorIndex = 0;
    }

    _baseColor = _rainbowColors[_colorIndex];
    _glowColor = _rainbowGlow[_colorIndex];

    _updateTime();
  }

  @override
  Widget build(BuildContext context) {
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final ampm =
        widget.model.is24HourFormat ? "" : DateFormat('a').format(_dateTime);

    final double ampmPadding = 50;
    final CrossAxisAlignment ampmAlignment =
        (ampm == "AM") ? CrossAxisAlignment.start : CrossAxisAlignment.end;

    final date = DateFormat('EEE, MMM d').format(_dateTime);

    TextStyle neonClockTextStyle = TextStyle(
      fontFamily: 'kalam',
      fontSize: 148.0,
      fontWeight: FontWeight.w300,
      color: _baseColor,
      shadows: [
        BoxShadow(
            color: _glowColor.withAlpha(150),
            offset: Offset(4.0, 4.0),
            blurRadius: 15.0),
        BoxShadow(
          color: _glowColor.withAlpha(200),
          offset: Offset(2.0, 2.0),
          blurRadius: 10.0,
        ),
        BoxShadow(
          color: _glowColor.withAlpha(150),
          blurRadius: 15.0,
          offset: Offset(-4.0, -4.0),
        ),
        BoxShadow(
          color: _glowColor.withAlpha(200),
          offset: Offset(-2.0, -2.0),
          blurRadius: 10.0,
        ),
      ],
    );

    TextStyle neonTextStyle = neonClockTextStyle.copyWith(fontSize: 48.0);

    return Container(
        color: Colors.black,
        child: FittedBox(
          fit: BoxFit.fill,
          child: Column(
            children: <Widget>[
              AnimatedDefaultTextStyle(
                duration: _colorAnimationDuration,
                style: neonClockTextStyle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: ampmAlignment,
                  children: <Widget>[
                    Text(hour),
                    Text(":"),
                    Text(minute),
                    Padding(
                      padding: EdgeInsets.only(
                          top: ampmPadding, bottom: ampmPadding),
                      child: AnimatedDefaultTextStyle(
                        duration: _colorAnimationDuration,
                        style: neonTextStyle,
                        child: Text(ampm),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: AnimatedDefaultTextStyle(
                  duration: _colorAnimationDuration,
                  style: neonTextStyle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Image(
                              image: _weatherImage,
                              semanticLabel:
                                  enumToString(widget.model.weatherCondition),
                              width: 64,
                              height: 64,
                            ),
                          ),
                          Text(
                            widget.model.temperatureString,
                            semanticsLabel: Weather()
                                .getAccessibilityForTempUnit(widget.model.unit),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 50,
                        height: 64,
                      ),
                      Text(
                        date,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
