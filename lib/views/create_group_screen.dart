import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/routes.dart';
import '../services/group_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final GroupService _groupService = GroupService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  List<Map<String, dynamic>> _allUsers = [];
  List<String> _selectedUserIds = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Fetch all users to display in selection list
  void _fetchUsers() async {
    List<Map<String, dynamic>> users = await _groupService.getAllUsers();
    setState(() {
      _allUsers = users;
    });
  }

  void _createGroup() async {
    if (_groupNameController.text.isEmpty) {
      Get.snackbar("Error", "Group name cannot be empty!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String adminId = _auth.currentUser!.uid;
    List<String> members = [..._selectedUserIds, adminId];

    String groupId = await _groupService.createGroup(_groupNameController.text, adminId, members);

    if (groupId.isNotEmpty) {

      Get.offNamed(
        AppRoutes.groupChatScreen,
        arguments: {
          'groupId': groupId,
          'groupName': _groupNameController.text.trim(),
        },
      );
    } else {
      Get.snackbar("Error", "Group with this name already exists.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Group")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: "Group Name"),
            ),
            SizedBox(height: 20),
            Text("Select Members:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: _allUsers.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  :ListView.builder(
                itemCount: _allUsers.length,
                itemBuilder: (context, index) {
                  final user = _allUsers[index];
                  bool isFile = user["isFile"] ?? false;
                  String uid = user["uid"] ?? "";
                  String name = user["name"] ?? "Unknown";
                  String email = user["email"] ?? "No email";

                  return CheckboxListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(name)),
                        if (isFile) Icon(Icons.arrow_forward, color: Colors.grey),
                      ],
                    ),
                    subtitle: Text(email),
                    value: _selectedUserIds.contains(uid),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedUserIds.add(uid);
                        } else {
                          _selectedUserIds.remove(uid);
                        }
                      });
                    },
                  );
                },

              ),
            ),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _createGroup,
              child: Text("Create Group"),
            ),
          ],
        ),
      ),
    );
  }
}
