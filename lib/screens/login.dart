import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:weather_app/bloc/weather_bloc_bloc.dart';
import 'package:weather_app/model/user_model.dart';
import 'package:weather_app/screens/home_screen.dart';
import 'package:weather_app/screens/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _login(); // Call the login function without passing the context
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              child: const Text('Already have an account?'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    var box = await Hive.openBox<User>('userBox');
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (box.containsKey(username)) {
      User user = box.get(username)!;
      if (user.password == password) {
        // Login successful
        // After successful login, fetch the position and provide the weather
        _determinePosition().then((position) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return FutureBuilder<Position>(
                  future: _determinePosition(),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      // Provide the WeatherBloc to the HomeScreen with the position
                      return BlocProvider<WeatherBlocBloc>(
                        create: (context) => WeatherBlocBloc()
                          ..add(FetchWeather(
                              snap.data!)), // Send position to fetch weather
                        child: const HomeScreen(),
                      );
                    } else {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        });
      } else {
        // Invalid password
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid password')),
        );
      }
    } else {
      // Username not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username not found')),
      );
    }
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
