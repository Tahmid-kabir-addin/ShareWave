import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/Theme/pallete.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/home/delegates/search_community_delegates.dart';
import 'package:reddit/features/home/drawers/community_list_drawer.dart';
import 'package:reddit/features/home/drawers/profile_icon_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChange(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => displayDrawer(context),
          );
        }),
        actions: [
          IconButton(
            onPressed: () => showSearch(
                context: context, delegate: SearchCommunityDelegates(ref: ref)),
            icon: const Icon(Icons.search),
          ),
          Builder(builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user!.profilePic),
              ),
              onPressed: () => isGuest ? null : displayEndDrawer(context),
            );
          }),
        ],
        title: const Text(
          "Home",
          style: TextStyle(
            color: Pallete.whiteColor,
          ),
        ),
      ),
      body: Constants.tabWidgets[_page],
      drawer: const CommunityListDrawer(),
      endDrawer: const ProfileIconDrawer(),
      bottomNavigationBar: isGuest
          ? null
          : CupertinoTabBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                ),
              ],
              onTap: onPageChange,
              currentIndex: _page,
              activeColor: Colors.white,
              backgroundColor: Pallete.darkModeAppTheme.backgroundColor,
            ),
    );
  }
}
