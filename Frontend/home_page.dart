// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert';
import 'package:lab4_frontend/config.dart';

late dynamic markerid;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.data});

  final LatLng data;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  late dynamic Latitude;
  late dynamic Longitude;
  late dynamic location_Latitude;
  late dynamic location_Longitude;
  final PanelController _panelController = PanelController();
  String markerDescription = "This is the marker description";
  
  get onTap => null;
  late dynamic locationLatitude;
  late dynamic locationLongitude;

  Map locations_details = 
  {
    "location_id": 0,
    "district": "",
    "latitude": 0,
    "longitude": 0,
    "capacity_charging_ports": 0,
    "have_cable": 0,
    "status": 0,
    "upvotes": 0,
    "downvotes": 0,
    "description": "",
    "Micro-USB": 0,
    "Lightning": 0,
    "USB-C cable": 0,
    "USB-C port": 0,
    "USB port": 0,
    "Lockable": 0
  };

  Future<Map<String, dynamic>> nearbyCharging() async { 

    final response = await http.get( 
      Uri.parse('$ip/charging_location/nearby?latitude=$locationLatitude&longitude=$locationLongitude'), 
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
    );

    if (response.statusCode == 200) {
      // Successful registration
      debugPrint("Retrieved successfully M");
      Map<String, dynamic> nearbylocations = jsonDecode(response.body);
      return nearbylocations;

    } else {
      // Registration failed
      debugPrint("Retrieval failed M");
      Map<String, dynamic> fail = {"result": {"result":"fail"}};
      return fail;
    }
  }

  Future<Map<String, dynamic>>currentNearbyCharging() async { 

    final response = await http.get(
      Uri.parse('$ip/charging_location/nearby?latitude=$Latitude&longitude=$Longitude'),
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
    );

    if (response.statusCode == 200) {
      // Successful
      debugPrint("Retrieved successfully M");
      Map<String, dynamic> nearbylocations = jsonDecode(response.body);
      return nearbylocations;

    } else {
      // Failed
      debugPrint("Retrieval failed M");
      Map<String, dynamic> fail = {"result": {"result":"fail"}};
      return fail;
    }
  }

  Future<Map> locationDetails() async { // SUPPOSED TO RETURN LIST BUT PUT TO BOOL FOR NOW

    final response = await http.get( // Need to change to GET Function
      Uri.parse('$ip/charging_location/details?locationID=$markerid'), // Replace with charging location URL
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
    );

    if (response.statusCode == 200) {
      // Successful registration
      debugPrint("Got Details successfully M");
      Map<String, dynamic> locationsDetails = jsonDecode(response.body);
      return locationsDetails;

    } else {
      // Registration failed
      debugPrint("Failed M");
      Map<String, dynamic> fail = {"result": {"result":"fail"}};
      return fail;
    }
  }

