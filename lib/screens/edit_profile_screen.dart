import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final UserProfile initialProfile;

  const EditProfileScreen({
    super.key,
    required this.initialProfile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  late TextEditingController _residenceCityController;
  late TextEditingController _residenceCountryController;
  late TextEditingController _professionController;
  late TextEditingController _idealPartnerController;
  late TextEditingController _hobbiesController;
  late TextEditingController _languagesController;

  File? _selectedImage;
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedEthnicity;
  String? _selectedReligion;
  String? _selectedCaste;
  String? _selectedPersonalityType;
  String? _selectedEducation;
  String? _selectedCareerLevel;
  String? _selectedBodyType;
  String? _selectedComplexion;
  String? _selectedDietaryPreference;
  String? _selectedDrinking;
  String? _selectedSmoking;
  int? _heightCm;
  int? _weightKg;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _displayNameController = TextEditingController(text: widget.initialProfile.displayName);
    _fullNameController = TextEditingController(text: widget.initialProfile.fullName);
    _bioController = TextEditingController(text: widget.initialProfile.bio ?? '');
    _residenceCityController = TextEditingController(text: widget.initialProfile.residenceCity ?? '');
    _residenceCountryController = TextEditingController(text: widget.initialProfile.residenceCountry ?? '');
    _professionController = TextEditingController(text: widget.initialProfile.profession ?? '');
    _idealPartnerController = TextEditingController(text: widget.initialProfile.idealPartnerDescription ?? '');
    _hobbiesController = TextEditingController(text: widget.initialProfile.hobbies?.join(', ') ?? '');
    _languagesController = TextEditingController(text: widget.initialProfile.spokenLanguages?.join(', ') ?? '');

    _selectedDateOfBirth = widget.initialProfile.dateOfBirth;
    _selectedGender = widget.initialProfile.gender;
    _selectedMaritalStatus = widget.initialProfile.maritalStatus;
    _selectedEthnicity = widget.initialProfile.ethnicity;
    _selectedReligion = widget.initialProfile.religion;
    _selectedCaste = widget.initialProfile.caste;
    _selectedPersonalityType = widget.initialProfile.personalityType;
    _selectedEducation = widget.initialProfile.highestEducation;
    _selectedCareerLevel = widget.initialProfile.careerLevel;
    _selectedBodyType = widget.initialProfile.bodyType;
    _selectedComplexion = widget.initialProfile.complexion;
    _selectedDietaryPreference = widget.initialProfile.dietaryPreference;
    _selectedDrinking = widget.initialProfile.drinking;
    _selectedSmoking = widget.initialProfile.smoking;
    _heightCm = widget.initialProfile.heightCm;
    _weightKg = widget.initialProfile.weightKg;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    _residenceCityController.dispose();
    _residenceCountryController.dispose();
    _professionController.dispose();
    _idealPartnerController.dispose();
    _hobbiesController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // TODO: Implement image picker
    // For now, show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker will be implemented with image_picker package')),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to Supabase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate profile was updated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (widget.initialProfile.avatarUrl != null
                              ? NetworkImage(widget.initialProfile.avatarUrl!)
                              : null) as ImageProvider?,
                      child: _selectedImage == null && widget.initialProfile.avatarUrl == null
                          ? Text(
                              widget.initialProfile.displayName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Basic Information
              _buildSectionTitle('Basic Information'),
              _buildTextField(_displayNameController, 'Display Name', Icons.person, required: true),
              _buildTextField(_fullNameController, 'Full Name', Icons.badge),
              _buildTextField(_bioController, 'About Me', Icons.description, maxLines: 4),

              // Date of Birth
              _buildDateField('Date of Birth', _selectedDateOfBirth),

              // Gender
              _buildDropdownField(
                'Gender',
                _selectedGender,
                ['Male', 'Female', 'Other'],
                (value) => setState(() => _selectedGender = value),
              ),

              const SizedBox(height: 24),

              // Location
              _buildSectionTitle('Location'),
              _buildTextField(_residenceCityController, 'City', Icons.location_city),
              _buildTextField(_residenceCountryController, 'Country', Icons.public),

              const SizedBox(height: 24),

              // Profession
              _buildSectionTitle('Profession'),
              _buildTextField(_professionController, 'Profession', Icons.work),
              _buildDropdownField(
                'Education',
                _selectedEducation,
                ['High School', 'Bachelor\'s Degree', 'Master\'s Degree', 'Doctorate'],
                (value) => setState(() => _selectedEducation = value),
              ),
              _buildDropdownField(
                'Career Level',
                _selectedCareerLevel,
                ['Entry-level', 'Mid-level', 'Senior', 'Executive'],
                (value) => setState(() => _selectedCareerLevel = value),
              ),

              const SizedBox(height: 24),

              // Personal Information
              _buildSectionTitle('Personal Information'),
              _buildDropdownField(
                'Marital Status',
                _selectedMaritalStatus,
                ['Never Married', 'Divorced', 'Widowed', 'Separated'],
                (value) => setState(() => _selectedMaritalStatus = value),
              ),
              _buildDropdownField(
                'Ethnicity',
                _selectedEthnicity,
                ['Sinhalese', 'Tamil', 'Muslim', 'Burgher', 'Other'],
                (value) => setState(() => _selectedEthnicity = value),
              ),
              _buildDropdownField(
                'Religion',
                _selectedReligion,
                ['Buddhist', 'Hindu', 'Catholic', 'Christian', 'Muslim', 'Other'],
                (value) => setState(() => _selectedReligion = value),
              ),
              _buildDropdownField(
                'Caste',
                _selectedCaste,
                ['Govigama', 'Karava', 'Salagama', 'Durava', 'Vellalar', 'Other'],
                (value) => setState(() => _selectedCaste = value),
              ),
              _buildTextField(_languagesController, 'Languages (comma separated)', Icons.language),

              const SizedBox(height: 24),

              // Physical Appearance
              _buildSectionTitle('Physical Appearance'),
              _buildNumberField('Height (cm)', _heightCm, (value) => _heightCm = value),
              _buildNumberField('Weight (kg)', _weightKg, (value) => _weightKg = value),
              _buildDropdownField(
                'Body Type',
                _selectedBodyType,
                ['Slim', 'Athletic', 'Average', 'Curvy', 'Plus-size'],
                (value) => setState(() => _selectedBodyType = value),
              ),
              _buildDropdownField(
                'Complexion',
                _selectedComplexion,
                ['Fair', 'Wheatish', 'Medium', 'Dark'],
                (value) => setState(() => _selectedComplexion = value),
              ),

              const SizedBox(height: 24),

              // Lifestyle
              _buildSectionTitle('Lifestyle'),
              _buildDropdownField(
                'Dietary Preference',
                _selectedDietaryPreference,
                ['Vegetarian', 'Non-Vegetarian', 'Vegan'],
                (value) => setState(() => _selectedDietaryPreference = value),
              ),
              _buildDropdownField(
                'Drinking',
                _selectedDrinking,
                ['Never', 'Socially', 'Occasionally'],
                (value) => setState(() => _selectedDrinking = value),
              ),
              _buildDropdownField(
                'Smoking',
                _selectedSmoking,
                ['Never', 'Occasionally', 'Regularly'],
                (value) => setState(() => _selectedSmoking = value),
              ),
              _buildTextField(_hobbiesController, 'Hobbies (comma separated)', Icons.sports_soccer),
              _buildDropdownField(
                'Personality Type',
                _selectedPersonalityType,
                ['Introvert', 'Extrovert', 'Ambivert'],
                (value) => setState(() => _selectedPersonalityType = value),
              ),

              const SizedBox(height: 24),

              // Ideal Partner
              _buildSectionTitle('Ideal Partner'),
              _buildTextField(_idealPartnerController, 'My Ideal Partner', Icons.favorite, maxLines: 4),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        maxLines: maxLines,
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? selectedDate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _selectDateOfBirth,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedDate)
                : 'Select date',
            style: TextStyle(
              color: selectedDate != null ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    int? value,
    ValueChanged<int?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value?.toString(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          onChanged(value.isEmpty ? null : int.tryParse(value));
        },
      ),
    );
  }
}

