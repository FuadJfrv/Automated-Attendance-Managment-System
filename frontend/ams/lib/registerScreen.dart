import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'participant/participant.dart';
import 'models/inputField.dart';

Future<AppUser> registerUser(AppUser user) async {
  final response = await http.post(
      Uri.parse("http://Sdp2-env.eba-cyewupda.eu-north-1.elasticbeanstalk.com:80/api/v1/registration"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        "firstName": user.firstName,
        "lastName" : user.lastName,
        "password": user.password,
        "email" : user.email,
        "appUserRole" : user.appUserRole
      })
  );
  if (response.statusCode == 201) {
    return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to register.');
  }
}


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
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

              const Text("Register", style: TextStyle(fontSize: 40),),

              InputField(controller: nameController, hintText: "First name",),

              const SizedBox(height: 5,),

              InputField(controller: lastNameController, hintText: "Last name",),

              const SizedBox(height: 5,),

              InputField(controller: emailController, hintText: "Email",),

              const SizedBox(height: 5,),

              InputField(controller: passwordController, hintText: "Password",
              isPassword: true,),

              const SizedBox(height: 5,),

              ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(150, 60)),
                  onPressed: () {
                    AppUser user = AppUser(
                        firstName: nameController.text,
                        lastName: lastNameController.text,
                        password: passwordController.text,
                        email: emailController.text,
                        appUserRole: "SUPERVISOR"
                    );
                    register(user);
                  },
                  child: const Text("Register")),

              const SizedBox(height: 15,),

              ElevatedButton(
                  onPressed: () {
                    return context.go('/');
                  },
                  child: const Text("I already have an account"))
            ],
          ),
        ),
      ),
    );
  }

  void register(AppUser user) {
    registerUser(user);
  }
}

