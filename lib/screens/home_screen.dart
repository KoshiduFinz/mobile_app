import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/mock_profiles.dart';
import '../widgets/profile_card.dart';
import 'chat_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  
  const HomeScreen({super.key, this.onMenuTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UserProfile> _profiles = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() {
    setState(() {
      _profiles = MockProfiles.getProfiles();
      _currentIndex = 0;
    });
  }

  void _handleLike() {
    if (_currentIndex < _profiles.length) {
      final profile = _profiles[_currentIndex];
      // Show like animation feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.white),
              const SizedBox(width: 8),
              Text('You liked ${profile.displayName}'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
      // Show next profile immediately - animation already completed in ProfileCard
      _showNextProfile();
    }
  }

  void _handleReject() {
    if (_currentIndex < _profiles.length) {
      final profile = _profiles[_currentIndex];
      // Show reject animation feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.close, color: Colors.white),
              const SizedBox(width: 8),
              Text('You passed on ${profile.displayName}'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
      // Show next profile immediately - animation already completed in ProfileCard
      _showNextProfile();
    }
  }

  void _handleMessage() {
    if (_currentIndex < _profiles.length) {
      final profile = _profiles[_currentIndex];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(profile: profile),
        ),
      );
    }
  }

  void _showNextProfile() {
    setState(() {
      _currentIndex++;
      if (_currentIndex >= _profiles.length) {
        // No more profiles, reload
        _loadProfiles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuTap,
        ),
        title: const Text('Discover'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _profiles.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _currentIndex >= _profiles.length
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No more profiles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for more matches',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadProfiles,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: SingleChildScrollView(
                    key: ValueKey(_profiles[_currentIndex].id),
                    child: ProfileCard(
                      key: ValueKey('card_${_profiles[_currentIndex].id}'),
                      profile: _profiles[_currentIndex],
                      onLike: _handleLike,
                      onReject: _handleReject,
                      onMessage: _handleMessage,
                    ),
                  ),
                ),
    );
  }
}

