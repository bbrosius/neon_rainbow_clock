// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/weather.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'detail_text_widget.dart';

/// A basic digital clock.
///
/// You can do better than this!
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
  final Duration _colorAnimationDuration = Duration(seconds: 10);

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
    widget.model.addListener(_updateModel);

    _baseColor = _rainbowColors[0];
    _glowColor = _rainbowGlow[0];
    _updateTime();
    _updateModel();
  }

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

      _colorIndex++;
      if (_colorIndex > 6) {
        _colorIndex = 0;
      }

      _baseColor = _rainbowColors[_colorIndex];
      _glowColor = _rainbowGlow[_colorIndex];

      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final ampm =
        widget.model.is24HourFormat ? "" : DateFormat('a').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 4;
    final detailFontSize = MediaQuery.of(context).size.width / 12;
    final double ampmPadding = fontSize / 3.0;
    final CrossAxisAlignment ampmAlignment =
        (ampm == "AM") ? CrossAxisAlignment.start : CrossAxisAlignment.end;

    final date = DateFormat('EEE, MMM d').format(_dateTime);
    final neonTextStyle = GoogleFonts.kalam(
      textStyle: TextStyle(
          fontSize: fontSize,
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
          ]),
    );

    return Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            AnimatedDefaultTextStyle(
              duration: _colorAnimationDuration,
              curve: Curves.easeIn,
              style: neonTextStyle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: ampmAlignment,
                children: <Widget>[
                  Text(hour),
                  Text(":"),
                  Text(minute),
                  Padding(
                    padding:
                        EdgeInsets.only(top: ampmPadding, bottom: ampmPadding),
                    child: DetailTextWidget(
                        defaultStyle: neonTextStyle,
                        detailFontSize: detailFontSize,
                        colorAnimationDuration: _colorAnimationDuration,
                        text: ampm),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image(
                        image: _weatherImage,
                        semanticLabel:
                            enumToString(widget.model.weatherCondition),
                        width: 64,
                        height: 64,
                      ),
                      DetailTextWidget(
                        defaultStyle: neonTextStyle,
                        detailFontSize: detailFontSize,
                        colorAnimationDuration: _colorAnimationDuration,
                        text: widget.model.temperatureString,
                        accessibilityText: Weather()
                            .getAccessibilityForTempUnit(widget.model.unit),
                      ),
                    ],
                  ),
                  DetailTextWidget(
                      defaultStyle: neonTextStyle,
                      detailFontSize: detailFontSize,
                      colorAnimationDuration: _colorAnimationDuration,
                      text: date),
                ],
              ),
            )
          ],
        ));
  }
}
