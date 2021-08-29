import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';


final _flexColorTheme = FlexColorScheme.dark(scheme: FlexScheme.indigo).toTheme;
const _outLineBorder = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(10),
      bottomLeft: Radius.circular(10),
    ));
ThemeData darkTheme = _flexColorTheme.copyWith(
    inputDecorationTheme: _flexColorTheme.inputDecorationTheme.copyWith(
        border: _outLineBorder,
        enabledBorder: _outLineBorder,
        focusedBorder: _outLineBorder,
        disabledBorder: _outLineBorder,
        errorBorder: _outLineBorder,
        focusedErrorBorder: _outLineBorder));
