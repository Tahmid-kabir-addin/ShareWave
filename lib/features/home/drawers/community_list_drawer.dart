import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/sign_in_button.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerStatefulWidget {
  const CommunityListDrawer({super.key});

  @override
  ConsumerState createState() => _CommunityListDrawerState();
}

class _CommunityListDrawerState extends ConsumerState<CommunityListDrawer> {
  void navigateToCreateCommunityScreen(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunityPage(BuildContext context, String name) {
    Routemaster.of(context).push('/r/$name');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            isGuest
                ? const SignInButton()
                : ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text(
                      "Create a community",
                    ),
                    onTap: () => navigateToCreateCommunityScreen(context),
                  ),
            if (!isGuest)
              ref.watch(userCommunitiesProvider(user.uid)).when(
                  data: (communities) => Expanded(
                        child: ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text("r/${communities[index].name}"),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(communities[index].avatar),
                              ),
                              onTap: () => navigateToCommunityPage(
                                  context, communities[index].name),
                            );
                          },
                          itemCount: communities.length,
                        ),
                      ),
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader())
          ],
        ),
      ),
    );
  }
}
