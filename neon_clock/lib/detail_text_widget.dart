import 'package:flutter/material.dart';

class DetailTextWidget extends StatelessWidget {
  const DetailTextWidget(
      {Key key,
      @required this.defaultStyle,
      @required this.detailFontSize,
      @required Duration colorAnimationDuration,
      @required this.text,
      this.accessibilityText})
      : _colorAnimationDuration = colorAnimationDuration,
        super(key: key);

  final TextStyle defaultStyle;
  final double detailFontSize;
  final Duration _colorAnimationDuration;
  final String text;
  final String accessibilityText;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      style: defaultStyle.copyWith(fontSize: detailFontSize),
      duration: _colorAnimationDuration,
      curve: Curves.easeIn,
      child: Text(
        text,
        semanticsLabel: (accessibilityText != null) ? accessibilityText : text,
      ),
    );
  }
}
