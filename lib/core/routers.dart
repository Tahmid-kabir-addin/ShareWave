import 'package:flutter/material.dart';
import 'package:reddit/features/auth/screen/login_screen.dart';
import 'package:reddit/features/community/screens/add_mods_screen.dart';
import 'package:reddit/features/community/screens/community_screen.dart';
import 'package:reddit/features/community/screens/create_community_screen.dart';
import 'package:reddit/features/community/screens/edit_community_screen.dart';
import 'package:reddit/features/community/screens/mod_tools_screen.dart';
import 'package:reddit/features/home/screens/home_screen.dart';
import 'package:reddit/features/user/screens/edit_user_screen.dart';
import 'package:reddit/features/user/screens/user_profile_screens.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) =>
      const MaterialPage(child: CreateCommunityScreen()),
  '/r/:name': (route) =>
      MaterialPage(child: CommunityScreen(name: route.pathParameters['name']!)),
  '/mod-tools/:name': (route) =>
      MaterialPage(child: ModToolsScreen(name: route.pathParameters['name']!)),
  '/edit-community/:name': (route) => MaterialPage(
      child: EditCommunityScreen(name: route.pathParameters['name']!)),
  '/add-mods/:name': (route) =>
      MaterialPage(child: AddModsScreen(name: route.pathParameters['name']!)),
  '/user/:uid': (route) =>
      MaterialPage(child: UserProfileScreen(uid: route.pathParameters['uid']!)),
  '/edit-user/:uid': (route) => MaterialPage(
        child: EditUserScreen(uid: route.pathParameters['uid']!),
      )
});
