import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';
import '../../core/widgets/status_badge.dart';

/// Banners Screen — Visual Hero Banner Editor with device preview
class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  int _selectedBanner = 0;
  _PreviewMode _previewMode = _PreviewMode.desktop;

  final _banners = const [
    _Banner('Interstellar — Explore Beyond', 'Sci-Fi Epic', '#050608', '#00D8FF', true),
    _Banner('The Dark Knight Returns', 'Action Thriller', '#0D0D0D', '#7B61FF', false),
    _Banner('Dune Part 2 — The Awakening', 'Epic Fantasy', '#0A0806', '#FFD86A', true),
    _Banner('Wednesday — Season 2', 'Dark Comedy', '#050505', '#00FFC8', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner list
          SizedBox(width: 300, child: _buildBannerList()),
          const SizedBox(width: 16),
          // Editor + Preview
          Expanded(child: _buildEditor()),
        ],
      ),
    );
  }

  Widget _buildBannerList() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Hero Banners', style: AppTextStyles.h3()),
                const Spacer(),
                GlowButton(
                  label: 'New',
                  icon: Icons.add_rounded,
                  color: AppColors.primary,
                  isSmall: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.glassBorder),
          Expanded(
            child: ListView.separated(
              itemCount: _banners.length,
              separatorBuilder: (_, __) =>
                  Container(height: 1, color: AppColors.glassBorder.withOpacity(0.5)),
              itemBuilder: (_, i) {
                final b = _banners[i];
                final isSelected = _selectedBanner == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBanner = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(14),
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.transparent,
                    child: Row(
                      children: [
                        // Mini preview
                        Container(
                          width: 56,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(int.parse(b.color1.replaceFirst('#', 'FF'), radix: 16)),
                                Color(int.parse(b.color2.replaceFirst('#', 'FF'), radix: 16)).withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.5)
                                  : AppColors.glassBorder,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.title,
                                  style: AppTextStyles.h4().copyWith(fontSize: 11),
                                  overflow: TextOverflow.ellipsis),
                              Text(b.subtitle,
                                  style: AppTextStyles.bodySm().copyWith(fontSize: 10)),
                            ],
                          ),
                        ),
                        if (b.isActive) StatusBadge.published(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    final banner = _banners[_selectedBanner];
    return Column(
      children: [
        // Device preview switcher
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text('Preview Mode', style: AppTextStyles.h4()),
              const SizedBox(width: 16),
              _PreviewModeBtn(
                label: '🖥 Desktop',
                selected: _previewMode == _PreviewMode.desktop,
                onTap: () => setState(() => _previewMode = _PreviewMode.desktop),
              ),
              const SizedBox(width: 8),
              _PreviewModeBtn(
                label: '📱 Tablet',
                selected: _previewMode == _PreviewMode.tablet,
                onTap: () => setState(() => _previewMode = _PreviewMode.tablet),
              ),
              const SizedBox(width: 8),
              _PreviewModeBtn(
                label: '📱 Mobile',
                selected: _previewMode == _PreviewMode.mobile,
                onTap: () => setState(() => _previewMode = _PreviewMode.mobile),
              ),
              const Spacer(),
              GlowButton(
                label: 'Upload Image',
                icon: Icons.upload_rounded,
                color: AppColors.primary,
                isSmall: true,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              GlowButton(
                label: 'Save',
                icon: Icons.save_rounded,
                color: AppColors.success,
                textColor: Colors.black,
                isSmall: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Banner preview
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live Preview', style: AppTextStyles.h3()),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      width: _previewMode == _PreviewMode.desktop
                          ? double.infinity
                          : _previewMode == _PreviewMode.tablet
                              ? 600
                              : 320,
                      height: _previewMode == _PreviewMode.mobile ? 180 : 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF050608),
                            AppColors.secondary.withOpacity(0.4),
                            AppColors.primary.withOpacity(0.2),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StatusBadge.featured(),
                          const SizedBox(height: 10),
                          Text(banner.title,
                              style: AppTextStyles.h1().copyWith(
                                fontSize: _previewMode == _PreviewMode.mobile ? 18 : 28,
                              )),
                          const SizedBox(height: 6),
                          Text(banner.subtitle,
                              style: AppTextStyles.bodyLg().copyWith(
                                  color: AppColors.textSecond,
                                  fontSize: 14)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Watch Now',
                                    style: AppTextStyles.h4().copyWith(
                                        fontSize: 12, color: Colors.black)),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.glass,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.glassBorder),
                                ),
                                child: Text('More Info',
                                    style: AppTextStyles.h4()
                                        .copyWith(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _PreviewMode { desktop, tablet, mobile }

class _Banner {
  const _Banner(
      this.title, this.subtitle, this.color1, this.color2, this.isActive);
  final String title, subtitle, color1, color2;
  final bool isActive;
}

class _PreviewModeBtn extends StatelessWidget {
  const _PreviewModeBtn(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.glass,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.glassBorder,
          ),
        ),
        child: Text(label,
            style: AppTextStyles.badge().copyWith(
                color: selected ? AppColors.primary : AppColors.textSecond,
                fontSize: 11)),
      ),
    );
  }
}
