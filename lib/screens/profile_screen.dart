import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/mock_profiles.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _currentUserProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    // For now, use mock data. Later this will come from Supabase
    // Get the first profile as a placeholder for current user
    final profiles = MockProfiles.getProfiles();
    setState(() {
      _currentUserProfile = profiles[0]; // Using first profile as mock current user
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    initialProfile: _currentUserProfile!,
                  ),
                ),
              );
              if (result == true) {
                // Reload profile if it was updated
                _loadUserProfile();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            _buildProfileImageSection(),

            // Name and Location Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentUserProfile!.displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_currentUserProfile!.age != null)
                        Text(
                          '${_currentUserProfile!.age}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _currentUserProfile!.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (_currentUserProfile!.profession != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.work, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _currentUserProfile!.profession!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const Divider(),

            // About Me Section
            _buildSection(
              title: 'About Me',
              content: _currentUserProfile!.bio ?? 'No bio available',
            ),

            // My Ideal Partner Section
            if (_currentUserProfile!.idealPartnerDescription != null)
              _buildSection(
                title: 'My Ideal Partner',
                content: _currentUserProfile!.idealPartnerDescription!,
              ),

            // Additional Details
            _buildDetailsSection(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: _currentUserProfile!.avatarUrl != null
          ? Image.network(
              _currentUserProfile!.avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Text(
          _currentUserProfile!.displayName[0].toUpperCase(),
          style: TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_currentUserProfile!.maritalStatus != null)
                _buildDetailChip('Marital Status', _currentUserProfile!.maritalStatus!),
              if (_currentUserProfile!.religion != null)
                _buildDetailChip('Religion', _currentUserProfile!.religion!),
              if (_currentUserProfile!.ethnicity != null)
                _buildDetailChip('Ethnicity', _currentUserProfile!.ethnicity!),
              if (_currentUserProfile!.caste != null)
                _buildDetailChip('Caste', _currentUserProfile!.caste!),
              if (_currentUserProfile!.heightCm != null)
                _buildDetailChip('Height', '${_currentUserProfile!.heightCm} cm'),
              if (_currentUserProfile!.bodyType != null)
                _buildDetailChip('Body Type', _currentUserProfile!.bodyType!),
              if (_currentUserProfile!.complexion != null)
                _buildDetailChip('Complexion', _currentUserProfile!.complexion!),
              if (_currentUserProfile!.highestEducation != null)
                _buildDetailChip('Education', _currentUserProfile!.highestEducation!),
              if (_currentUserProfile!.dietaryPreference != null)
                _buildDetailChip('Diet', _currentUserProfile!.dietaryPreference!),
              if (_currentUserProfile!.drinking != null)
                _buildDetailChip('Drinking', _currentUserProfile!.drinking!),
              if (_currentUserProfile!.smoking != null)
                _buildDetailChip('Smoking', _currentUserProfile!.smoking!),
              if (_currentUserProfile!.personalityType != null)
                _buildDetailChip('Personality', _currentUserProfile!.personalityType!),
            ],
          ),
          if (_currentUserProfile!.hobbies != null && _currentUserProfile!.hobbies!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Hobbies',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentUserProfile!.hobbies!
                  .map((hobby) => Chip(
                        label: Text(hobby),
                        backgroundColor: Colors.blue[50],
                      ))
                  .toList(),
            ),
          ],
          if (_currentUserProfile!.spokenLanguages != null &&
              _currentUserProfile!.spokenLanguages!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Languages',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentUserProfile!.spokenLanguages!
                  .map((lang) => Chip(
                        label: Text(lang),
                        backgroundColor: Colors.green[50],
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}

