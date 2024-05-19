import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert';
import 'package:lab4_frontend/config.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {

  late dynamic filterType;

  Future<Map> getPoints() async { 

    final response = await http.get(
      Uri.parse('$ip/user/points'),
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
    );

    if (response.statusCode == 200) {
      // Successful registration
      debugPrint("Retrieved successfully M");
      Map points = jsonDecode(response.body);
      return points;

    } else {
      // Registration failed
      debugPrint("Retrieval failed M");
      Map<String, dynamic> fail = {"result": {"result":"fail"}};
      return fail;
    }
  }

  Future<String> getTier() async { 

    final response = await http.get(
      Uri.parse('$ip/user/check_tier'),
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
    );

    if (response.statusCode == 200) {
      // Successful registration
      debugPrint("Retrieved successfully M");
      String tier = jsonDecode(response.body);
      return tier;

    } else {
      // Registration failed
      debugPrint("Retrieval failed M");
      return "Failed";
    }
  }

  Future<Map> filterDeals() async { 

    final response = await http.get(
      Uri.parse('$ip/user/filter_deals?filter_type=$filterType'),
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
    );

    if (response.statusCode == 200) {
      // Successful registration
      debugPrint("Retrieved successfully M");
      Map <String, dynamic> Deals = jsonDecode(response.body);
      return Deals;

    } else {
      // Registration failed
      debugPrint("Retrieval failed M");
      return {"Result" : {"result": "Failed"}};
    }
  }

  String? selectedCategory = 'All'; // Initial selected category

  final List<String> categories =  ['All', 'FnB', 'Travel', 'Entertainment', 'Lifestyle', 'Fashion']; // Initialize with 'All'
  bool expand = true;
  int user_points = 0;
  late Color color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: color,
              ),
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(10.0),
              width: double.infinity,
              child: ExpansionTile(
                onExpansionChanged: (expand) async {
                    Map userPoints = await getPoints();
                    user_points = userPoints["points"];
                    String userTier = await getTier();
                    if (userTier == "Gold")
                    {
                      color = Colors.amber.shade600;
                    }
                    if (userTier == "Silver")
                    {
                      color = Colors.grey.shade600;
                    }
                    if (userTier == "Bronze")
                    {
                      color = Colors.brown.shade400;
                    }
                    if (userTier == "None")
                    {
                      color = Colors.white;
                    }
                    // To figure out where to change tier
                    setState(() {});
                },
                title: const Row(
                  children: [
                    Text(
                      'Rewards ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                      ),
                    ),
                    Icon(Icons.star, color: Colors.yellow),
                  ],
                ),

                children: [
                  ListTile(
                    title: Text(
                      "$user_points Points",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
            buildSearchBox(),
            const SizedBox(height: 10), // Add some spacing
            buildCategoryDropdown(), // Add category dropdown
            buildRewardsList(),
          ],
        ), 
      ), 
    );
  }

  Widget buildSearchBox() {
    double height = 48;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(height / 2)),
      child: Container(
        height: height,
        padding: EdgeInsets.only(left: height / 2, right: height / 2 - 12),
        child: TextFormField(
          autofocus: false,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.only(top: 16, bottom: 14),
            hintText: "What do you wish for?",
            suffix: Icon(Icons.search),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
List<Widget> reward = [];

  Widget buildCategoryDropdown() {
    return DropdownButton<String>(
      value: selectedCategory,
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? value) async {
        if (value != null) {
          reward.clear();
          selectedCategory = value;
            filterType = selectedCategory;
            debugPrint(filterType);
            Map deals = await filterDeals();
            deals.forEach((key, value) {
              reward.add(
                RewardItem(title: value["description"].toString(), points: int.parse(value["cost"].toString()), category: value["type"].toString(), dealID: int.parse(key),),
              );
            },
            );
            setState(() {
              
            });
        }
      },
    );
  }

  Widget buildRewardsList() { 
    List<Widget> rewards = List.from(reward);
    setState(() {
    });
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: rewards,
    );
  }
}

// class RewardItem extends StatelessWidget {
//   final String title;
//   final int points;
//   final int dealID;

//   late int idDeal;
//   late Map<String, dynamic> data = {
//     "dealID": idDeal,
//   };

//   Future<bool> redeemDeals() async { 

//     final response = await http.post( 
//       Uri.parse('$ip/user/redeem_deals'), 
//       headers: {
//       "Content-Type": "application/json", // Set the content type to JSON
//       },
//       body: jsonEncode(idDeal),// To Check and Fill in with DealID variable
//     );

//     if (response.statusCode == 200) {
//       // Successful registration
//       debugPrint("Redeemed successfully M");
//       return true;

//     } else {
//       // Registration failed
//       debugPrint("Redeem failed M");
//       return false;
//     }
//   }

//   RewardItem({required this.title, required this.points, required String category, required this.dealID});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
//       child: ListTile(
//         title: Text(title),
//         subtitle: Text("Points: $points"),
//         trailing: ElevatedButton(
//           onPressed: () async {
//             idDeal = dealID;
//             debugPrint(idDeal.toString());
//             bool redeemSuccess = await redeemDeals();

//             if (redeemSuccess)
//             {
//               // DO something
//             }
//             else
//             {
//               // DO something
//             }
//             // Add your redemption logic here
//             print("Redeem: $title");
//           },
//           child: Text('Redeem'),
//         ),
//       ),
//     );
//   }
// }

class RewardItem extends StatefulWidget {
  final String title;
  final int points;
  final int dealID;

  const RewardItem({super.key, required this.title, required this.points, required String category, required this.dealID});

  @override
  _RewardItemState createState() => _RewardItemState();
}

class _RewardItemState extends State<RewardItem> {
  late int idDeal;
  late Map<String, int> data = {
    "dealId": idDeal
   };
  String buttonLabel = 'redeem';

  Future<bool> redeemDeals() async {
    final response = await http.post(
      Uri.parse('$ip/user/redeem_deals'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      debugPrint("Redeemed successfully M");
      setState(() {
        buttonLabel = 'Redeemed'; // Update buttonLabel when redemption is successful
      });
      return true;
    } else {
      debugPrint("Redeem failed M");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: ListTile(
        title: Text(widget.title),
        subtitle: Text("Points: ${widget.points}"),
        trailing: ElevatedButton(
          onPressed: () async {
            idDeal = widget.dealID;
            debugPrint(idDeal.toString());
            bool redeemSuccess = await redeemDeals();
            if (redeemSuccess) {
              // ignore: use_build_context_synchronously
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Redeemed Success'),
                    content: const Text('You have successfully redeemed the reward'),
                    actions: [
                      ElevatedButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              // ignore: use_build_context_synchronously
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Redeem Failed'),
                    content: const Text('You are unable to redeem this reward'),
                    actions: [
                      ElevatedButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
            print("Redeem: ${widget.title}");
          },
          child: Text(buttonLabel),
        ),
      ),
    );
  }
}
