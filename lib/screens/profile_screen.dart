import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../constants/app_constants.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _currentUserProfile;
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final profile = await _profileService.getCurrentUserProfile();
      setState(() {
        _currentUserProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentUserProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile', style: TextStyle(color: Colors.white)),
          foregroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppConstants.gradientRoyal,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppConstants.gradientRoyal,
          ),
        ),
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
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppConstants.mutedText,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppConstants.mutedText),
                      const SizedBox(width: 4),
                      Text(
                        _currentUserProfile!.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.mutedText,
                        ),
                      ),
                    ],
                  ),
                  if (_currentUserProfile!.profession != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.work, size: 16, color: AppConstants.mutedText),
                        const SizedBox(width: 4),
                        Text(
                          _currentUserProfile!.profession!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.mutedText,
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
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.mutedText,
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
                        backgroundColor: AppConstants.royalPurple.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppConstants.royalPurple),
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
                        backgroundColor: AppConstants.luxuryGold.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppConstants.luxuryGold),
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