// can only limit to 1 vote
// voting only show if status is pending, otherwise dont show


  late GoogleMapController _controller;

  // static const CameraPosition _ntu = CameraPosition(
  //   target: LatLng(1.3483, 103.6831),
  //   zoom: 14.4746,
  // );

  // static final Marker _Library = Marker(
  //   markerId: const MarkerId("_Library"),
  //   infoWindow: const InfoWindow(title: 'Library'),
  //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //   position: const LatLng(1.3478295748869, 103.68083769212),
  // );

  Set<Marker> currentmarkers = {};
  late int iupvote = 0;
  late int idownvote = 0;

  @override
  Widget build(BuildContext context) {
    
    const BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

    final data = widget.data;
    locationLatitude = data.latitude;
    locationLongitude = data.longitude;
    // var borderRadius;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(target: LatLng(locationLatitude, locationLongitude), zoom: 14),
          onMapCreated: (GoogleMapController controller) async {
            _controller = controller;
            currentmarkers.add(
                Marker(
                  markerId: const MarkerId("Current"),
                  infoWindow: const InfoWindow(title: 'Current'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
                  position: LatLng(locationLatitude, locationLongitude),
                ),
              );
            if (locationLatitude != 1.3521){
              Map nearbycharging =  await nearbyCharging();
              
              nearbycharging.forEach((key, value) {
              if (value["status"] == 0)
              {
                currentmarkers.add(
                Marker(
                  markerId: MarkerId(key),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange),
                  position: LatLng(double.parse(value["latitude"].toString()), double.parse(value["longitude"].toString())),
                  onTap: () async {
                    markerid = int.parse(key);
                    Map location_details = await locationDetails();
                    locations_details = location_details;
                    setState(() {});
                    debugPrint(markerid.toString());
                    _panelController.open(); 
                  },
                ),
              );  
              }
              else
              {
                currentmarkers.add(
                  Marker(
                    markerId: MarkerId(key),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                    position: LatLng(double.parse(value["latitude"].toString()), double.parse(value["longitude"].toString())),
                    onTap: () async {
                      markerid = int.parse(key);
                      Map location_details = await locationDetails();
                      locations_details = location_details;
                      setState(() {});
                      debugPrint(markerid.toString());
                      _panelController.open(); 
                    },
                  ),
                ); 
              } 
            },
          );
          }
          setState(() {});
          },

          markers: currentmarkers,
          onTap: (LatLng position) {
              // Handle map tap here
              // Close the panel when the map is tapped
              _panelController.close();
          },
          ),
          
          SlidingUpPanel(
            // panel: Center(
            //   child: Text(markerDescription), // Display the marker description here
            // ),
             controller: _panelController,
              minHeight: 100, // Set the minimum height of the sliding panel
              maxHeight: 400, // Set the maximum height of the sliding panel
              borderRadius: radius,
              panelBuilder: (ScrollController sc) {
              return Column(
              children: [
                Container(
                  height:80,
                  width: 420,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(6, 161, 146, 1.0), // Customize the background color of the header
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        //  Text(" SCSE ", style: GoogleFonts.oswald(Colors.black, fontSize: 30, fontWeight: FontWeight.bold), ),
                        //  Text("Description", style: TextStyle(color: Colors.black, fontSize: 20,), ),
                        Text(
                          "Nanyang Technological University",
                          style: GoogleFonts.oswald(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  )
                ),
                 Expanded(
                  child: SingleChildScrollView(
                    controller: sc,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                        children: <Widget>[
                        DescriptionBox(title: "Description", content: locations_details["description"].toString()),
                        InfoBox(title: "Location ID", content: locations_details["location_id"].toString()),
                        InfoBox(title: "Capacity", content: locations_details["capacity_charging_ports"].toString()),
                        InfoBox(title: "Cable Type Available", content: 
                          ((locations_details["Micro-USB"] == 0) ? "" : "Micro USB ") + 
                          ((locations_details["Lightning"] == 0) ? "" : "Lightning ") +
                          ((locations_details["USB-C cable"] == 0) ? "" : "USB-C cable ") +
                          ((locations_details["USB-C port"] == 0) ? "" : "USB-C port ") +
                          ((locations_details["USB port"] == 0) ? "" : "USB port ")
                          ) ,
                        InfoBox(title: "Lockable or Unlockable", content: (locations_details["Lockable"] == 1) ? "Has lock provided" : "No lock provided"),
                        InfoBox(title: "Status", content: (locations_details["status"] == 0) ? "Pending" : "Confirmed" ),
                        VotesWithActions(
                        title: "Votes", status: (locations_details["status"] == 0) ? "Pending" : "Confirmed", 
                        initialUpvotes: locations_details["upvotes"], 
                        initialDownvotes: locations_details["downvotes"],
                        ),
                        ElevatedButton(
                            onPressed: () {
                              // if (widget.status == "Confirmed") {
                                showDamageReportPopUp(context);
                              // }
                            },
                            child: const Text("Damage Report"),
                        ),
                        
                      ],
                    )
                  ),
                ),
              ],
            );
          },
        
          
  // If you want to set a different background color for the main content, you can use the `body` property
  // body: Container(
  //   color: Colors.black, // Customize the background color of the main content
  //   child: Center(
  //     child: Text("This is the main content of the sliding panel"), // Main content goes here
  //   ),
  // ),
          ),
      ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position position = await _currentLocation();
          
          Latitude = position.latitude;
          Longitude = position.longitude;

          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(Latitude,Longitude),
                zoom: 14,
              ),
            ),
          );
          currentmarkers.add(
                Marker(
                  markerId: const MarkerId("Current"),
                  infoWindow: const InfoWindow(title: 'Current'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
                  position: LatLng(Latitude, Longitude),
                ),
              );

          Map nearbycharginglocation = await currentNearbyCharging();
          nearbycharginglocation.forEach((key, value) {
            if (value["status"] == 0)
            {
              currentmarkers.add(
              Marker(
                markerId: MarkerId(key),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange),
                position: LatLng(double.parse(value["latitude"].toString()), double.parse(value["longitude"].toString())),
                onTap: () async {
                  markerid = int.parse(key);
                  Map location_details = await locationDetails();
                  locations_details = location_details;
                  setState(() {});
                  debugPrint(markerid.toString());
                  _panelController.open(); 
                },
              ),
            );  
          }
          else
          {
            currentmarkers.add(
              Marker(
                markerId: MarkerId(key),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
                position: LatLng(double.parse(value["latitude"].toString()), double.parse(value["longitude"].toString())),
                onTap: () async {
                  markerid = int.parse(key);
                  Map location_details = await locationDetails();
                  locations_details = location_details;
                  setState(() {});
                  debugPrint(markerid.toString());
                  _panelController.open(); 
                  
                  // Open the sliding panel
                },
            ),
          );
          // List nearbyCharging = await nearbyCharging();
          // include for loop, for each (Lat, Lng) received from method call in the list, 
          // add a marker to it
          // location_Latitude = Lat, location_Longitude = Lng
          setState(() {});
        }
        },
        );
        },
        label: const Text(''),
        icon: const Icon(Icons.location_on),
      ),
      
    );
  }

  Future<Position> _currentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location Services are not disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location Permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are denied permanatly");
    }

    Position position = Position(
        longitude: 103.6814,
        latitude: 1.3461,
        timestamp: DateTime(2023, 10, 20, 11),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0);

    return position;

    // final GoogleMapController controller = await _controller.future;
    // await controller.animateCamera(CameraUpdate.newCameraPosition(_tampines));
  }

}

