import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial());

  Future<void> loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final isDarkTheme = prefs.getBool("theme") ?? false;
    emit(isDarkTheme ? DarkTheme() : LightTheme());
  }

  Future<void> toggleTheme() async {
    final isCurrentlyDark = state is DarkTheme;
    final newTheme = isCurrentlyDark ? LightTheme() : DarkTheme();
    emit(newTheme);

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool("theme", !isCurrentlyDark);
  }
}
