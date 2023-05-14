class ChatUser {
  ChatUser({
    required this.created_At,
    required this.image,
    required this.about,
    required this.name,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
  });
  late final String created_At;
  late final String image;
  late final String about;
  late final String name;
  late final bool isOnline;
  late final String id;
  late final String lastActive;
  late final String email;
  late final String pushToken;
  
  ChatUser.fromJson(Map<String, dynamic> json){
    created_At = json['created_id'] ?? '';
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    isOnline = json['is_online'] ?? '';
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['created_id'] = created_At;
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}