import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/enums/enums.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/storage_repositoy.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/repository/post_repository.dart';
import 'package:reddit/features/user/user_controller.dart';
import 'package:reddit/models/comment_model.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';
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
final guestPostsProvider = StreamProvider((ref) {
  return ref.watch(postControllerProvider.notifier).getGuestPosts();
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  return ref.watch(postControllerProvider.notifier).getPostById(postId);
});

final allCommentsByPostIdProvider = StreamProvider.family((ref, String postId) {
  return ref
      .watch(postControllerProvider.notifier)
      .getAllCommentsByPostId(postId);
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
    final user = _ref.watch(userProvider)!;
    _ref
        .watch(userControllerProvider.notifier)
        .updateUserKarma(user, UserKarma.textPost, context);
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
    final user = _ref.watch(userProvider)!;
    _ref
        .watch(userControllerProvider.notifier)
        .updateUserKarma(user, UserKarma.linkPost, context);
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
    final user = _ref.watch(userProvider)!;
    _ref
        .watch(userControllerProvider.notifier)
        .updateUserKarma(user, UserKarma.imagePost, context);
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

  Stream<List<Post>> getGuestPosts() {
    return _postRepository.getGuestPosts();
    return Stream.value([]);
  }

  void deletePost(UserModel user, Post post, BuildContext context) async {
    state = false;
    final res = await _postRepository.deletePost(post);
    state = true;
    res.fold((l) => showSnackBar(context, "Deletion Failed!"), (r) {
      _ref
          .watch(userControllerProvider.notifier)
          .updateUserKarma(user, UserKarma.deletePost, context);
      showSnackBar(context, "Successfully Deleted!");
    });
  }

  void updateVote(
      Post post, BuildContext context, String voteType, String uid) async {
    final Either<Failure, void> res;
    if (voteType == 'upVote') {
      if (post.upVotes.contains(uid)) {
        res = await _postRepository.updateUpVote(post, uid, true);
      } else {
        res = await _postRepository.updateUpVote(post, uid, false);
      }
    } else {
      if (post.downVotes.contains(uid)) {
        res = await _postRepository.updateDownVote(post, uid, true);
      } else {
        res = await _postRepository.updateDownVote(post, uid, false);
      }
    }
    res.fold((l) => showSnackBar(context, 'Voting Failed!'),
        (r) => showSnackBar(context, 'Vote Updated Successfully!'));
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment(
      {required BuildContext context,
      required UserModel user,
      required String text,
      required String postId}) async {
    final commentId = uid.v4();

    final comment = Comment(
        id: commentId,
        text: text,
        postId: postId,
        userName: user.name,
        userProfilePic: user.profilePic,
        createdAt: DateTime.now());

    final res = await _postRepository.addComment(comment);

    res.fold((l) => showSnackBar(context, "Comment Failed!"), (r) {
      _ref
          .watch(userControllerProvider.notifier)
          .updateUserKarma(user, UserKarma.comment, context);
      showSnackBar(context, "Commented Successfylly!");
    });
  }

  Stream<List<Comment>> getAllCommentsByPostId(String postId) {
    final res = _postRepository.getAllCommentsByPostId(postId);
    print("----------%%%%%%%%%----------\n");
    // print(res.first.toString());
    return res;
  }

  void awardPost(
      UserModel user, String award, BuildContext context, Post post) async {
    final res = await _postRepository.awardPost(post, award, user.uid);

    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref
          .watch(userControllerProvider.notifier)
          .updateUserKarma(user, UserKarma.awardPost, context);
      _ref.watch(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }
}
