import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/community_model.dart';

// Define a provider for the CommunityRepository.
final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(fireStore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _fireStore;

  CommunityRepository({required FirebaseFirestore fireStore})
      : _fireStore = fireStore;

  // Reference to the 'communities' collection in Firestore.
  CollectionReference get _communities =>
      _fireStore.collection(FirebaseConstants.communitiesCollection);

  // Function to create a new community in Firestore.
  FutureVoid createCommunity(Community community) async {
    try {
      // get the community document based on the name
      var communityDoc = await _communities.doc(community.name).get();

      // Check if a community with the same name already exists.
      if (communityDoc.exists) {
        throw 'Community With The Same Name Already Exists!';
      }

      // Set the data for the new community in Firestore and return a successful result (Right).
      return Right(_communities.doc(community.name).set(community.toMap()));
    } catch (e) {
      print(e.toString());
      return Left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map((event) {
      return Community.fromMap(event.data() as Map<String, dynamic>);
    });
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addModsToCommunity(String communityName, List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({
        'mods': uids,
      }));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }



  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where('name',
            isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
            isLessThan: query.isEmpty
                ? null
                : query.substring(0, query.length - 1) +
                    String.fromCharCode(query.codeUnitAt(query.length - 1) + 1))
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }
  FutureVoid joinCommunity(String communityName, String uid) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([uid]),
      }));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String uid) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([uid]),
      }));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

}
