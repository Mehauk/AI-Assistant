import 'package:flutter/material.dart';

enum MeTextStyle { body, headlineSmall }

extension on MeTextStyle {
  TextStyle? getStyle(BuildContext context) {
    switch (this) {
      case MeTextStyle.body:
        return Theme.of(context).textTheme.bodyMedium;

      case MeTextStyle.headlineSmall:
        return Theme.of(context).textTheme.headlineSmall;
    }
  }
}

class MeText extends StatelessWidget {
  final MeTextStyle style;
  final String text;
  const MeText(this.text, {super.key, this.style = MeTextStyle.body});

  factory MeText.headlineSmall(String text) {
    return MeText(text, style: MeTextStyle.headlineSmall);
  }

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style.getStyle(context));
  }
}
