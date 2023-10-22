import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String text;
  final String postId;
  final String userName;
  final String userProfilePic;
  final DateTime createdAt;

//<editor-fold desc="Data Methods">
  const Comment({
    required this.id,
    required this.text,
    required this.postId,
    required this.userName,
    required this.userProfilePic,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Comment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          postId == other.postId &&
          userName == other.userName &&
          userProfilePic == other.userProfilePic &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      text.hashCode ^
      postId.hashCode ^
      userName.hashCode ^
      userProfilePic.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'Comment{' +
        ' id: $id,' +
        ' text: $text,' +
        ' postId: $postId,' +
        ' userName: $userName,' +
        ' userProfilePic: $userProfilePic,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  Comment copyWith({
    String? id,
    String? text,
    String? postId,
    String? userName,
    String? userProfilePic,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      postId: postId ?? this.postId,
      userName: userName ?? this.userName,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'text': this.text,
      'postId': this.postId,
      'userName': this.userName,
      'userProfilePic': this.userProfilePic,
      'createdAt': this.createdAt,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    // Convert Firestore Timestamp to DateTime
    Timestamp createdAtTimestamp = map['createdAt'] as Timestamp;
    DateTime createdAt = createdAtTimestamp.toDate();
    return Comment(
      id: map['id'] as String,
      text: map['text'] as String,
      postId: map['postId'] as String,
      userName: map['userName'] as String,
      userProfilePic: map['userProfilePic'] as String,
      createdAt: createdAt,
    );
  }

//</editor-fold>
}
