import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';

import '../../../models/community_model.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;

  const AddModsScreen({super.key, required this.name});

  @override
  ConsumerState<AddModsScreen> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};
  bool firstRun = true;

  void addUid(String uid) {
    uids.add(uid);
  }

  void removeUid(String uid) {
    uids.remove(uid);
  }

  void save(BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .addModsToCommunity(context, widget.name, List.of(uids));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () => save(context), icon: const Icon(Icons.done),),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) {
            final members = community.members;
            if (firstRun) {
              for (var user in community.mods) {
                uids.add(user);
              }
            }
            firstRun = false;
            return ListView.builder(
              itemCount: community.members.length,
              itemBuilder: (context, index) {
                return ref.watch(getUserDataProvider(members[index])).when(
                      data: (user) {
                        return CheckboxListTile(
                          value: uids.contains(user.uid),
                          onChanged: (val) {
                            if (val!) {
                              addUid(user.uid);
                            } else {
                              removeUid(user.uid);
                            }
                          },
                          title: Text(user.name),
                        );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader(),
                    );
              },
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}
