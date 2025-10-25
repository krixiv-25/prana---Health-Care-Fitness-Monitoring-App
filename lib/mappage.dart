import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kenko/logadd.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class FreeMapScreen extends StatefulWidget {
  const FreeMapScreen({super.key});

  @override
  State<FreeMapScreen> createState() => _FreeMapScreenState();
}

class _FreeMapScreenState extends State<FreeMapScreen> {
  LatLng? userLocation;

  final Map<String, Map<String, LatLng>> placesByCategory = {
    'Gym': {
      'Gym 1': LatLng(1.3666805, 103.8410098), //ACTIVE SG
      'Gym 2': LatLng(1.2869829, 103.8144155), //ACTIVE SG
      'Gym 3': LatLng(1.3914286, 103.8731487), //ACTIVE SG
      'Gym 4': LatLng(1.3522078, 103.8721024), //ACTIVE SG
      'Gym 5': LatLng(1.3375519, 103.8448239), //ACTIVE SG
      'Gym 6': LatLng(1.3351491, 103.845178), //ACTIVE SG
      'Gym 7': LatLng(1.3477783, 103.7112244), //ACTIVE SG
      'Gym 8': LatLng(1.3529572, 103.8518961), //ACTIVE SG
      'Gym 9': LatLng(1.3445487, 103.7475654), //ACTIVE SG
      'Gym 10': LatLng(1.4477252, 103.8231771), //ACTIVE SG
      'Gym 11': LatLng(1.3689459, 103.7487832), //ACTIVE SG
      'Gym 12': LatLng(1.390896, 103.7474198), //ACTIVE SG
      'Gym 13': LatLng(1.3117211, 103.7653319), //ACTIVE SG
      'Gym 14': LatLng(1.2893927, 103.8202497), //ACTIVE SG
      'Gym 15': LatLng(1.3269068, 103.9320133), //ACTIVE SG
      'Gym 16': LatLng(1.3108537, 103.859925), //ACTIVE SG
      'Gym 17': LatLng(1.3443255, 103.7301562), //ACTIVE SG
      'Gym 18': LatLng(1.330469, 103.7256213), //ACTIVE SG
      'Gym 19': LatLng(1.338594, 103.694289), //ACTIVE SG
      'Gym 20': LatLng(1.323749, 103.8709003), //ACTIVE SG
      'Gym 21': LatLng(1.3029895, 103.8948755), //ACTIVE SG
      'Gym 22': LatLng(1.3741881, 103.9515336), //ACTIVE SG
      'Gym 23': LatLng(1.3816702, 103.7647336), //ACTIVE SG
      'Gym 24': LatLng(1.3537755, 103.9398986), //ACTIVE SG
      'Gym 25': LatLng(1.3964574, 103.8870983), //ACTIVE SG
      'Gym 26': LatLng(1.4363844, 103.7739886), //ACTIVE SG
      'Gym 27': LatLng(1.3823343, 103.8456976), //ACTIVE SG
      'Gym 28': LatLng(1.4119597, 103.8312149), //ACTIVE SG
    },
    'Women-Only Gym': {
      'WGym 1': LatLng(1.2989008, 103.855176), //AMORE FITNESS
      'WGym 2': LatLng(1.3594916, 103.8852177), //AMORE FITNESS
      'WGym 3': LatLng(1.3784471, 103.7633144), //AMORE FITNESS
      'WGym 4': LatLng(1.2989008, 103.855176), //AMORE FITNESS
      'WGym 5': LatLng(1.28967, 103.85007), //AMORE FITNESS
      'WGym 6': LatLng(1.2994894, 103.8454842), //AMORE FITNESS
      'WGym 7': LatLng(1.28233, 103.84996), //MSFIT 24 HOUR
      'WGym 8': LatLng(1.3229288, 103.9251788), //COUNTOUR EXPRESS
      'WGym 9': LatLng(1.3540772, 103.8708075), //COUNTOUR EXPRESS
      'WGym 10': LatLng(1.3535681, 103.9539929), //COUNTOUR EXPRESS
      'WGym 11': LatLng(1.4269915, 103.8372458), //COUNTOUR EXPRESS
      'WGym 12': LatLng(1.3338599, 103.7400148), //COUNTOUR EXPRESS
      'WGym 13': LatLng(1.3759535, 103.9464677), //COUNTOUR EXPRESS
      'WGym 14': LatLng(1.3531702, 103.9427981), //Active.Co
      'WGym 15': LatLng(1.28967, 103.85007), //Active.co
    },
  };

  String selectedCategory = 'Gym';

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  void _launchDirections(LatLng target) async {
    if (userLocation == null) return;

    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${userLocation!.latitude},${userLocation!.longitude}'
      '&destination=${target.latitude},${target.longitude}'
      '&travelmode=driving',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch directions.')),
      );
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPlaces = placesByCategory[selectedCategory]!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        centerTitle: true,
        title: Text(
          "FIND NEARBY PLACES",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
        ],
      ),
      body:
          userLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      items:
                          placesByCategory.keys
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: userLocation!,
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.kenko',
                          tileProvider: NetworkTileProvider(),
                        ),
                        MarkerLayer(
                          markers: [
                           
                            Marker(
                              point: userLocation!,
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.person_pin_circle,
                                size: 40,
                                color: Colors.blue,
                              ),
                            ),
                            
                            for (var entry in currentPlaces.entries)
                              Marker(
                                point: entry.value,
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () => _launchDirections(entry.value),
                                  child: const Icon(
                                    Icons.place,
                                    size: 40,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Tap on a red marker to get directions',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(24, 2, 12, 1),
        unselectedItemColor: const Color.fromRGBO(149, 144, 168, 1),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 2) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              builder: (context) => LogAdd(),
            );
          } else if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/mental');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            _onItemTapped(index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Mental',
          ),
        ],
      ),
    );
  }
}
