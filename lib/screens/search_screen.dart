import 'package:flutter/material.dart';
import '../models/interest_tag.dart';
import '../models/mock_interests.dart';
import '../constants/app_constants.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  
  const SearchScreen({super.key, this.onMenuTap});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<InterestTag> _myInterests = [];
  List<InterestTag> _otherInterests = [];

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  void _loadInterests() {
    setState(() {
      _myInterests = MockInterests.getMyInterests();
      _otherInterests = MockInterests.getOtherInterests();
    });
  }

  void _toggleInterest(InterestTag interest) {
    setState(() {
      if (interest.isSelected) {
        // Remove from my interests, add to other interests
        _myInterests.removeWhere((tag) => tag.id == interest.id);
        _otherInterests.add(interest.copyWith(isSelected: false));
      } else {
        // Add to my interests, remove from other interests
        _otherInterests.removeWhere((tag) => tag.id == interest.id);
        _myInterests.add(interest.copyWith(isSelected: true));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: widget.onMenuTap,
        ),
        title: const Text('Search', style: TextStyle(color: Colors.white)),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppConstants.gradientRoyal,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Interests Section
                  if (_myInterests.isNotEmpty) ...[
                    const Text(
                      'My Interests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _myInterests.map((interest) {
                        return _buildInterestChip(
                          interest,
                          isSelected: true,
                          showSouls: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Other Interests Section
                  const Text(
                    'Other Interests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._otherInterests.map((interest) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildOtherInterestRow(interest),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(
    InterestTag interest, {
    required bool isSelected,
    required bool showSouls,
  }) {
    return GestureDetector(
      onTap: () => _toggleInterest(interest),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              interest.name,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (showSouls && interest.soulsCount > 0) ...[
              const SizedBox(width: 8),
              Text(
                '${MockInterests.formatSoulsCount(interest.soulsCount)} souls',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOtherInterestRow(InterestTag interest) {
    return GestureDetector(
      onTap: () => _toggleInterest(interest),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              interest.name,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              '${MockInterests.formatSoulsCount(interest.soulsCount)} souls',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

