class UserProfile {
  final String id;
  final String displayName;
  final String fullName;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? bio;
  
  // Location
  final String? residenceCity;
  final String? residenceCountry;
  
  // Profession
  final String? profession;
  final String? highestEducation;
  final String? careerLevel;
  
  // Personal Info
  final String? maritalStatus;
  final String? ethnicity;
  final String? religion;
  final String? caste;
  final List<String>? spokenLanguages;
  final String? personalityType;
  
  // Physical Appearance
  final int? heightCm;
  final int? weightKg;
  final String? bodyType;
  final String? complexion;
  
  // Lifestyle
  final String? dietaryPreference;
  final String? drinking;
  final String? smoking;
  final List<String>? hobbies;
  
  // Ideal Partner Preferences
  final String? idealPartnerDescription;
  
  UserProfile({
    required this.id,
    required this.displayName,
    required this.fullName,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.bio,
    this.residenceCity,
    this.residenceCountry,
    this.profession,
    this.highestEducation,
    this.careerLevel,
    this.maritalStatus,
    this.ethnicity,
    this.religion,
    this.caste,
    this.spokenLanguages,
    this.personalityType,
    this.heightCm,
    this.weightKg,
    this.bodyType,
    this.complexion,
    this.dietaryPreference,
    this.drinking,
    this.smoking,
    this.hobbies,
    this.idealPartnerDescription,
  });
  
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
  
  String get location {
    final parts = <String>[];
    if (residenceCity != null) parts.add(residenceCity!);
    if (residenceCountry != null) parts.add(residenceCountry!);
    return parts.isEmpty ? 'Location not specified' : parts.join(', ');
  }
}

