// Model creation always in controller class
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/providers/storage_repositoy.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/repository/community_repository.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';
import 'package:reddit/utils.dart';
import 'package:routemaster/routemaster.dart';

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

final userCommunitiesProvider = StreamProvider.family((ref, String userId) {
  return ref.watch(communityControllerProvider.notifier).getUserCommunities(userId);
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});
final communityPostsProvider =
    StreamProvider.family((ref, String communityName) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityPosts(communityName);
});
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  return CommunityController(
      communityRepository: ref.watch(communityRepositoryProvider),
      ref: ref,
      storageRepository: ref.watch(storageRepositoryProvider));
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;

  CommunityController(
      {required CommunityRepository communityRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.watch(userProvider)?.uid ?? '';

    Community community = Community(
        id: name,
        name: name,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        members: [uid],
        mods: [uid]);

    final res = await _communityRepository.createCommunity(community);

    res.fold((l) {
      showSnackBar(context, l.message);
      state = false;
    }, (r) {
      Routemaster.of(context).pop();
      showSnackBar(context, "Community Created Successfully");
      state = false;
    });
  }

  void joinCommunity(BuildContext context, Community community) async {
    final uid = _ref.watch(userProvider)?.uid;
    if (!community.members.contains(uid)) {
      print("${community.name} ${uid!}");
      final res = await _communityRepository.joinCommunity(community.name, uid);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => showSnackBar(context, 'Community Joined Successfully!'));
    } else {
      final res =
          await _communityRepository.leaveCommunity(community.name, uid!);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => showSnackBar(context, "Community Left Successfully!"));
    }
  }

  Stream<List<Community>> getUserCommunities(String userId) {
    // state = true;
    final communities = _communityRepository.getUserCommunities(userId);
    // state = false;
    return communities;
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void editCommunity(
      {required Community community,
      required File? profileFile,
      required File? bannerFile,
      required BuildContext context}) async {
    state = true;
    // path: community/profile/{name}
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
          path: 'community/profile', id: community.name, file: profileFile);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => community = community.copyWith(avatar: r));
    }

    // path: community/banner/{name}
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          path: 'community/banner', id: community.name, file: bannerFile);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => community = community.copyWith(banner: r));
    }
    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  void addModsToCommunity(
      BuildContext context, String communityName, List<String> uids) async {
    final res =
        await _communityRepository.addModsToCommunity(communityName, uids);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Post>> getCommunityPosts(String communityName) {
    return _communityRepository.getCommunityPosts(communityName);
  }
}
