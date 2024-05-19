// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lab4_frontend/root_page.dart';
import 'package:lab4_frontend/sign_up_page.dart';
import 'package:lab4_frontend/reset_password_page.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert';
import 'package:lab4_frontend/config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     theme: ThemeData(
  //       primaryColor: const Color(0xFFFF9000),
  //     ),
  //     home: MyHomePage(),
  //   );
  // }

  Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: MaterialColor(
        const Color.fromARGB(255, 6, 161, 146).value,
        const <int, Color>{
          50: Color.fromRGBO(6, 161, 146, 0.1),
          100: Color.fromRGBO(6, 161, 146, 0.2),
          200: Color.fromRGBO(6, 161, 146, 0.3),
          300: Color.fromRGBO(6, 161, 146, 0.4),
          400: Color.fromRGBO(6, 161, 146, 0.5),
          500: Color.fromRGBO(6, 161, 146, 0.6),
          600: Color.fromRGBO(6, 161, 146, 0.7),
          700: Color.fromRGBO(6, 161, 146, 0.8),
          800: Color.fromRGBO(6, 161, 146, 0.9),
          900: Color.fromRGBO(6, 161, 146, 1.0),
        },
      ),
    ),
    home: MyHomePage(),
  );
}
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final usercontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  Future<bool> signIn() async {

      final Map<String, String> data = {
      "UserId": usercontroller.text,
      "Password": passwordcontroller.text
    };

    final response = await http.post(
      Uri.parse('$ip/user/login'), // Replace with your sign-up URL
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // Successful registration
      print("User login successfully M");
      print(response.body);
      print(response.statusCode);
      return true;
    
    } else {
      // Registration failed
      print("User login failed M");
      print(response.body);
      print(response.statusCode);
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Image.asset('images/logo.png', height: 50),
                const SizedBox(height: 20),
                const Text(
                  'Sign-In',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                    controller: usercontroller,
                    decoration: const InputDecoration(
                      labelText: 'UserID',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    }),
                const SizedBox(height: 10),
                TextFormField(
                    controller: passwordcontroller,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      } else if (value.length < 6) {
                        return 'Password length should be more than 6 characters';
                      }
                      return null;
                    }),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background color
                  ),
                  // onPressed: () {
                  //   if (_key.currentState!.validate()) {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (BuildContext context) {
                  //           return const RootPage(
                  //             params: LatLng(1.348876, 103.683095),
                  //             // BY DEFAULT SET TO SHOW VIEW OF NTU
                  //           );
                  //         },
                  //       ),
                  //     );
                  //   }
                  // } 
                  onPressed: 
                  () async {
                      bool signInSuccess = await signIn();

                      if (signInSuccess) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const RootPage(
                                params: LatLng(1.3483, 103.6831),
                                // SET TO SHOW SINGAPORE MAP
                              );
                            },
                          ),
                        );
                      } 
                      else 
                      {
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Login Failed'),
                              content: const Text('Authentication failed. Please check your username and password.'),
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
                  }
                    // SUPPOSED TO DO SOME VERIFICATION CHECKS AND STUFF WITH BACKEND BUT FOR NOW IT JUST LOGINS
                    // TO CALL LOGIN FUNCTIONS FROM BACKEND
                  ,
                  child: const Text('Login', style: TextStyle(fontSize: 20)),
                ),

                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return SignUpPage();
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'Do not have an account? Sign-up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const ResetPasswordPage();
                        },
                      ),
                    );
                  },
                  child: const Text('Forget Password',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
