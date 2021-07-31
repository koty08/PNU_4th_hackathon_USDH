import 'package:cloud_firestore/cloud_firestore.dart';

// user 정보 저장
class ChatRoom {
  String chatName;
  List<dynamic> peerIds;

  ChatRoom({required this.chatName, required this.peerIds});

  factory ChatRoom.fromDocument(DocumentSnapshot doc) {
    return ChatRoom(
      chatName: doc['chatRoomName'],
      peerIds: doc['chatMembers'],
    );
  }
}
