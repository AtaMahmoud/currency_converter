import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './src/services/dependency_assembler.dart';

void main() {
  setupDependencyAssembler();
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.title,
      themeMode: ThemeMode.system,
      darkTheme: FlexColorScheme.dark(scheme: FlexScheme.indigo).toTheme,
      theme: FlexColorScheme.light(scheme: FlexScheme.indigo).toTheme,
      home: Container(),
    );
  }
}
