import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String? link;
  final String? image;
  final String? description;
  final String communityName;
  final String communityProfilePic;
  final List<String> upVotes;
  final List<String> downVotes;
  final int commentCount;
  final String userName;
  final String uid;
  final String userProfilePic;
  final String type;
  final DateTime createdAt;
  final List<String> awards;

//<editor-fold desc="Data Methods">

  const Post({
    required this.id,
    required this.title,
    this.link,
    this.image,
    this.description,
    required this.communityName,
    required this.communityProfilePic,
    required this.upVotes,
    required this.downVotes,
    required this.commentCount,
    required this.userName,
    required this.uid,
    required this.userProfilePic,
    required this.type,
    required this.createdAt,
    required this.awards,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Post &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          link == other.link &&
          image == other.image &&
          description == other.description &&
          communityName == other.communityName &&
          communityProfilePic == other.communityProfilePic &&
          upVotes == other.upVotes &&
          downVotes == other.downVotes &&
          commentCount == other.commentCount &&
          userName == other.userName &&
          uid == other.uid &&
          userProfilePic == other.userProfilePic &&
          type == other.type &&
          createdAt == other.createdAt &&
          awards == other.awards);

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      link.hashCode ^
      image.hashCode ^
      description.hashCode ^
      communityName.hashCode ^
      communityProfilePic.hashCode ^
      upVotes.hashCode ^
      downVotes.hashCode ^
      commentCount.hashCode ^
      userName.hashCode ^
      uid.hashCode ^
      userProfilePic.hashCode ^
      type.hashCode ^
      createdAt.hashCode ^
      awards.hashCode;

  @override
  String toString() {
    return 'Post{' +
        ' id: $id,' +
        ' title: $title,' +
        ' link: $link,' +
        ' image: $image,' +
        ' description: $description,' +
        ' communityName: $communityName,' +
        ' communityProfilePic: $communityProfilePic,' +
        ' upvotes: $upVotes,' +
        ' downvotes: $downVotes,' +
        ' commentCount: $commentCount,' +
        ' userName: $userName,' +
        ' uid: $uid,' +
        ' userProfilePic: $userProfilePic,' +
        ' type: $type,' +
        ' createdAt: $createdAt,' +
        ' awards: $awards,' +
        '}';
  }

  Post copyWith({
    String? id,
    String? title,
    String? link,
    String? image,
    String? description,
    String? communityName,
    String? communityProfilePic,
    List<String>? upvotes,
    List<String>? downvotes,
    int? commentCount,
    String? userName,
    String? uid,
    String? userProfilePic,
    String? type,
    DateTime? createdAt,
    List<String>? awards,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      image: image ?? this.image,
      description: description ?? this.description,
      communityName: communityName ?? this.communityName,
      communityProfilePic: communityProfilePic ?? this.communityProfilePic,
      upVotes: upvotes ?? this.upVotes,
      downVotes: downvotes ?? this.downVotes,
      commentCount: commentCount ?? this.commentCount,
      userName: userName ?? this.userName,
      uid: uid ?? this.uid,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'link': this.link,
      'image': this.image,
      'description': this.description,
      'communityName': this.communityName,
      'communityProfilePic': this.communityProfilePic,
      'upvotes': this.upVotes,
      'downvotes': this.downVotes,
      'commentCount': this.commentCount,
      'userName': this.userName,
      'uid': this.uid,
      'userProfilePic': this.userProfilePic,
      'type': this.type,
      'createdAt': this.createdAt,
      'awards': this.awards,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    List<String> upVotes = (map['upVotes'] as List<dynamic>?)
            ?.map((upVote) => upVote.toString())
            .toList() ??
        [];

    List<String> downVotes = (map['downVotes'] as List<dynamic>?)
            ?.map((downVote) => downVote.toString())
            .toList() ??
        [];

    List<String> awards = (map['awards'] as List<dynamic>?)
            ?.map((award) => award.toString())
            .toList() ??
        [];

    // Convert Firestore Timestamp to DateTime
    Timestamp createdAtTimestamp = map['createdAt'] as Timestamp;
    DateTime createdAt = createdAtTimestamp.toDate();

    return Post(
      id: map['id'] as String,
      title: map['title'] as String,
      link: map['link'] as String?,
      image: map['image'] as String?,
      description: map['description'] as String?,
      communityName: map['communityName'] as String,
      communityProfilePic: map['communityProfilePic'] as String,
      upVotes: upVotes,
      downVotes: downVotes,
      commentCount: map['commentCount'] as int,
      userName: map['userName'] as String,
      uid: map['uid'] as String,
      userProfilePic: map['userProfilePic'] as String,
      type: map['type'] as String,
      createdAt: createdAt,
      awards: awards,
    );
  }

//</editor-fold>
}
