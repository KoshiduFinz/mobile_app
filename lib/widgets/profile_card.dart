import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfileCard extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onLike;
  final VoidCallback onReject;
  final VoidCallback onMessage;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.onLike,
    required this.onReject,
    required this.onMessage,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Animation<Offset>? _slideAnimation;
  bool _isAnimating = false;
  Offset _slideDirection = const Offset(1.5, 0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _updateSlideAnimation();
  }

  void _updateSlideAnimation() {
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _slideDirection,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleAction(String action) {
    if (_isAnimating) return;

    // Determine slide direction based on action
    _slideDirection = action == 'like' 
        ? const Offset(-1.5, 0)  // Slide left for like
        : const Offset(1.5, 0);   // Slide right for reject
    
    _updateSlideAnimation();
    _animationController.reset();

    setState(() {
      _isAnimating = true;
    });

    _animationController.forward().then((_) {
      // Small delay to ensure animation is fully visible before calling callback
      Future.delayed(const Duration(milliseconds: 100), () {
        // Call the callback after animation completes
        if (action == 'like') {
          widget.onLike();
        } else if (action == 'reject') {
          widget.onReject();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always show the card, but apply animation if animating
    final card = _buildCard();
    
    if (_isAnimating && _slideAnimation != null) {
      return SlideTransition(
        position: _slideAnimation!,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
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
                          widget.profile.displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.profile.age != null)
                        Text(
                          '${widget.profile.age}',
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
                        widget.profile.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (widget.profile.profession != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.work, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          widget.profile.profession!,
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
              content: widget.profile.bio ?? 'No bio available',
            ),

            // My Ideal Partner Section
            if (widget.profile.idealPartnerDescription != null)
              _buildSection(
                title: 'My Ideal Partner',
                content: widget.profile.idealPartnerDescription!,
              ),

            // Additional Details
            _buildDetailsSection(),

            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.grey[200],
      ),
      child: widget.profile.avatarUrl != null
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                widget.profile.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
              ),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
        child: Icon(
          Icons.person,
          size: 100,
          color: Colors.grey[400],
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
              if (widget.profile.maritalStatus != null)
                _buildDetailChip('Marital Status', widget.profile.maritalStatus!),
              if (widget.profile.religion != null)
                _buildDetailChip('Religion', widget.profile.religion!),
              if (widget.profile.ethnicity != null)
                _buildDetailChip('Ethnicity', widget.profile.ethnicity!),
              if (widget.profile.caste != null)
                _buildDetailChip('Caste', widget.profile.caste!),
              if (widget.profile.heightCm != null)
                _buildDetailChip('Height', '${widget.profile.heightCm} cm'),
              if (widget.profile.bodyType != null)
                _buildDetailChip('Body Type', widget.profile.bodyType!),
              if (widget.profile.complexion != null)
                _buildDetailChip('Complexion', widget.profile.complexion!),
              if (widget.profile.highestEducation != null)
                _buildDetailChip('Education', widget.profile.highestEducation!),
              if (widget.profile.dietaryPreference != null)
                _buildDetailChip('Diet', widget.profile.dietaryPreference!),
              if (widget.profile.drinking != null)
                _buildDetailChip('Drinking', widget.profile.drinking!),
              if (widget.profile.smoking != null)
                _buildDetailChip('Smoking', widget.profile.smoking!),
              if (widget.profile.personalityType != null)
                _buildDetailChip('Personality', widget.profile.personalityType!),
            ],
          ),
          if (widget.profile.hobbies != null && widget.profile.hobbies!.isNotEmpty) ...[
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
              children: widget.profile.hobbies!
                  .map((hobby) => Chip(
                        label: Text(hobby),
                        backgroundColor: Colors.blue[50],
                      ))
                  .toList(),
            ),
          ],
          if (widget.profile.spokenLanguages != null &&
              widget.profile.spokenLanguages!.isNotEmpty) ...[
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
              children: widget.profile.spokenLanguages!
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reject Button
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            onPressed: () => _handleAction('reject'),
          ),
          // Message Button
          _buildActionButton(
            icon: Icons.message,
            color: Colors.blue,
            onPressed: widget.onMessage,
          ),
          // Like Button
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.green,
            onPressed: () => _handleAction('like'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        iconSize: 32,
        onPressed: onPressed,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}

