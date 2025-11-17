import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../models/mock_profiles.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.currentUser;

    return Drawer(
      backgroundColor: Colors.black,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            // User Profile Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey[800],
                    child: currentUser?.userMetadata?['first_name'] != null
                        ? Text(
                            currentUser!.userMetadata!['first_name'][0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              currentUser?.userMetadata?['first_name'] ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.verified,
                              color: Colors.blue[400],
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${currentUser?.email?.split('@')[0] ?? 'username'}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _buildActionIcon(Icons.public, Colors.white),
                      const SizedBox(height: 8),
                      _buildActionIcon(Icons.settings, const Color(0xFF14B8A6)),
                      const SizedBox(height: 8),
                      _buildActionIcon(Icons.star, const Color(0xFF14B8A6)),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.grey, height: 1),

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
                  _buildMenuItem(Icons.edit, 'Edit Profile', () {
                    // Get current user profile (using mock data for now)
                    final profiles = MockProfiles.getProfiles();
                    final currentUserProfile = profiles[0]; // Using first profile as mock current user
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          initialProfile: currentUserProfile,
                        ),
                      ),
                    );
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Builder(
      builder: (context) => ListTile(
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        onTap: () {
          Navigator.pop(context); // Close drawer
          onTap();
        },
      ),
    );
  }

}

