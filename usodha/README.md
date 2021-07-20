# 채팅 기능
1. 기본적인 채팅 틀은 예제를 활용
2. 본인이 쓴 메세지들은 시간 순으로 정렬되어 firebase에 저장됨
3. 'idFrom' field 에는 상대방 id, 'idTo' field 에는 본인 id 저장


- model/userchat : 상대에게 보일 각 user의 정보
- const : default 색 설정
- widget/loading : loading중 표시 design
- home : 현재 내가 포함된 채팅방들 리스트 정렬
- chatting : 각 채팅방의 내용들 가져옴
