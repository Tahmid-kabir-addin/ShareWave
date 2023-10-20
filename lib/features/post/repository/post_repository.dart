import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(firestore: ref.watch(firestoreProvider));
});

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPosts(List<Community> communities) {
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateUpVote(Post post, String uid, bool doesExist) async {
    try {
      if (!doesExist) {
        if (post.downVotes.contains(uid)) updateDownVote(post, uid, true);
        return right(_posts.doc(post.id).update({
          'upVotes': FieldValue.arrayUnion([uid])
        }));
      }
      return right(_posts.doc(post.id).update({
        'upVotes': FieldValue.arrayRemove([uid])
      }));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateDownVote(Post post, String uid, bool doesExist) async {
    try {
      if (!doesExist) {
        if (post.upVotes.contains(uid)) updateUpVote(post, uid, true);
        return right(_posts.doc(post.id).update({
          'downVotes': FieldValue.arrayUnion([uid])
        }));
      }
      return right(_posts.doc(post.id).update({
        'downVotes': FieldValue.arrayRemove([uid])
      }));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
