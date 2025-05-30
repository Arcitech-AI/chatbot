// models/user_model.dart
class AppUser {
  final String uid;
  final String email;
  final String name;
  final List<String> friends;
  final List<String> sentRequests;
  final List<String> receivedRequests;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.friends,
    required this.sentRequests,
    required this.receivedRequests,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'],
      name: data['name'],
      friends: List<String>.from(data['friends'] ?? []),
      sentRequests: List<String>.from(data['sentRequests'] ?? []),
      receivedRequests: List<String>.from(data['receivedRequests'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'friends': friends,
        'sentRequests': sentRequests,
        'receivedRequests': receivedRequests,
      };
}
