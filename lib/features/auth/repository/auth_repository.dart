import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/user_model.dart';

// ref.read(): when you need to read the value only once
final authRepositoryProvider = Provider((ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider)));

class AuthRepository {
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;
  late final GoogleSignIn _googleSignIn;

  AuthRepository(
      {required FirebaseFirestore firestore,
      required FirebaseAuth auth,
      required GoogleSignIn googleSignIn})
      : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  FutureEither<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final googleAuth = (await googleUser?.authentication);

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      UserModel userModel;
      // print(userCredential.user?.email);
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
            name: userCredential.user!.displayName ?? 'No Name',
            profilePic:
                userCredential.user!.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: []);

        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
        // return right(userModel);
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } catch (E) {
      print(E);
      return left(Failure(E.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }
}
