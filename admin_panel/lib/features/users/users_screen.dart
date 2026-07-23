import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';
import '../../core/widgets/status_badge.dart';

/// Users Screen — Enterprise user management table
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _search = '';
  int _hoveredRow = -1;

  final _users = [
    _User('Ariana Mitchell', 'ariana@example.com', 'super_admin', 'google', 'active', 'US', '2024-01-12', 'iPhone 15'),
    _User('James Rodriguez', 'james@example.com', 'user', 'facebook', 'active', 'ES', '2024-02-08', 'Android 14'),
    _User('Yuki Tanaka', 'yuki@example.com', 'admin', 'email', 'active', 'JP', '2024-03-15', 'iPad Pro'),
    _User('Sofia Klein', 'sofia@example.com', 'user', 'google', 'suspended', 'DE', '2024-04-22', 'Samsung S24'),
    _User('Omar Hassan', 'omar@example.com', 'user', 'email', 'active', 'AE', '2024-05-10', 'iPhone 14'),
    _User('Chen Wei', 'chen@example.com', 'user', 'facebook', 'active', 'CN', '2024-06-01', 'Pixel 8'),
    _User('Emma Dubois', 'emma@example.com', 'admin', 'google', 'active', 'FR', '2024-06-18', 'MacBook'),
    _User('Raj Patel', 'raj@example.com', 'user', 'email', 'inactive', 'IN', '2024-07-05', 'OnePlus 12'),
    _User('Layla Al-Farsi', 'layla@example.com', 'user', 'facebook', 'active', 'SA', '2024-07-14', 'iPhone 15 Pro'),
    _User('Marco Rossi', 'marco@example.com', 'user', 'google', 'active', 'IT', '2024-07-20', 'Galaxy Tab'),
  ];

  List<_User> get _filtered => _users
      .where((u) =>
          u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.email.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildToolbar(),
          const SizedBox(height: 16),
          _buildStats(),
          const SizedBox(height: 16),
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: AppTextStyles.body().copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: AppTextStyles.body()
                    .copyWith(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 16, color: AppColors.textMuted),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ProviderFilter('All'),
          const SizedBox(width: 6),
          _ProviderFilter('Google'),
          const SizedBox(width: 6),
          _ProviderFilter('Facebook'),
          const SizedBox(width: 6),
          _ProviderFilter('Email'),
          const Spacer(),
          GlowButton(
            label: 'Export CSV',
            icon: Icons.download_rounded,
            color: AppColors.accent,
            textColor: Colors.black,
            isSmall: true,
            outlined: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = [
      ('Total Users', '94,721', AppColors.primary),
      ('Active', '88,450', AppColors.success),
      ('Suspended', '412', AppColors.danger),
      ('Inactive', '5,859', AppColors.textMuted),
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              borderColor: s.$3.withOpacity(0.15),
              glowColor: s.$3,
              glowBlur: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$1,
                      style: AppTextStyles.labelLg()),
                  const SizedBox(height: 4),
                  Text(s.$2,
                      style: AppTextStyles.h2().copyWith(color: s.$3)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTable() {
    final filtered = _filtered;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildHeader(),
          Container(height: 1, color: AppColors.glassBorder),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  Container(height: 1, color: AppColors.glassBorder.withOpacity(0.5)),
              itemBuilder: (_, i) => _buildUserRow(filtered[i], i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 52),
          Expanded(flex: 3, child: Text('USER', style: AppTextStyles.tableHeader())),
          Expanded(flex: 2, child: Text('ROLE', style: AppTextStyles.tableHeader())),
          Expanded(flex: 2, child: Text('PROVIDER', style: AppTextStyles.tableHeader())),
          Expanded(flex: 1, child: Text('COUNTRY', style: AppTextStyles.tableHeader())),
          Expanded(flex: 2, child: Text('STATUS', style: AppTextStyles.tableHeader())),
          Expanded(flex: 2, child: Text('LAST LOGIN', style: AppTextStyles.tableHeader())),
          SizedBox(width: 80, child: Text('ACTIONS', style: AppTextStyles.tableHeader())),
        ],
      ),
    );
  }

  Widget _buildUserRow(_User user, int index) {
    final isHovered = _hoveredRow == index;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRow = index),
      onExit: (_) => setState(() => _hoveredRow = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: isHovered ? AppColors.glass : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _avatarColor(user.name),
                    _avatarColor(user.name).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  user.name[0].toUpperCase(),
                  style: AppTextStyles.h4().copyWith(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: AppTextStyles.tableCell().copyWith(fontWeight: FontWeight.w600)),
                  Text(user.email, style: AppTextStyles.bodySm()),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: user.role == 'super_admin'
                  ? StatusBadge.superAdmin()
                  : user.role == 'admin'
                      ? StatusBadge.admin()
                      : StatusBadge.user(),
            ),
            Expanded(
              flex: 2,
              child: user.provider == 'google'
                  ? StatusBadge.google()
                  : user.provider == 'facebook'
                      ? StatusBadge.facebook()
                      : StatusBadge.email(),
            ),
            Expanded(
              flex: 1,
              child: Text(user.country,
                  style: AppTextStyles.tableCell()),
            ),
            Expanded(
              flex: 2,
              child: _StatusChip(status: user.status),
            ),
            Expanded(
              flex: 2,
              child: Text(user.lastLogin,
                  style: AppTextStyles.tableCell()
                      .copyWith(color: AppColors.textSecond, fontSize: 12)),
            ),
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  _SmallActionBtn(
                      icon: Icons.visibility_rounded, color: AppColors.primary),
                  const SizedBox(width: 4),
                  _SmallActionBtn(
                      icon: Icons.block_rounded, color: AppColors.danger),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _avatarColor(String name) {
    final colors = [
      AppColors.primary, AppColors.secondary, AppColors.accent,
      AppColors.gold, AppColors.success, AppColors.warning,
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}

class _User {
  const _User(this.name, this.email, this.role, this.provider, this.status,
      this.country, this.lastLogin, this.device);
  final String name, email, role, provider, status, country, lastLogin, device;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = status == 'active'
        ? AppColors.success
        : status == 'suspended'
            ? AppColors.danger
            : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(status.capitalize(),
              style: AppTextStyles.badge()
                  .copyWith(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ProviderFilter extends StatelessWidget {
  const _ProviderFilter(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(label, style: AppTextStyles.badge().copyWith(fontSize: 11, color: AppColors.textSecond)),
    );
  }
}

class _SmallActionBtn extends StatelessWidget {
  const _SmallActionBtn({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

extension _StringExt on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
