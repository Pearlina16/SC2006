import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert';
import 'package:lab4_frontend/config.dart';



class SignUpPage extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  SignUpPage({super.key});

  Future<bool> register() async {

      final Map<String, String> data = {
    "newUserId": usernameController.text,
    "newPassword": passwordController.text
  };

    final response = await http.post(
      Uri.parse('$ip/user/register'), // Replace with your backend server URL
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
      body: Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Colors.blueGrey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios_new),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Image.asset('Images/logo.png', height: 100),
                  const SizedBox(height: 20),
                  const Text(
                    'Sign-Up',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'UserID',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom
                    (
                      backgroundColor: Colors.green, // Background color
                    ),
                    onPressed: () async {
                      bool registrationSuccess = await register();
    
                      if (registrationSuccess) {
                        Navigator.of(context).pop();
                       }
                      else
                      {
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Username already taken! Please try again'),
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
                      },
                    child: const Text('Sign-Up', style: TextStyle(fontSize: 20)),
                  ),
                  // const SizedBox(height: 20),
                ],
            ),
          ),
        ),
      ),
    ]
    ),
    );
  }
}