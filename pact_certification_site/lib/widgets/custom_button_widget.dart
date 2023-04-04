import 'package:flutter/material.dart';

enum CustomButtonType { primary, secondary, success, failure }

class CustomButtonWidget extends StatelessWidget {
  final CustomButtonType type;
  final Widget child;
  final VoidCallback onTap;

  CustomButtonWidget({
    required this.type,
    required this.child,
    required this.onTap,
  });

  Color get _backgroundColor {
    switch (type) {
      case CustomButtonType.primary:
        return Color(0xFF2980B9);
      case CustomButtonType.secondary:
        return Colors.transparent;
      case CustomButtonType.success:
        return Color(0xFF19990E);
      case CustomButtonType.failure:
        return Color(0xFFB92929);
    }
  }

  BorderSide get _borderSide {
    switch (type) {
      case CustomButtonType.secondary:
        return BorderSide(width: 4, color: Color(0xFF2980B9));
      default:
        return BorderSide.none;
    }
  }

  TextStyle get _textTheme {
    switch (type) {
      case CustomButtonType.secondary:
        return TextStyle(fontSize: 24, color: Color(0xFF2980B9));
      default:
        return TextStyle(fontSize: 24, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          border: Border.fromBorderSide(_borderSide),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DefaultTextStyle.merge(
          style: _textTheme,
          child: child,
        ),
      ),
    );
  }
}
