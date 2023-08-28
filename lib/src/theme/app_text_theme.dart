import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final class AppTextTheme extends LocalizationsDelegate<AppTextTheme> {
  const AppTextTheme._();

  static const AppTextTheme delegate = AppTextTheme._();

  static late TextTheme _textTheme;

  TextTheme get textTheme => _textTheme;

  static TextStyle get displayLarge => _textTheme.displayLarge!;

  static TextStyle get displayMedium => _textTheme.displayMedium!;

  static TextStyle get displaySmall => _textTheme.displaySmall!;

  static TextStyle get headlineLarge => _textTheme.headlineLarge!;

  static TextStyle get headlineMedium => _textTheme.headlineMedium!;

  static TextStyle get headlineSmall => _textTheme.headlineSmall!;

  static TextStyle get titleLarge => _textTheme.titleLarge!;

  static TextStyle get titleMedium => _textTheme.titleMedium!;

  static TextStyle get titleSmall => _textTheme.titleSmall!;

  static TextStyle get bodyLarge => _textTheme.bodyLarge!;

  static TextStyle get bodyMedium => _textTheme.bodyMedium!;

  static TextStyle get bodySmall => _textTheme.bodySmall!;

  static TextStyle get labelLarge => _textTheme.labelLarge!;

  static TextStyle get labelMedium => _textTheme.labelMedium!;

  static TextStyle get labelSmall => _textTheme.labelSmall!;

  // todo: add button styles
  static TextStyle get buttonLarge => _textTheme.labelSmall!;

  static TextStyle get buttonMedium => _textTheme.labelSmall!;

  static late TextTheme Function(Locale locale) onLocalChange;

  static TextTheme of(BuildContext context) {
    return Localizations.of<AppTextTheme>(context, AppTextTheme)!.textTheme;
  }

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppTextTheme> load(Locale locale) {
    _textTheme = onLocalChange(locale);
    return SynchronousFuture(this);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppTextTheme> old) => false;
}
