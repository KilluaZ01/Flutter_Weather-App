import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/bloc/weather_bloc_bloc.dart';
import 'package:weather_app/cubit/theme_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget getWeatherIcon(int code) {
    switch (code) {
      case >= 200 && < 300:
        return Image.asset('assets/1.png');
      case >= 300 && < 400:
        return Image.asset('assets/2.png');
      case >= 500 && < 600:
        return Image.asset('assets/3.png');
      case >= 600 && < 700:
        return Image.asset('assets/4.png');
      case >= 700 && < 800:
        return Image.asset('assets/5.png');
      case == 800:
        return Image.asset('assets/6.png');
      case > 800 && <= 804:
        return Image.asset('assets/7.png');
      default:
        return Image.asset('assets/7.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Define dynamic colors for the theme
    final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
    final appBarColor = Colors.transparent;
    final primaryTextColor = isDarkTheme ? Colors.white : Colors.black;
    final secondaryTextColor =
        isDarkTheme ? Colors.grey[400]! : Colors.grey[800]!;
    final accentColor =
        isDarkTheme ? const Color(0xFFFFAB40) : const Color(0xFF673AB7);
    final circleColor1 =
        isDarkTheme ? const Color(0xFF424242) : const Color(0xFFFFC107);
    final circleColor2 =
        isDarkTheme ? const Color(0xFF616161) : const Color(0xFFFF5722);
    final dividerColor = isDarkTheme ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          size.width * 0.1, // 10% of the width
          1.2 * kToolbarHeight,
          size.width * 0.1,
          size.height * 0.02,
        ),
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // Background Circles
              Align(
                alignment: const AlignmentDirectional(3, -0.3),
                child: Container(
                  height: size.width * 0.8,
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor1,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-3, -0.3),
                child: Container(
                  height: size.width * 0.8,
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor2,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -1.2),
                child: Container(
                  height: size.width * 0.4,
                  width: size.width,
                  decoration: BoxDecoration(color: accentColor),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),
              BlocBuilder<WeatherBlocBloc, WeatherBlocState>(
                builder: (context, state) {
                  if (state is WeatherBlocSuccess) {
                    return SizedBox(
                      width: size.width,
                      height: size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: secondaryTextColor,
                                    size: size.width * 0.05,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${state.weather.areaName}',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontWeight: FontWeight.w300,
                                      fontSize: size.width * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<ThemeCubit>().toggleTheme();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(size.width * 0.04),
                                  shape: const CircleBorder(),
                                  backgroundColor: accentColor,
                                ),
                                child: Icon(
                                  isDarkTheme
                                      ? Icons.nights_stay
                                      : Icons.wb_sunny,
                                  color: Colors.white,
                                  size: size.width * 0.06,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Good Morning',
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: size.width * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Weather Icon
                          Center(
                            child: getWeatherIcon(
                                state.weather.weatherConditionCode!),
                          ),
                          // Temperature
                          Center(
                            child: Text(
                              '${state.weather.temperature!.celsius!.round()}°C',
                              style: TextStyle(
                                color: primaryTextColor,
                                fontSize: size.width * 0.12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Weather Description
                          Center(
                            child: Text(
                              state.weather.weatherMain!.toUpperCase(),
                              style: TextStyle(
                                color: primaryTextColor,
                                fontSize: size.width * 0.06,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Center(
                            child: Text(
                              DateFormat('EEEE dd •')
                                  .add_jm()
                                  .format(state.weather.date!),
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Sunrise and Sunset Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoItem(
                                'Sunrise',
                                DateFormat()
                                    .add_jm()
                                    .format(state.weather.sunrise!),
                                'assets/11.png',
                                size,
                                primaryTextColor,
                                secondaryTextColor,
                              ),
                              _buildInfoItem(
                                'Sunset',
                                DateFormat()
                                    .add_jm()
                                    .format(state.weather.sunset!),
                                'assets/12.png',
                                size,
                                primaryTextColor,
                                secondaryTextColor,
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: Divider(
                              color: dividerColor,
                            ),
                          ),
                          // Temp Max and Min
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoItem(
                                'Temp Max',
                                '${state.weather.tempMax!.celsius!.round()} °C',
                                'assets/13.png',
                                size,
                                primaryTextColor,
                                secondaryTextColor,
                              ),
                              _buildInfoItem(
                                'Temp Min',
                                '${state.weather.tempMin!.celsius!.round()} °C',
                                'assets/14.png',
                                size,
                                primaryTextColor,
                                secondaryTextColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'Loading...',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: size.width * 0.05,
                        ),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    String iconPath,
    Size size,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          scale: size.width * 0.015,
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: secondaryTextColor,
                fontWeight: FontWeight.w300,
                fontSize: size.width * 0.04,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: primaryTextColor,
                fontWeight: FontWeight.w700,
                fontSize: size.width * 0.045,
              ),
            ),
          ],
        )
      ],
    );
  }
}
