import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;
  var lat;
  var lon;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  _determinePosition() async {
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

    position = await Geolocator.getCurrentPosition();

    lat = position!.latitude;
    lon = position!.longitude;

    print("latitude $lat longitude $lon");
    fetchWeatherData();
  }

  fetchWeatherData() async {
    String myApiKey = "e5f043662dc24e903eb78c6beb0472e9";
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$myApiKey";
    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$myApiKey";

    var weatherResponce = await http.get(Uri.parse(weatherApi));
    var forecastResponce = await http.get(Uri.parse(forecastApi));
    print("result is ${forecastResponce.body}");
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponce.body));
    });
  }

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: weatherMap == null
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
              body: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(
                        flex: 7,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.1,
                                right: MediaQuery.of(context).size.width * 0.2,
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                color: Color.fromRGBO(34, 51, 94, 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "${Jiffy(DateTime.now()).format("MMM do yy, h:mm a")}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "${weatherMap!["name"]}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        height: 50,
                                        width: 50,
                                        child: Image.network(
                                          weatherMap!["main"]["feels_like"] ==
                                                  "clear sky"
                                              ? "https://windy.app//storage/posts/November2021/02-partly-%20cloudy-weather-symbol-windyapp.jpg"
                                              : weatherMap!["main"]
                                                          ["feels_like"] ==
                                                      "rainy"
                                                  ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ9k7m4NE-r-iF8f_WuSbW09wnlE35SEw0poQWiHdhEMvihYpBddZ3UBZyGtKTfOV8EVqA&usqp=CAU"
                                                  : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ9k7m4NE-r-iF8f_WuSbW09wnlE35SEw0poQWiHdhEMvihYpBddZ3UBZyGtKTfOV8EVqA&usqp=CAU",
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "${weatherMap!["main"]["temp"]}°C",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 35),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 50,),
                            Container(
                              child: Column(
                                children: [
                                  Text(
                                    "${weatherMap!["main"]["feels_like"]}°",
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  Text(
                                    "${weatherMap!["weather"][0]["main"]}",
                                    style: TextStyle(fontSize: 22),
                                  ),

                                  SizedBox(height: 20,),
                                  Text(
                                    "Humidity : ${weatherMap!["main"]["humidity"]} Pressure :${weatherMap!["main"]["pressure"]}",
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  SizedBox(height: 10,),
                                  Text(
                                    "Sunrise ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)).format("h:mm a")}  Sunset ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)).format("h:mm a")}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )),
                    Expanded(
                      flex: 3,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: forecastMap!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color.fromRGBO(34, 51, 94, 1),
                              ),
                              width: 120,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE h:mm")}",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "${forecastMap!["list"][index]["main"]["temp_min"]} / ${forecastMap!["list"][index]["main"]["temp_max"]}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE h:mm")}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "${forecastMap!["list"][index]["weather"][0]["description"]}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