class InfoBox extends StatelessWidget {
  final String title;
  final String content;

  const InfoBox({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Match the same height as the green box
      width: 420,
      margin:  const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color:const Color.fromRGBO(142, 207, 200, 0.992), // Change the background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Change the text color
                ),
              ),
            ),
            Padding(
              padding: 
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
              child: Text(
                content,
                style: const TextStyle(
                  color: Colors.black, // Change the text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DescriptionBox extends StatelessWidget {
  final String title;
  final String content;

  const DescriptionBox({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Match the same height as the green box
      width: 420,
      margin:  const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color: const Color.fromARGB(255, 148, 200, 246), // Change the background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Change the text color
                ),
              ),
            ),
            Padding(
              padding: 
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
              child: Text(
                content,
                style: const TextStyle(
                  color: Colors.black, // Change the text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

dynamic votes;
late Map<String, int> vote = {
    "LocationID": markerid,
    "vote": votes
  };

class VotesWithActions extends StatefulWidget {
  final String title;
  final int initialUpvotes;
  final int initialDownvotes; // Add the initial downvotes count
  final String status;

  const VotesWithActions({
    Key? key,
    required this.title,
    required this.initialUpvotes,
    required this.initialDownvotes, // Add the initial downvotes count to the constructor
    required this.status,
  }) : super(key: key);

  @override
  _VotesWithActionsState createState() => _VotesWithActionsState();
}

class _VotesWithActionsState extends State<VotesWithActions> {
  late int upvotesCount;
  late int downvotesCount; // Maintain upvote and downvote counts as state
  bool hasUpvoted = false;
  bool hasDownvoted = false;

  Future<bool> Vote() async { 

    final response = await http.post(
      Uri.parse('$ip/charging_location/vote'), 
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
      body: jsonEncode(vote)
    );

    if (response.statusCode == 200) {
      // Successful registration
      debugPrint("Voted successfully M");
      return true;

    } else {
      // Registration failed
      debugPrint("Failed M");
      return false;
    }
  }

  void handleUpvote() {
    setState(() {
      if (hasUpvoted) {
        upvotesCount--;
      } else {
        upvotesCount++;
        if (hasDownvoted) {
          downvotesCount--;
          hasDownvoted = false;
        }
      }
      hasUpvoted = !hasUpvoted;
    });
  }

  void handleDownvote() {
    setState(() {
      if (hasDownvoted) {
        downvotesCount--;
      } else {
        downvotesCount++;
        if (hasUpvoted) {
          upvotesCount--;
          hasUpvoted = false;
        }
      }
      hasDownvoted = !hasDownvoted;
    });
  }

  @override
  void initState() {
    super.initState();
    upvotesCount = widget.initialUpvotes;
    downvotesCount = widget.initialDownvotes; // Initialize upvote and downvote counts
  }
  // Color.fromARGB(255, 148, 200, 246),

  @override
  Widget build(BuildContext context) {
    if (widget.status == "Pending") {
      return Container(
        height: 150,
        width: 420,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: const Color.fromARGB(255, 148, 200, 246),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Votes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
               Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color: hasUpvoted ? Colors.green : Colors.black,
                      ),
                      onPressed: hasUpvoted ? null : handleUpvote,
                      // () async {
                      //   setState(() {
                      //     votes = 1;
                      //   }); 
                      //   bool voteSuccess = await Vote();
                      //   if (voteSuccess)
                      //   {
                      //     // hasUpvoted ? null : handleUpvote;
                      //     // ignore: use_build_context_synchronously
                      //     showDialog(
                      //       context: context,
                      //       builder: (BuildContext context) {
                      //         return AlertDialog(
                      //           title: const Text('Thank you!'),
                      //           content: const Column(
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: <Widget>[
                      //               Icon(
                      //                 Icons.check_circle, // Tick icon
                      //                 color: Colors.green, // Icon color
                      //                 size: 48, // Icon size
                      //               ),
                      //               Text('Your Have Successfully Voted.'),
                      //             ],
                      //           ),
                      //           actions: <Widget>[
                      //             TextButton(
                      //               onPressed: () {
                      //                 // Handle showing the damage report or navigating to the report page.
                      //                 // You can add navigation logic here.
                      //                 Navigator.of(context).pop();
                      //               },
                      //               child: const Text('OK'),
                      //             ),
                      //           ],
                      //         );
                      //       },
                      //     );
                      //     setState(() {
                      //       hasUpvoted ? null : handleUpvote;
                      //     });
                      //   }
                      //   else
                      //   {
                      //     // ignore: use_build_context_synchronously
                      //     showDialog(
                      //       context: context,
                      //       builder: (BuildContext context) {
                      //         return AlertDialog(
                      //           title: const Text("Error"),
                      //           content: const Text("There seems to be an error, please try again"),
                      //           actions: <Widget>[
                      //             TextButton(
                      //               child: const Text("OK"),
                      //               onPressed: () {
                      //                 Navigator.of(context).pop(); // Close the dialog
                      //               },
                      //             ),
                      //           ],
                      //         );
                      //       },
                      //     );
                      //   }
                      // }
                    ),
                    Text(
                      upvotesCount.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.thumb_down,
                        color: hasDownvoted ? Colors.red : Colors.black,
                      ),
                      onPressed: hasDownvoted ? null : handleDownvote,
                      // () async {
                      //   setState(() {
                      //     votes = 0;
                      //   });
                      //   bool votingSuccess = await Vote();
                      //   if (votingSuccess)
                      //   {
                      //     // hasDownvoted ? null : handleDownvote;
                      //     // ignore: use_build_context_synchronously
                      //     showDialog(
                      //       context: context,
                      //       builder: (BuildContext context) {
                      //         return AlertDialog(
                      //           title: const Text('Thank you!'),
                      //           content: const Column(
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: <Widget>[
                      //               Icon(
                      //                 Icons.check_circle, // Tick icon
                      //                 color: Colors.green, // Icon color
                      //                 size: 48, // Icon size
                      //               ),
                      //               Text('Your Have Successfully Voted.'),
                      //             ],
                      //           ),
                      //           actions: <Widget>[
                      //             TextButton(
                      //               onPressed: () {
                      //                 // Handle showing the damage report or navigating to the report page.
                      //                 // You can add navigation logic here.
                      //                 Navigator.of(context).pop();
                      //               },
                      //               child: const Text('OK'),
                      //             ),
                      //           ],
                      //         );
                      //       },
                      //     );
                      //     setState(() {
                      //       hasDownvoted ? null : handleDownvote;
                      //     });
                      //   }
                      //   else
                      //   {
                      //     // ignore: use_build_context_synchronously
                      //     showDialog(
                      //       context: context,
                      //       builder: (BuildContext context) {
                      //         return AlertDialog(
                      //           title: const Text("Error"),
                      //           content: const Text("There seems to be an error, please try again"),
                      //           actions: <Widget>[
                      //             TextButton(
                      //               child: const Text("OK"),
                      //               onPressed: () {
                      //                 Navigator.of(context).pop(); // Close the dialog
                      //               },
                      //             ),
                      //           ],
                      //         );
                      //       },
                      //     );
                      //   }
                      
                      // },
                    ),
                    Text(
                      downvotesCount.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

void showDamageReportPopUp(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Damage Report'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('This marker has a damage report. Would you like to see the report?'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Handle showing the damage report or navigating to the report page.
              // You can add navigation logic here.
              Navigator.of(context).pop();
              displayReport(context);
            },
            child: const Text('Show Report'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog.
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}

void displayReport(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Report'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('There are 2 ports damaged leaving only 8 available.'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Close the dialog.
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
