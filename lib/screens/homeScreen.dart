import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Page"),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_currentPosition != null)
                Text(
                    'LAT: ${_currentPosition
                        ?.latitude}, LONG: ${_currentPosition?.longitude} '),
              if(_currentAddress != null)
                Text(_currentAddress!),
              TextButton(
                child: const Text('Get Location'),
                onPressed: () {
                  determinePosition();
                },
              )
            ],
          )),
    );
  }

  //Determine whether location service is enabled an if so request for permission
  Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    //Test if location service is serviceEnabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //TODO: add a notification to alert the user to enable location serviceEnabled
      return Future.error('Location services is not enabled');
    }

    //Check for permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission == await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }
    return await _getCurrentLocation();
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  //Turn coodinates into human readable text
  _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
         _currentPosition!.latitude,
          _currentPosition!.longitude
      );
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch(e){
      print(e);
    }
  }

}
