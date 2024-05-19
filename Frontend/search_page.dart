// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lab4_frontend/locations.dart';
import 'package:lab4_frontend/root_page.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert';
import 'package:lab4_frontend/config.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}
late String locationName;
late dynamic Latitude;
late dynamic Longitude;

class _SearchPageState extends State<SearchPage> {

  Future<bool> nearbyCharging() async { // SUPPOSED TO RETURN LIST BUT PUT TO BOOL FOR NOW

    final Map<String, String> data = {
      "Latitude": Latitude.toString(),
      "newPassword": Longitude.toString()
    };

    final response = await http.post( // Need to change to GET Function
      Uri.parse('$ip/'), // Replace with nearby charging URL
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // Successful registration
      print("User registered successfully M");
      print(response.body);
      print(response.statusCode);
      return true;

    } else {
      // Registration failed
      print("User registration failed M");
      print(response.body);
      print(response.statusCode);
      return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            // method to show the search bar
            showSearch(
              context: context,
              //delegate to customise the search bar
              delegate: CustomSearchDelegate(),
            );
          },
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  // method to show the search bar
                  showSearch(
                      context: context,
                      // delegate to customize the search bar
                      delegate: CustomSearchDelegate());
                },
                icon: const Icon(Icons.search),
              ),
              const Text(
                "Search Locations",
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //Call voice to text recognition method
            },
            icon: const Icon(Icons.mic),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: const Center(
          child: Column(
            children: [
            SizedBox(height: 150),
            Icon(
              Icons.search,
              size: 200,
            ), //magnifying glass
            Divider(
              height: 16, //vertical space occupied by the divider
              // color: Colors.black, // color of the vertical divider
              thickness: 0, //width of the visble line itself
            ),
            // const SizedBox(width: 8),
            Text(
              'You can search for locations here',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            ]
        )
      )
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {

  Future<Map> getLatLng() async { // SUPPOSED TO RETURN LIST BUT PUT TO BOOL FOR NOW

    final response = await http.get( // Need to change to GET Function
      Uri.parse('$ip/charging_location/district_name?district_name=$locationName'), // Replace with getLatLng URL
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
    );

    if (response.statusCode == 200)  
    {
    // Successful GET request
      debugPrint("Location retrieved successfully");

    // Parse the JSON response into a Map
      Map<String, dynamic> locationLatLng = jsonDecode(response.body);

      return locationLatLng;
    } 
    else 
    {
    // Request failed
      debugPrint("Failed to retrieve location details");
      Map<String, dynamic> fail = {"result": "fail"};
      return fail;
    }
  }
  // Sample List to show querying, To be replaced with list of all locations/call backend methods to retrieve list
  List<String> searchTerms = locations;

  // first overwrite to
  // clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  // second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  // third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  // last overwrite to show the
  // querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var location in searchTerms) {
      if (location.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(location);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        // locationName = result;
        // debugPrint(locationName);
        return ListTile(
          onTap: () async {
            locationName = result;
            Map locationLatitudeLongitude = await getLatLng();
            double positionLatitude = locationLatitudeLongitude["latitude"];  // Get from List LatLng
            double postionLongtitude = locationLatitudeLongitude["longitude"]; // Get from List LatLng
            // TO CALL BACKEND METHOD TO GET LATITUDE AND LONGTITUDE OF LOCATION FROM DATABASE
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RootPage(
                  params: LatLng(positionLatitude, postionLongtitude), 
                  // replace with postition_lat and position_long
                  // SETTED IT TO JURONG POINT FOR NOW, TO BE REPLACED WITH ACTUAL LATLNG OF 
                  //LOCATIONS USING THE TWO VARIABLES ABOVE AFTER GETTING DATA FROM BACKEND
                ),
              ),
            );
            Latitude = positionLatitude;
            Longitude = postionLongtitude;
            // List nearbyCharging = await nearbyCharging();
            // include for loop, for each (Lat, Lng) received from method call in the list, 
            // add a marker to it
            // location_Latitude = Lat, location_Longitude = Lng
          },
          title: Text(result),
        );
      },
    );
  }
}
