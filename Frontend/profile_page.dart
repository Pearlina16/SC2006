import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  // Future<void> _showPrivacyPolicy(BuildContext context) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: true, // Clicking outside the dialog will close it
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Privacy Policy'),
  //         content: const SingleChildScrollView(
  //           child: Text(
  //             // Include your complete Privacy Policy text here
  //             "We are strongly committed to letting you know how we will collect and use your personal information.  The policies below are applicable to data and information collected when you use WattWay; however accessed and/or used, that are operated by us, made available by us, or produced and maintained by us and our related companies (collectively “ PowerOn  ” or “we”, “us”, or “our”).  We have established this privacy policy (“Privacy Policy”) to let you know the kinds of personal information we may gather during your use of this App, why we gather your information, what we use your personal information for, when we might disclose your personal information, and how you can manage your personal information. Please be advised that the practices described in this Privacy Policy apply to information gathered online through our App, through our websites and otherwise by our customer service personnel.  It does not apply to information that you may submit to organisations to which we may link or who may link to us or information that we may receive about you from other organisations. By using our App, you are accepting the practices described in our Privacy Policy.  If you do not agree to the terms of this Privacy Policy, please do not use the App.  We reserve the right to modify or amend the terms of our Privacy Policy from time to time without notice. Your continued use of our App following the posting of changes to these terms will mean you accept those changes.  If we intend to apply the modifications or amendments to this Privacy Policy retroactively or to personal information already in our possession, we will provide you with notice of the modifications or amendments. If you have any questions about this Privacy Policy or don’t see your concerns addressed here, you should contact us by email at contact@wattway.com",
  //             style: TextStyle(fontSize: 16),
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              color: const Color.fromRGBO(6, 161, 146, 1.0),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage("images/adrianspfp.png"), // Set the profile photo
                  ),
                  SizedBox(height: 10.0, width: 400),
                  Text(
                    'Adrian', // Set the user's name
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color:  Color.fromARGB(250, 116, 182, 175),
              ),
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(10.0),
              width: double.infinity,
              child: const ExpansionTile(
                collapsedBackgroundColor: Color.fromARGB(250, 116, 182, 175),
                backgroundColor: Color.fromARGB(250, 116, 182, 175),
                title: Text(
                  'General Settings',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  
                ),
                children: [
                  ListTile(
                    title: Text(
                      "Change Username",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Change Password",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color.fromARGB(250, 116, 182, 175),
              ),
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(10.0),
              width: double.infinity,
              child: ExpansionTile(
                collapsedBackgroundColor: Color.fromARGB(250, 116, 182, 175),
                backgroundColor: const Color.fromARGB(250, 116, 182, 175),
                title: const Text(
                  'History',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                children: [
                  TextButton(
                    onPressed: () {
                      viewRedeemedDeals();
                    },
                    child: const ListTile(
                      title: Text(
                        "Deals Redeemed",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // just for show
                    },
                    child: const ListTile(
                      title: Text(
                        "History for Newly Discovered Locations",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // just for show
                    },
                    child: const ListTile(
                      title: Text(
                        "History for Damaged or Incorrect Reports",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color.fromARGB(250, 116, 182, 175),
              ),
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(10.0),
              width: double.infinity,
              child: const ExpansionTile(
                collapsedBackgroundColor:Color.fromARGB(250, 116, 182, 175),
                backgroundColor: Color.fromARGB(250, 116, 182, 175),
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                children: [
                  ListTile(
                    title: Text(
                      "We are strongly committed to letting you know how we will collect and use your personal information.  The policies below are applicable to data and information collected when you use WattWay; however accessed and/or used, that are operated by us, made available by us, or produced and maintained by us and our related companies (collectively “ PowerOn  ” or “we”, “us”, or “our”).  We have established this privacy policy (“Privacy Policy”) to let you know the kinds of personal information we may gather during your use of this App, why we gather your information, what we use your personal information for, when we might disclose your personal information, and how you can manage your personal information. Please be advised that the practices described in this Privacy Policy apply to information gathered online through our App, through our websites and otherwise by our customer service personnel.  It does not apply to information that you may submit to organisations to which we may link or who may link to us or information that we may receive about you from other organisations. By using our App, you are accepting the practices described in our Privacy Policy.  If you do not agree to the terms of this Privacy Policy, please do not use the App.  We reserve the right to modify or amend the terms of our Privacy Policy from time to time without notice. Your continued use of our App following the posting of changes to these terms will mean you accept those changes.  If we intend to apply the modifications or amendments to this Privacy Policy retroactively or to personal information already in our possession, we will provide you with notice of the modifications or amendments. If you have any questions about this Privacy Policy or don’t see your concerns addressed here, you should contact us by email at contact@wattway.com",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color.fromARGB(250, 116, 182, 175),
              ),
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(10.0),
              width: double.infinity,
              child: const ExpansionTile(
                collapsedBackgroundColor: Color.fromARGB(250, 116, 182, 175),
                backgroundColor: Color.fromARGB(250, 116, 182, 175),
                title: Text(
                  'About Us',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                children: [
                  ListTile(
                    title: Text(
                      "Running out of battery? Find your nearest charging port using WattWay--Your favourite charging port sharing app.  From now on you can locate charging ports easily and navigate your way there before your phone runs out of battery! Download the WattWay app, and follow the 4 simple steps: *Discover in the app all your nearby stations, it’s the perfect moment to discover your city. *Choose the type of charging ports you need. *Charge your device on the go and enjoy your day! *If you found any new charging ports, do submit a discover new port report to earn points and redeem voucher! If the port is damaged, do also submit a damaged report. By using the WattWay app, you support our goal! Our goal is to simplify the process of finding and using charging stations, foster a sense of community around this shared need, and reward users for their participation in improving the charging port network. Any more questions about WattWay? Contact us by email at contact@wattway.com",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color.fromARGB(250, 116, 182, 175),
              ),
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(10.0),
              width: double.infinity,
              child: const ExpansionTile(
                collapsedBackgroundColor: Color.fromARGB(250, 116, 182, 175),
                backgroundColor: Color.fromARGB(250, 116, 182, 175),
                title: Text(
                  'Help',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                children: [
                  ListTile(
                    title: Text(
                      "General FAQs",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color.fromARGB(250, 116, 182, 175),
              ),
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(10.0),
              width: double.infinity,
              child: ExpansionTile(
                collapsedBackgroundColor: Color.fromRGBO(142, 207, 200, 0.992),
                backgroundColor: Color.fromRGBO(142, 207, 200, 0.992),
                title: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Log Out", // Button text
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
  
  void viewRedeemedDeals() {}
}
