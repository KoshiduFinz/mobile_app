import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../widgets/profile_card.dart';
import '../constants/app_constants.dart';
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
  bool _isLoading = true;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final profiles = await _profileService.getDiscoverableProfiles();
      setState(() {
        _profiles = profiles;
        _currentIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profiles: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: widget.onMenuTap,
        ),
        title: const Text('Discover', style: TextStyle(color: Colors.white)),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppConstants.gradientRoyal,
          ),
        ),
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _profiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No profiles available',
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppConstants.gradientGold,
                    ),
                    child: ElevatedButton(
                      onPressed: _loadProfiles,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Refresh', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
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

