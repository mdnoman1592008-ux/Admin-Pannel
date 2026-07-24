import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final String accentColorHex;
  final int displayOrder;
  final bool isVisible;

  const CategoryItem({
    required this.id,
    required this.name,
    this.icon = Icons.movie_filter_rounded,
    this.accentColorHex = '#00CFFF',
    this.displayOrder = 0,
    this.isVisible = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'accentColorHex': accentColorHex,
      'displayOrder': displayOrder,
      'isVisible': isVisible,
    };
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map, String id) {
    return CategoryItem(
      id: id,
      name: map['name'] ?? '',
      accentColorHex: map['accentColorHex'] ?? '#00CFFF',
      displayOrder: map['displayOrder'] ?? 0,
      isVisible: map['isVisible'] ?? true,
    );
  }
}
