import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/models/user_model.dart';

import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_defs.dart';

final userRepositoryProvider = Provider((ref) {
  return UserRepository(fireStore: ref.watch(firestoreProvider));
});

class UserRepository {
  final  _fireStore;

  UserRepository({required FirebaseFirestore fireStore})
      : _fireStore = fireStore;

  CollectionReference get _users =>
      _fireStore.collection(FirebaseConstants.usersCollection);

  FutureVoid editUser(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
