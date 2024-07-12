import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:game_app/firebase_options.dart';
import 'package:game_app/models/gameModel.dart';
import 'package:game_app/screens/GlobalRankScreen.dart';
import 'package:game_app/screens/LandingScreen.dart';
import 'package:game_app/screens/gameScreen.dart';
import 'package:go_router/go_router.dart';
import 'package:game_app/screens/LoginScreen.dart';
import 'package:game_app/screens/RegistrationScreen.dart';
import 'package:game_app/screens/homeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialLocation =
        FirebaseAuth.instance.currentUser != null ? '/landing' : '/login';

    final GoRouter _router = GoRouter(
      initialLocation: '${initialLocation}',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginPage(),
        ),
        GoRoute(
          path: '/global',
          builder: (context, state) => GlobalRankScreen(),
        ),
        GoRoute(
          path: '/landing',
          builder: (context, state) => Landingscreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => RegistrationScreen(),
        ),
        GoRoute(
          path: '/gameScreen',
          builder: (context, state) => GameScreen(
              game: state.extra as Game, requestSender: state.extra as String),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
