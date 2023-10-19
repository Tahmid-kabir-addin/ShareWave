import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/providers/storage_repositoy.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/repository/post_repository.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/utils.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  return PostController(
      postRepository: ref.watch(postRepositoryProvider),
      ref: ref,
      storageRepository: ref.watch(storageRepositoryProvider));
});

final userPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  return ref.watch(postControllerProvider.notifier).getUserPosts(communities);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  final uid = const Uuid();

  PostController(
      {required PostRepository postRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareTextPost(
      {required String title,
      required Community selectedCommunity,
      required BuildContext context,
      required String description}) async {
    final postId = uid.v4();
    final user = _ref.watch(userProvider);
    state = false;
    Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upVotes: [],
        downVotes: [],
        commentCount: 0,
        userName: user!.name,
        uid: user.uid,
        userProfilePic: user.profilePic,
        type: "text",
        createdAt: DateTime.now(),
        awards: [],
        description: description);

    final res = await _postRepository.addPost(post);

    res.fold((l) {
      showSnackBar(context, l.message);
      state = true;
    }, (r) {
      showSnackBar(context, "Posted Successfully");
      Routemaster.of(context).pop();
      state = true;
    });
  }

  void shareLinkPost(
      {required String title,
      required Community selectedCommunity,
      required BuildContext context,
      required String link}) async {
    final postId = uid.v4();
    final user = _ref.watch(userProvider);
    state = false;
    Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upVotes: [],
        downVotes: [],
        commentCount: 0,
        userName: user!.name,
        uid: user.uid,
        userProfilePic: user.profilePic,
        type: "link",
        createdAt: DateTime.now(),
        awards: [],
        link: link);

    final res = await _postRepository.addPost(post);
    res.fold((l) {
      showSnackBar(context, l.message);
      state = true;
    }, (r) {
      showSnackBar(context, "Posted Successfully");
      Routemaster.of(context).pop();
      state = true;
    });
  }

  void shareImagePost(
      {required String title,
      required Community selectedCommunity,
      required BuildContext context,
      required File? imageFile}) async {
    final postId = uid.v4();
    final user = _ref.watch(userProvider);
    state = false;
    final imageRes = await _storageRepository.storeFile(
        path: 'posts/${selectedCommunity.name}/', id: postId, file: imageFile);

    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      Post post = Post(
          id: postId,
          title: title,
          communityName: selectedCommunity.name,
          communityProfilePic: selectedCommunity.avatar,
          upVotes: [],
          downVotes: [],
          commentCount: 0,
          userName: user!.name,
          uid: user.uid,
          userProfilePic: user.profilePic,
          type: "image",
          createdAt: DateTime.now(),
          awards: [],
          image: r);

      final res = await _postRepository.addPost(post);

      res.fold((l) {
        showSnackBar(context, l.message);
        state = true;
      }, (r) {
        showSnackBar(context, "Posted Successfully");
        Routemaster.of(context).pop();
        state = true;

      });
    });
  }

  Stream<List<Post>> getUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {

      return _postRepository.getUserPosts(communities);
    }
    return Stream.value([]);
  }
}
