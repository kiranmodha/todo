import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do/presentation/home_screen/home.dart';
import 'package:to_do/presentation/welcome_screen/welcome_screen.dart';

class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return buildLoading();
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (snapshot.hasData) {
              return const Home(); // If user is signed in already, show home screen
            } else {
              return const WelcomeScreen(); // If user is not signed in, show sign in screen
            }
          },
        ),
      );

  Widget buildLoading() => const Center(child: CircularProgressIndicator());
}
