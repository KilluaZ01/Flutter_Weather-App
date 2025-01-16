import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_app/bloc/weather_bloc_bloc.dart';
import 'package:weather_app/cubit/theme_cubit.dart';
import 'package:weather_app/screens/home_screen.dart';
import 'package:weather_app/screens/login.dart';
import 'package:weather_app/theme/theme.dart';
import 'package:weather_app/model/user_model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter()); // Register the User adapter
  await Hive.openBox<User>('userBox'); // Open the userBox

  runApp(BlocProvider(
    create: (context) => ThemeCubit()..loadTheme(),
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) {
        if (state is DarkTheme) {
          return true;
        }
        return false;
      },
      builder: (context, isDarkTheme) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            home: FutureBuilder(
                future: _determinePosition(),
                builder: (context, snap) {
                  if (snap.hasData) {
                    return FutureBuilder(
                      future: _checkLoginStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData && snapshot.data == true) {
                            return BlocProvider<WeatherBlocBloc>(
                              create: (context) => WeatherBlocBloc()
                                ..add(FetchWeather(snap.data as Position)),
                              child: const HomeScreen(),
                            );
                          } else {
                            return const LoginScreen();
                          }
                        } else {
                          return const Scaffold(
                            body: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                    );
                  } else {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                }));
      },
    );
  }

  // Method to determine the current position of the device
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Method to check login status
  Future<bool> _checkLoginStatus() async {
    var box = await Hive.openBox<User>('userBox');
    return box.isNotEmpty; // If the box is not empty, user is logged in
  }
}
