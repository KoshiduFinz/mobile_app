import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'supabase_client.dart';
import 'auth_service.dart';

class ProfileService {
  final SupabaseClient _supabase = SupabaseService.client;
  final AuthService _authService = AuthService();

  // Get current user's profile with all related data
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return null;

      return await getProfileById(userId);
    } catch (e) {
      print('Error fetching current user profile: $e');
      return null;
    }
  }

  // Get discoverable profiles (excluding current user)
  Future<List<UserProfile>> getDiscoverableProfiles({int limit = 50}) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('profiles')
          .select()
          .neq('id', userId)
          .limit(limit);

      if (response.isEmpty) return [];

      final List<UserProfile> profiles = [];
      for (final profileData in response) {
        final profile = await _buildFullProfile(profileData);
        if (profile != null) {
          profiles.add(profile);
        }
      }

      return profiles;
    } catch (e) {
      print('Error fetching discoverable profiles: $e');
      return [];
    }
  }

  // Get a specific profile by ID with all related data
  Future<UserProfile?> getProfileById(String profileId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', profileId)
          .maybeSingle();

      if (response == null) return null;
      return await _buildFullProfile(response);
    } catch (e) {
      print('Error fetching profile by ID: $e');
      return null;
    }
  }

  // Build a complete profile by joining data from multiple tables
  Future<UserProfile?> _buildFullProfile(Map<String, dynamic> profileData) async {
    try {
      final profileId = profileData['id']?.toString();
      if (profileId == null) return null;

      // Fetch related data from other tables
      final personalInfo = await _supabase
          .from('personal_info')
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();

      final physicalAppearance = await _supabase
          .from('physical_appearance')
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();

      final educationProfession = await _supabase
          .from('education_profession')
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();

      final locationMobility = await _supabase
          .from('location_mobility')
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();

      final lifestyleInterests = await _supabase
          .from('lifestyle_interests')
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();

      // Parse date of birth
      DateTime? dateOfBirth;
      if (profileData['date_of_birth'] != null) {
        try {
          if (profileData['date_of_birth'] is String) {
            dateOfBirth = DateTime.parse(profileData['date_of_birth']);
          }
        } catch (e) {
          print('Error parsing date_of_birth: $e');
        }
      }

      // Get hobbies and spoken languages from arrays
      List<String>? hobbies;
      if (lifestyleInterests != null && lifestyleInterests['hobbies'] != null) {
        if (lifestyleInterests['hobbies'] is List) {
          hobbies = List<String>.from(lifestyleInterests['hobbies']);
        }
      }

      List<String>? spokenLanguages;
      if (personalInfo != null && personalInfo['spoken_languages'] != null) {
        if (personalInfo['spoken_languages'] is List) {
          spokenLanguages = List<String>.from(personalInfo['spoken_languages']);
        }
      }

      // Normalize gender value to match dropdown options
      String? normalizedGender = profileData['gender'];
      if (normalizedGender != null) {
        final lowerGender = normalizedGender.toLowerCase().trim();
        if (lowerGender == 'male' || lowerGender == 'm') {
          normalizedGender = 'Male';
        } else if (lowerGender == 'female' || lowerGender == 'f') {
          normalizedGender = 'Female';
        } else if (lowerGender == 'other') {
          normalizedGender = 'Other';
        }
        // Keep original if it doesn't match any pattern
      }

      return UserProfile(
        id: profileId,
        displayName: profileData['display_name'] ?? profileData['full_name']?.split(' ').first ?? 'Unknown',
        fullName: profileData['full_name'] ?? profileData['display_name'] ?? 'Unknown',
        avatarUrl: profileData['avatar_url'],
        gender: normalizedGender,
        dateOfBirth: dateOfBirth,
        bio: profileData['bio'],
        residenceCity: locationMobility?['residence_city'],
        residenceCountry: locationMobility?['residence_country'],
        profession: educationProfession?['profession'],
        highestEducation: educationProfession?['highest_education'],
        careerLevel: educationProfession?['career_level'],
        maritalStatus: personalInfo?['marital_status'],
        ethnicity: personalInfo?['ethnicity'],
        religion: personalInfo?['religion'],
        caste: personalInfo?['caste'],
        spokenLanguages: spokenLanguages,
        personalityType: personalInfo?['personality_type'],
        heightCm: physicalAppearance?['height_cm'] != null 
            ? int.tryParse(physicalAppearance!['height_cm'].toString()) 
            : null,
        weightKg: physicalAppearance?['weight_kg'] != null 
            ? int.tryParse(physicalAppearance!['weight_kg'].toString()) 
            : null,
        bodyType: physicalAppearance?['body_type'],
        complexion: physicalAppearance?['complexion'],
        dietaryPreference: lifestyleInterests?['dietary_preference'],
        drinking: lifestyleInterests?['drinking'],
        smoking: lifestyleInterests?['smoking'],
        hobbies: hobbies,
        idealPartnerDescription: null, // This field doesn't exist in the schema
      );
    } catch (e) {
      print('Error building full profile: $e');
      return null;
    }
  }

  // Map Supabase data to UserProfile model (kept for backward compatibility)
  UserProfile mapToUserProfile(Map<String, dynamic> data) {
    // This method is deprecated - use _buildFullProfile instead
    // But keeping it for RequestService compatibility
    DateTime? dateOfBirth;
    if (data['date_of_birth'] != null) {
      try {
        if (data['date_of_birth'] is String) {
          dateOfBirth = DateTime.parse(data['date_of_birth']);
        }
      } catch (e) {
        print('Error parsing date_of_birth: $e');
      }
    }

    return UserProfile(
      id: data['id']?.toString() ?? '',
      displayName: data['display_name'] ?? data['full_name']?.split(' ').first ?? 'Unknown',
      fullName: data['full_name'] ?? data['display_name'] ?? 'Unknown',
      avatarUrl: data['avatar_url'],
      gender: data['gender'],
      dateOfBirth: dateOfBirth,
      bio: data['bio'],
      residenceCity: data['residence_city'],
      residenceCountry: data['residence_country'],
      profession: data['profession'],
      highestEducation: data['highest_education'],
      careerLevel: data['career_level'],
      maritalStatus: data['marital_status'],
      ethnicity: data['ethnicity'],
      religion: data['religion'],
      caste: data['caste'],
      spokenLanguages: data['spoken_languages'] != null && data['spoken_languages'] is List
          ? List<String>.from(data['spoken_languages'])
          : null,
      personalityType: data['personality_type'],
      heightCm: data['height_cm'] != null ? int.tryParse(data['height_cm'].toString()) : null,
      weightKg: data['weight_kg'] != null ? int.tryParse(data['weight_kg'].toString()) : null,
      bodyType: data['body_type'],
      complexion: data['complexion'],
      dietaryPreference: data['dietary_preference'],
      drinking: data['drinking'],
      smoking: data['smoking'],
      hobbies: data['hobbies'] != null && data['hobbies'] is List
          ? List<String>.from(data['hobbies'])
          : null,
      idealPartnerDescription: null,
    );
  }
}
