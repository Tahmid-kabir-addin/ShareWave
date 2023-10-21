import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/enums/enums.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/user/repository/user_repository.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../core/providers/storage_repositoy.dart';
import '../../utils.dart';

final userControllerProvider =
    StateNotifierProvider<UserController, bool>((ref) {
  return UserController(
      userRepository: ref.watch(userRepositoryProvider),
      ref: ref,
      storageRepository: ref.watch(storageRepositoryProvider));
});

final userOwnedPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.watch(userControllerProvider.notifier).getUserOwnedPosts(uid);
});

class UserController extends StateNotifier<bool> {
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;

  UserController(
      {required UserRepository userRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _userRepository = userRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void editUser(
      {required UserModel user,
      required File? profileFile,
      required File? bannerFile,
      required BuildContext context,
      required String name}) async {
    state = true;
    // path: community/profile/{name}
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
          path: 'user/profile', id: user.uid, file: profileFile);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => user = user.copyWith(profilePic: r));
    }

    // path: community/banner/{name}
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          path: 'user/banner', id: user.uid, file: bannerFile);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => user = user.copyWith(banner: r));
    }
    if (name.isNotEmpty) user = user.copyWith(name: name);

    final res = await _userRepository.editUser(user);
    state = false;
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Post>> getUserOwnedPosts(String uid) {
    return _userRepository.getUserOwnedPosts(uid);
  }

  void updateUserKarma(UserModel user, UserKarma karma, BuildContext context) async {
    user.copyWith(karma: user.karma + karma.karma);
    final res = await _userRepository.updateUserKarma(user.uid, karma.karma);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => _ref.watch(userProvider.notifier).update((state) => user));
  }
}
