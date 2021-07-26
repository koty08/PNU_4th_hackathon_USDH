import 'package:cloud_firestore/cloud_firestore.dart';

// user 정보 저장
class UserChat {
  String id;
  String photoUrl;
  String nick;

  UserChat({required this.id, required this.photoUrl, required this.nick});

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    return UserChat(
      id: doc['email'],
      photoUrl: doc['photoUrl'],
      nick: doc['nick'],
    );
  }
}
