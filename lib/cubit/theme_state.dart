part of 'theme_cubit.dart';

@immutable
sealed class ThemeState {}

final class LightTheme extends ThemeState {}

final class DarkTheme extends ThemeState {}

final class ThemeInitial extends ThemeState {}
