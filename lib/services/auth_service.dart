import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agasthi_mobile/services/supabase_client.dart';

class AuthService {
  SupabaseClient get _supabase => SupabaseService.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? mobileNumber,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    try {
      // Sign up the user in Supabase Auth
      final AuthResponse authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      // If sign up successful and user exists, create/update profile
      if (authResponse.user != null) {
        final userId = authResponse.user!.id;
        
        // Wait a moment for the trigger to create the profile
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Check if profile exists
        var profileExists = false;
        try {
          final existingProfile = await getProfile(userId);
          profileExists = existingProfile != null;
          debugPrint('Profile exists check: $profileExists');
        } catch (e) {
          debugPrint('Error checking profile: $e');
        }
        
        // If profile doesn't exist, try to create it manually
        if (!profileExists) {
          try {
            debugPrint('Profile not found, attempting to create manually...');
            await _createProfileManually(
              userId: userId,
              email: email,
              firstName: firstName,
              lastName: lastName,
              mobileNumber: mobileNumber,
              dateOfBirth: dateOfBirth,
              gender: gender,
            );
            debugPrint('Profile created successfully');
          } catch (createError) {
            debugPrint('Failed to create profile manually: $createError');
            // Don't throw - let the trigger handle it later
          }
        } else {
          // Profile exists, update it with additional information
          try {
            debugPrint('Profile exists, updating with additional info...');
            await _updateProfile(
              userId: userId,
              firstName: firstName,
              lastName: lastName,
              mobileNumber: mobileNumber,
              dateOfBirth: dateOfBirth,
              gender: gender,
            );
            debugPrint('Profile updated successfully');
            
            // Update contact verification with mobile number if provided
            if (mobileNumber != null) {
              try {
                await _supabase.from('contact_verification').update({
                  'phone': mobileNumber,
                }).eq('profile_id', userId);
                debugPrint('Contact verification updated');
              } catch (e) {
                debugPrint('Warning: Failed to update contact verification: $e');
              }
            }
          } catch (updateError) {
            debugPrint('Warning: Could not update profile: $updateError');
            // Don't throw - profile exists, user can update later
          }
        }
      }

      return authResponse;
    } on AuthException catch (e) {
      // Handle Supabase auth specific errors
      throw Exception(_getErrorMessage(e.message));
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      // Handle Supabase auth specific errors
      throw Exception(_getErrorMessage(e.message));
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Create profile manually using database function (bypasses RLS)
  Future<void> _createProfileManually({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    String? mobileNumber,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    final fullName = '$firstName $lastName'.trim();
    final displayName = firstName;

    // Use database function with SECURITY DEFINER to bypass RLS
    await _supabase.rpc('create_or_update_profile', params: {
      'p_user_id': userId,
      'p_full_name': fullName,
      'p_display_name': displayName,
      'p_gender': gender,
      'p_date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'p_contact_number': mobileNumber,
      'p_email': email,
    });
  }

  // Update profile (used when profile already exists)
  // Note: Profile is automatically created by database trigger handle_new_user()
  Future<void> _updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    String? mobileNumber,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    final fullName = '$firstName $lastName'.trim();
    final displayName = firstName;

    try {
      // Try direct update first (works if user is authenticated)
      final updateData = <String, dynamic>{
        'full_name': fullName,
        'display_name': displayName,
      };

      if (gender != null) updateData['gender'] = gender;
      if (dateOfBirth != null) {
        updateData['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
      }
      if (mobileNumber != null) updateData['contact_number'] = mobileNumber;

      await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', userId);
    } catch (e) {
      // If direct update fails (RLS issue), use RPC function
      debugPrint('Direct update failed, using RPC function: $e');
      await _supabase.rpc('create_or_update_profile', params: {
        'p_user_id': userId,
        'p_full_name': fullName,
        'p_display_name': displayName,
        'p_gender': gender,
        'p_date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
        'p_contact_number': mobileNumber,
        'p_email': null, // Don't update email on profile update
      });
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Helper method to convert Supabase error messages to user-friendly messages
  String _getErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (message.contains('User already registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    } else if (message.contains('Password should be at least')) {
      return 'Password must be at least 6 characters long.';
    } else if (message.contains('Email not confirmed')) {
      return 'Please verify your email address before signing in.';
    } else if (message.contains('Email rate limit exceeded')) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    return message;
  }
}
