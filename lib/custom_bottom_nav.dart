import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final isAuthenticated;

  BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.isAuthenticated
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index);
      },
      type: BottomNavigationBarType.fixed, // Ensure all items are shown
      backgroundColor: Colors.transparent,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.format_list_numbered),
          label: 'Rules',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.connect_without_contact),
          label: 'Leaderboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.policy),
          label: 'Privacy Policy',
        ),
      ],
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.black,
    );
  }

}
