import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/auth/login_screen.dart';
import '../models/user_profile.dart';
import '../constants/app_constants.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _authService = AuthService();
  final _profileService = ProfileService();
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _profileService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoadingProfile = false;
        });
        // Debug: Print avatar URL to help diagnose image loading issues
        if (profile?.avatarUrl != null) {
          debugPrint('Profile avatar URL: ${profile!.avatarUrl}');
        } else {
          debugPrint('No avatar URL found for user');
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProfileAvatar(String displayName, String? avatarUrl) {
    if (_isLoadingProfile) {
      return CircleAvatar(
        radius: 35,
        backgroundColor: Colors.grey[800],
        child: const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    }

    if (avatarUrl == null || avatarUrl.isEmpty) {
      return CircleAvatar(
        radius: 35,
        backgroundColor: Colors.grey[800],
        child: displayName.isNotEmpty
            ? Text(
                displayName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.person, size: 40, color: Colors.white),
      );
    }

    // Use Image.network with error handling
    return CircleAvatar(
      radius: 35,
      backgroundColor: Colors.grey[800],
      child: ClipOval(
        child: Image.network(
          avatarUrl,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Log error for debugging
            debugPrint('Error loading profile image: $error');
            debugPrint('Image URL: $avatarUrl');
            // If image fails to load, show fallback
            return Container(
              width: 70,
              height: 70,
              color: Colors.grey[800],
              child: displayName.isNotEmpty
                  ? Center(
                      child: Text(
                        displayName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const Icon(Icons.person, size: 40, color: Colors.white),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 70,
              height: 70,
              color: Colors.grey[800],
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    final displayName = _userProfile?.displayName ?? 
                       _userProfile?.fullName ?? 
                       currentUser?.userMetadata?['first_name'] ?? 
                       'User';
    final avatarUrl = _userProfile?.avatarUrl;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.gradientRoyal,
        ),
        child: SafeArea(
          child: Column(
            children: [
            // User Profile Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildProfileAvatar(displayName, avatarUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppConstants.accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${currentUser?.email?.split('@')[0] ?? 'username'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _buildActionIcon(Icons.public, Colors.white),
                      const SizedBox(height: 8),
                      _buildActionIcon(Icons.settings, AppConstants.accentColor),
                      const SizedBox(height: 8),
                      _buildActionIcon(Icons.star, AppConstants.accentColor),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white30, height: 1),

            // Menu List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(Icons.person, 'Profile', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  }),
                  _buildMenuItem(Icons.edit, 'Edit Profile', () async {
                    // Reload profile to ensure we have the latest data
                    await _loadUserProfile();
                    if (_userProfile != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            initialProfile: _userProfile!,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to load profile. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }),
                  _buildMenuItem(Icons.notifications, 'Notifications', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  }),
                  _buildMenuItem(Icons.bookmark, 'Saved Posts', () {
                    // TODO: Navigate to saved posts
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved posts coming soon')),
                    );
                  }),
                  _buildMenuItem(Icons.settings, 'Settings', () {
                    // TODO: Navigate to settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon')),
                    );
                  }),
                  const Divider(color: Colors.white30, height: 1),
                  _buildMenuItem(Icons.logout, 'Logout', _handleLogout, isLogout: true),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30, width: 1),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Builder(
      builder: (context) => ListTile(
        leading: Icon(
          icon,
          color: isLogout ? AppConstants.accentColor : Colors.white,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? AppConstants.accentColor : Colors.white,
            fontSize: 16,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close drawer
          onTap();
        },
      ),
    );
  }

}

