import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppFontWeight {
  regular(FontWeight.w400),
  medium(FontWeight.w500),
  semibold(FontWeight.w600),
  bold(FontWeight.w700);

  final FontWeight weight;

  const AppFontWeight(this.weight);
}

final class AppFontFamily {
  final String regular;

  final String medium;

  final String semibold;

  final String bold;

  final List<String> fallback;

  const AppFontFamily(this.regular, this.medium, this.semibold, this.bold, this.fallback);

  String adjustWithFontWeight(AppFontWeight fontWeight) => switch (fontWeight) {
        AppFontWeight.regular => regular,
        AppFontWeight.medium => medium,
        AppFontWeight.semibold => semibold,
        AppFontWeight.bold => bold
      };
}

final class AppTextStyle {
  const AppTextStyle(this._textStyle);

  final TextStyle _textStyle;

  TextStyle dynamicColor(
    BuildContext context, {
    CupertinoDynamicColor? color,
    AppFontWeight? appFontWeight,
    double? fontSize,
  }) {
    Localizations.of<AppTextTheme>(context, AppTextTheme)!;
    final color_ = (color ?? _textStyle.color) as CupertinoDynamicColor;
    return _textStyle.copyWith(
      color: color_.resolveFrom(context),
      fontWeight: appFontWeight?.weight,
      fontSize: fontSize,
    );
  }

  TextStyle staticColor(
    BuildContext context, {
    Color? color,
    AppFontWeight? appFontWeight,
    double? fontSize,
  }) {
    Localizations.of<AppTextTheme>(context, AppTextTheme)!;
    return _textStyle.copyWith(
      color: color,
      fontWeight: appFontWeight?.weight,
      fontSize: fontSize,
    );
  }

  AppTextStyle copyWith({
    bool? inherit,
    Color? backgroundColor,
    double? fontSize,
    AppFontWeight? appFontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    TextLeadingDistribution? leadingDistribution,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    List<FontVariation>? fontVariations,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? debugLabel,
    AppFontFamily? appFontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
  }) {
    return AppTextStyle(_textStyle.copyWith(
      inherit: inherit,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: appFontWeight?.weight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      leadingDistribution: leadingDistribution,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      fontVariations: fontVariations,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      debugLabel: debugLabel,
      fontFamily: (appFontWeight != null) ? appFontFamily?.adjustWithFontWeight(appFontWeight) : null,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    ));
  }

  TextStyle get read => _textStyle;
}

final class AppTextTheme {
  const AppTextTheme._();

  static const delegate = AppTextThemeLocaleDelegate();

  static AppTextStyle get displayLarge => AppTextStyle(_textTheme.displayLarge!);

  static AppTextStyle get displayMedium => AppTextStyle(_textTheme.displayMedium!);

  static AppTextStyle get displaySmall => AppTextStyle(_textTheme.displaySmall!);

  static AppTextStyle get headlineLarge => AppTextStyle(_textTheme.headlineLarge!);

  static AppTextStyle get headlineMedium => AppTextStyle(_textTheme.headlineMedium!);

  static AppTextStyle get headlineSmall => AppTextStyle(_textTheme.headlineSmall!);

  static AppTextStyle get titleLarge => AppTextStyle(_textTheme.titleLarge!);

  static AppTextStyle get titleMedium => AppTextStyle(_textTheme.titleMedium!);

  static AppTextStyle get titleSmall => AppTextStyle(_textTheme.titleSmall!);

  static AppTextStyle get bodyLarge => AppTextStyle(_textTheme.bodyLarge!);

  static AppTextStyle get bodyMedium => AppTextStyle(_textTheme.bodyMedium!);

  static AppTextStyle get bodySmall => AppTextStyle(_textTheme.bodySmall!);

  static AppTextStyle get labelLarge => AppTextStyle(_textTheme.labelLarge!);

  static AppTextStyle get labelMedium => AppTextStyle(_textTheme.labelMedium!);

  static AppTextStyle get labelSmall => AppTextStyle(_textTheme.labelSmall!);

  static late TextTheme _textTheme;

  ///　watch locale
  static AppTextTheme of(BuildContext context) {
    final tf = Localizations.of<AppTextTheme>(context, AppTextTheme)!;
    return tf;
  }

  static late TextTheme Function(Locale locale) onLocaleChange;
}

extension AppTextThemeBuildContextExtension on BuildContext {
  AppTextTheme get textTheme => AppTextTheme.of(this);
}

final class AppTextThemeLocaleDelegate extends LocalizationsDelegate<AppTextTheme> {
  const AppTextThemeLocaleDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppTextTheme> load(Locale locale) {
    AppTextTheme._textTheme = AppTextTheme.onLocaleChange(locale);
    return SynchronousFuture(const AppTextTheme._());
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppTextTheme> old) => false;
}
