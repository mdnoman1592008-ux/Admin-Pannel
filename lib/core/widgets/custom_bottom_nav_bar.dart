import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  static const _items = <_NavItem>[
    _NavItem(Icons.home_rounded, 'Home'),
    _NavItem(Icons.grid_view_rounded, 'Categories'),
    _NavItem(Icons.download_for_offline_rounded, 'Downloads'),
    _NavItem(Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xEE32115F), Color(0xEE170B39)],
                ),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: Colors.white.withOpacity(.24)),
                boxShadow: const [
                  BoxShadow(color: Color(0x99000000), blurRadius: 26, offset: Offset(0, 12)),
                  BoxShadow(color: Color(0x556C35C9), blurRadius: 24, spreadRadius: -4),
                ],
              ),
              child: Row(
                children: List.generate(_items.length, (index) {
                  final selected = index == currentIndex;
                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: _items[index].label,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: selected
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(27),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF00D9FF), Color(0xFF2476FF)],
                                  ),
                                  border: Border.all(color: Colors.white.withOpacity(.55)),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x9900CFFF), blurRadius: 16, offset: Offset(0, 5)),
                                    BoxShadow(color: Color(0x772D1169), blurRadius: 0, offset: Offset(0, 4)),
                                  ],
                                )
                              : null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedScale(
                                scale: selected ? 1.08 : 1,
                                duration: const Duration(milliseconds: 220),
                                child: Icon(_items[index].icon, size: selected ? 25 : 23,
                                    color: selected ? Colors.white : Colors.white.withOpacity(.62)),
                              ),
                              const SizedBox(height: 3),
                              Text(_items[index].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 10, letterSpacing: .15,
                                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                                      color: selected ? Colors.white : Colors.white.withOpacity(.62))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
