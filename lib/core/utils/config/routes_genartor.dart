import 'package:flutter/material.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/features/auth/presentation/screens/login.dart';
import 'package:gradproject/features/auth/presentation/screens/signup.dart';

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => Login());
      case Routes.signup:
        return MaterialPageRoute(builder: (_) => const Signup());

      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('No Route Found'),
        ),
        body: const Center(child: Text('No Route Found')),
      ),
    );
  }
}
