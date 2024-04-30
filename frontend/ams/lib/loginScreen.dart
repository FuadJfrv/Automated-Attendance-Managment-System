import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'models/inputField.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  // bool participantLoggedIn = false;
  // bool supervisorLoggedIn = false;

  // void logInUser(String email, String password) async {
  //
  //   final response = await http.post(
  //       Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/login/$email/$password"),
  //       headers: {
  //         "Content-Type": "application/x-www-form-urlencoded",
  //       },
  //   );
  //
  //   String cookies = '';
  //
  //   if (response.statusCode != 302) return;
  //
  //   if (response.headers['set-cookie'] != null) {
  //     cookies = response.headers['set-cookie']!;
  //   }
  //
  //   if (response.headers.containsKey("location")) {
  //     final Uri originalUri = Uri.parse(response.headers["location"]!);
  //     final Uri uriWithQueryParams = originalUri.replace(queryParameters: {
  //       'email': email,
  //     });
  //
  //     final getResponse = await http.get( uriWithQueryParams,
  //         headers: { 'Cookie' : cookies, } );
  //     log(getResponse.body);
  //
  //     // if (getResponse.body == "PARTICIPANT") {
  //     //   setState(() {
  //     //     participantLoggedIn = true;
  //     //   });
  //     // }
  //     // else {
  //     //   setState(() {
  //     //     supervisorLoggedIn = true;
  //     //   });
  //     // }
  //   }
  // }

  void logInUser(String email, String password) async {
    final response = await http.get(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/login/$email/$password"),
      );

    if (response.body == "SUPERVISOR") {
      return context.go("/supervisor/$email");
    }
    else if (response.body == "PARTICIPANT") {
      return context.go("/participant/$email");
    }
    print(response.body);
  }


  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text("Log In", style: TextStyle(fontSize: 40),),

              const SizedBox(height: 20,),

              InputField(controller: emailController, hintText: "Email",),

              const SizedBox(height: 5,),

              InputField(controller: passwordController, hintText: "Password",
                isPassword: true,),

              const SizedBox(height: 30,),

              ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(150, 50)),
                  onPressed: () {
                    logInUser(emailController.text, passwordController.text);
                    // if (participantLoggedIn) {
                    //   return context.go("/participant");
                    // }
                    // else if (supervisorLoggedIn) {
                    //   return context.go("/supervisor");
                    // }
                    // else {
                    //   logInUser(emailController.text, passwordController.text);
                    // }
                  },
                  child: const Text("Log in")),

              const SizedBox(height: 5,),

              ElevatedButton(
                  onPressed: () {
                    return context.go('/register');
                  },
                  child: const Text("Create an account")),

            ],
          ),
        ),
      ),
    );
  }
}

