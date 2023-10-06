import 'package:flutter/material.dart';
import 'package:reddit/features/auth/screen/login_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoutes = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});
