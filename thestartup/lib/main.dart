import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {

  return runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({ Key? key }) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
} 
class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        
      ),
      home: const HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "";

  Future<void> _register() async {
    http.Response response = await http.post(
      Uri.parse("https://thestartup.herokuapp.com/api/register_user"),
      body: {
        "name": name
      }
    );

    // ignore: avoid_print
    print(response.body);
  }

  Future<void> _update() async {
    try{
      Position geolocator = await _getPosition();

      Map location = {
        "lat": geolocator.latitude,
        "lon": geolocator.longitude
      };
      
      http.Response response = await http.post(
        Uri.parse("https://thestartup.herokuapp.com/api//api/update_location"),
        body: {
          "name": name,
          "location": location
        }
      );

      // ignore: avoid_print
      print(response.body);
    }catch(err){
      // ignore: avoid_print
      print(err);
    }
    
  }
  
  Future<Position> _getPosition() async {
    
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

  @override
  void initState() {
    super.initState();

    Random random = Random();
    int randomNumber = random.nextInt(100);
    name = "new_user$randomNumber";

    _register();
    _update();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: (){_update();},
        child: Container(
          height: 50,
          width: 250,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: const BorderRadius.all(Radius.circular(10))
          ),
          child: const Text("Refresh"),
        ),
      ),
    );
  }
}