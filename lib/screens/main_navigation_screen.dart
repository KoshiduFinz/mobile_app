import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'messages_screen.dart';
import 'requests_screen.dart';
import '../widgets/app_drawer.dart';
import '../constants/app_constants.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [];

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      HomeScreen(onMenuTap: _openDrawer),
      SearchScreen(onMenuTap: _openDrawer),
      MessagesScreen(onMenuTap: _openDrawer),
      RequestsScreen(onMenuTap: _openDrawer),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: false, // Disable swipe to open, only open via icon
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.gradientRoyal,
        ),
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search,
                  label: 'Search',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.message_outlined,
                  selectedIcon: Icons.message,
                  label: 'Messages',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_add_outlined,
                  selectedIcon: Icons.person_add,
                  label: 'Requests',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Translucent gold oval indicator behind active icon
                if (isSelected)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppConstants.luxuryGold.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                // Icon
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? AppConstants.luxuryGold : Colors.white,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppConstants.luxuryGold : Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

