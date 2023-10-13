import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:routemaster/routemaster.dart';

class ProfileIconDrawer extends ConsumerWidget {
  const ProfileIconDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    void logOut() {
      ref.watch(authControllerProvider.notifier).logOut();
    }
    
    void navigateToUserProfile(BuildContext context) {
      Routemaster.of(context).push('/user/${user?.uid}');
    }
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user!.profilePic),
              radius: 70,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "u/${user.name}",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () => navigateToUserProfile(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              title: const Text('Log Out'),
              onTap: () => logOut(),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
