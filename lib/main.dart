import 'package:check_raspadores/utils/popular_firestore.dart';
import 'package:check_raspadores/views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // 👈 gerado automaticamente
import 'views/usina_list_view.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 👈 agora usando o arquivo gerado
  );
  //await FirestorePopulator().popular();
  runApp(ChecklistApp());
}

class ChecklistApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklist Raspadores',
      theme: ThemeData(primarySwatch: Colors.blue),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: child,
          ),
        );
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return UsinaListView(); // usuário logado
          }
          return LoginView(); // usuário não logado
        },
      ),
    );
  }
}
