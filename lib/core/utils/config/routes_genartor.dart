import 'package:flutter/material.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/features/auth/presentation/screens/forgot_password.dart';
import 'package:gradproject/features/auth/presentation/screens/login.dart';
import 'package:gradproject/features/auth/presentation/screens/new_password.dart';
import 'package:gradproject/features/auth/presentation/screens/otp.dart';
import 'package:gradproject/features/auth/presentation/screens/signup.dart';
import 'package:gradproject/features/auth/presentation/screens/test.dart';

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => Login());
      case Routes.signup:
        return MaterialPageRoute(builder: (_) => Signup());
      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPassword());
      case Routes.test:
        return MaterialPageRoute(builder: (_) => TestScreen());
      // case Routes.newPassword:
      //   return MaterialPageRoute(builder: (_) =>  NewPassword(email: '',, token: '',));

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
