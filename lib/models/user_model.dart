class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoURL;
  final String role;

  UserModel({required this.uid, required this.name, required this.email, required this.photoURL, required this.role});

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
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      photoURL: map['photoURL'],
      role: map['role'],
    );
  }
}
