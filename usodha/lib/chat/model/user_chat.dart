import 'package:cloud_firestore/cloud_firestore.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;
  String aboutMe;

  UserChat(
      {required this.id,
      required this.photoUrl,
      required this.nickname,
      required this.aboutMe});

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    return UserChat(
      id: doc['email'],
      photoUrl: doc['photoUrl'],
      nickname: doc['nickname'],
      aboutMe: doc['aboutMe'],
    );
  }
}
