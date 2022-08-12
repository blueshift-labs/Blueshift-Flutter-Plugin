import 'package:flutter/material.dart';
import '../utils/routes.dart';
import 'package:blueshift_plugin/blueshift.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? emailId = "";
  String? username = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Blueshift.trackScreenView("LoginScreen", {}, false);
    getUserInfo();
  }

  void getUserInfo() async {
    try {
      emailId = await Blueshift.getUserInfoEmailId;
      username = await Blueshift.getUserInfoFirstName;
      if (emailId != null && emailId != "") {
        Navigator.pushNamed(context, MyRoutes.homeRoute);
      }
    } catch (err) {
      print('Caught error: $err');
    }
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 200,
          ),
          Text("Welcome $username",
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Enter user email id",
                    label: Text("Email id"),
                  ),
                  onChanged: (value) {
                    emailId = value;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Enter user name",
                    label: Text("User name"),
                  ),
                  onChanged: (value) {
                    username = value;
                    setState(() {});
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      loginButtonClicked(context);
                    },
                    child: const Text("Login"),
                    style:
                        TextButton.styleFrom(minimumSize: const Size(200, 40))),
              ],
            ),
          )
        ],
      ),
    ));
  }

  void loginButtonClicked(context) {
    if (emailId != "" && emailId != null) {
      Blueshift.setUserInfoEmailId(emailId!);
      Blueshift.setUserInfoFirstName(username!);

      Blueshift.identifyWithDetails({
        "AppType": "flutter",
        "value": "test flutter",
        "intVal": 24,
        "doubleVal": 2.3,
        "boolVal": true
      });
      Navigator.pushNamed(context, MyRoutes.homeRoute);
    }
  }
}
