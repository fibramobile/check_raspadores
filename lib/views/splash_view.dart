import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'usina_list_view.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    // ⏳ Aguarda 2 segundos e decide a rota
    Timer(const Duration(seconds: 3), _checkAuth);
  }

  void _checkAuth() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UsinaListView()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white, // Verde Vale
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (coloque em assets/logo.png)
            Image.asset(
              "assets/logo.png",
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              "Checklist Raspadores",
              style: TextStyle(
                color:  Color(0xFF007C6C),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>( Color(0xFF007C6C)),
            ),
          ],
        ),
      ),
    );
  }
}
