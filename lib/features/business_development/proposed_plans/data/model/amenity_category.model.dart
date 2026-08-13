class AmenitySubCategory {
  final String name;
  bool isSelected;

  AmenitySubCategory({required this.name, this.isSelected = false});

  AmenitySubCategory copyWith({String? name, bool? isSelected}) {
    return AmenitySubCategory(
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class AmenityCategory {
  final String title;
  final List<AmenitySubCategory> subCategories;
  bool isExpanded;

  AmenityCategory({
    required this.title,
    required this.subCategories,
    this.isExpanded = false,
  });

  AmenityCategory copyWith({
    String? title,
    List<AmenitySubCategory>? subCategories,
    bool? isExpanded,
  }) {
    return AmenityCategory(
      title: title ?? this.title,
      subCategories: subCategories ?? this.subCategories,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
