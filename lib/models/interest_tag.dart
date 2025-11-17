class InterestTag {
  final String id;
  final String name;
  final int soulsCount;
  final bool isSelected;

  InterestTag({
    required this.id,
    required this.name,
    required this.soulsCount,
    this.isSelected = false,
  });

  InterestTag copyWith({
    String? id,
    String? name,
    int? soulsCount,
    bool? isSelected,
  }) {
    return InterestTag(
      id: id ?? this.id,
      name: name ?? this.name,
      soulsCount: soulsCount ?? this.soulsCount,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

