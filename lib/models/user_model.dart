class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoURL;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoURL,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? "", // ✅ Default empty string if null
      name: map['name'] ?? "Unknown", // ✅ Default name if null
      email: map['email'] ?? "", // ✅ Default empty email
      photoURL: map['photoURL'] ?? "", // ✅ Default empty photo URL
      role: map['role'] ?? "user", // ✅ Default role as "user"
    );
  }
}
