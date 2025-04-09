import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_app/views/library_home_screen.dart';
import 'package:library_app/views/study_room/room_list.dart';

import '../all_room_screen.dart';
import '../cummunity_screen.dart';

class MainScaffold extends StatefulWidget {
  final Widget body;
  final int currentIndex;
  final PreferredSizeWidget? appBar;
  final Color backgroundColor;

  const MainScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    this.appBar,
    this.backgroundColor = Colors.white,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    _currentIndex = widget.currentIndex;
    super.initState();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        Get.offAll(() => const LibraryHomeScreen());
        break;
      case 1:
        Get.offAll(() => const RoomListView());
        break;
      case 2:
        Get.offAll(() => const CommunityScreen());
        break;
      case 3:
        Get.offAll(() => const AllRoomsScreen());
        break;

    // Add future navigation here

    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: widget.appBar,
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chair_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
