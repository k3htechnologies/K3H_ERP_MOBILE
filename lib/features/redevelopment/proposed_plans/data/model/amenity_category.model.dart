class AmenitySubCategory {
  final String name;
  bool isSelected;

  AmenitySubCategory({
    required this.name,
    this.isSelected = false,
  });
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
}
