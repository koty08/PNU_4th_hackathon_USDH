# 백엔드 KKK
채팅방 1ㄷ1 기능만 구현

더 야 할거
1. firestore가 굉장히 비효율적인 느낌
 -> 예를 들면 한 user의 email을 여러 번 저장함(users-user@pusan.ac.kr-email 을 유연하게 빼야하는데,,)
2. 1과 비슷한데 users-user@pusan.ac.kr-email 정보를 유연하게 못 빼와서 chatting.dart의 readLocal 함수 내에서
  email 설정을 못함
 -> sharedReference를 좀 공부하면 할 수 있을 듯

3. board.dart에서 제한 인원, 참가 기능 구현해서 그룹방 기능 구현해야함
