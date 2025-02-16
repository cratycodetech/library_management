import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String id;
  String name;
  String adminId;
  List<String> members;
  Timestamp createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.adminId,
    required this.members,
    required this.createdAt,
  });


  factory GroupModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GroupModel(
      id: documentId,
      name: data['name'],
      adminId: data['adminId'],
      members: List<String>.from(data['members']),
      createdAt: data['createdAt'],
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'adminId': adminId,
      'members': members,
      'createdAt': createdAt,
    };
  }
}
