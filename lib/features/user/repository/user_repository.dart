import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_defs.dart';

final userRepositoryProvider = Provider((ref) {
  return UserRepository(fireStore: ref.watch(firestoreProvider));
});

class UserRepository {
  final FirebaseFirestore _fireStore;

  UserRepository({required FirebaseFirestore fireStore})
      : _fireStore = fireStore;

  CollectionReference get _users =>
      _fireStore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _posts =>
      _fireStore.collection(FirebaseConstants.postsCollection);

  FutureVoid editUser(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserOwnedPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(e.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }
}
