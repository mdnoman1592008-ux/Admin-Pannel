import 'dart:ui';
import 'package:flutter/material.dart';
import '../backend/backend_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Premium Top Bar — Ether Cinema Admin Panel
/// Layout: Title/Logo -> Spacer -> Live Search (🔍) -> System Health -> Live FCM Notification Drawer (🔔)
class TopBar extends StatefulWidget {
  const TopBar({
    super.key,
    required this.pageTitle,
    required this.pageSubtitle,
    this.actions,
  });

  final String pageTitle;
  final String pageSubtitle;
  final List<Widget>? actions;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final _backend = LiveBackendService.instance;

  void _openLiveSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => const _LiveSearchOverlayDialog(),
    );
  }

  void _openNotificationDrawer() {
    showDialog(
      context: context,
      builder: (context) => const _LiveNotificationDrawerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _backend,
      builder: (context, _) {
        final notifCount = _backend.notifications.length;

        final compact = MediaQuery.sizeOf(context).width < 700;
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.glass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  if (compact)
                    IconButton(
                      tooltip: 'Open navigation',
                      icon: const Icon(Icons.menu_rounded,
                          color: AppColors.primary),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  // Logo & Page title
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.play_circle_fill_rounded,
                            color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.pageTitle, style: AppTextStyles.h3()),
                          if (!compact) Text(widget.pageSubtitle,
                              style: AppTextStyles.bodySm().copyWith(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Live Search Button (🔍)
                  IconButton(
                    tooltip: 'Open Live Firestore Search (⌘K)',
                    icon: const Icon(Icons.search_rounded,
                        color: AppColors.primary, size: 22),
                    onPressed: _openLiveSearchDialog,
                  ),
                  if (!compact) const SizedBox(width: 12),
                  // System Health Indicator
                  if (!compact) const _SystemHealthIndicator(),
                  if (!compact) const SizedBox(width: 16),
                  // Live Notification Bell (🔔)
                  _NotificationButton(
                    count: notifCount,
                    onTap: _openNotificationDrawer,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SystemHealthIndicator extends StatelessWidget {
  const _SystemHealthIndicator();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Firebase: OK | Supabase: OK | FCM: OK',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.success.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                boxShadow: [AppColors.glowMint(blur: 8, opacity: 0.8)],
              ),
            ),
            const SizedBox(width: 6),
            Text('All Systems',
                style: AppTextStyles.labelLg().copyWith(
                    color: AppColors.success, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.glass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withOpacity(0.5),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: AppTextStyles.badge().copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fullscreen Live Search Overlay Dialog
class _LiveSearchOverlayDialog extends StatefulWidget {
  const _LiveSearchOverlayDialog();

  @override
  State<_LiveSearchOverlayDialog> createState() => _LiveSearchOverlayDialogState();
}

class _LiveSearchOverlayDialogState extends State<_LiveSearchOverlayDialog> {
  final _backend = LiveBackendService.instance;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final movies = _backend.movies
        .where((m) => m.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: 760,
            height: 520,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        style: AppTextStyles.h3(),
                        decoration: InputDecoration(
                          hintText: 'Live search movies, series & categories in Firestore...',
                          hintStyle: AppTextStyles.body().copyWith(color: AppColors.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Container(height: 1, color: AppColors.glassBorder),
                const SizedBox(height: 16),
                if (_query.isEmpty) ...[
                  Text('Trending Searches', style: AppTextStyles.labelLg()),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Nebula Drift 4K', 'Sci-Fi Epic', 'The Dark Knight', 'Dune Part 2', 'Action Thriller']
                        .map((term) => ActionChip(
                              label: Text(term, style: AppTextStyles.bodySm()),
                              backgroundColor: AppColors.surfaceCard,
                              side: const BorderSide(color: AppColors.glassBorder),
                              onPressed: () => setState(() => _query = term),
                            ))
                        .toList(),
                  ),
                ] else if (movies.isEmpty) ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 44),
                          const SizedBox(height: 12),
                          Text('No results found for "$_query"', style: AppTextStyles.h4()),
                          const SizedBox(height: 4),
                          Text('Try searching for titles or categories in Firestore', style: AppTextStyles.bodySm()),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ListView.separated(
                      itemCount: movies.length,
                      separatorBuilder: (_, __) => Container(height: 1, color: AppColors.glassBorder),
                      itemBuilder: (_, i) {
                        final movie = movies[i];
                        return ListTile(
                          leading: Container(
                            width: 36,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.movie_rounded, color: Colors.black, size: 18),
                          ),
                          title: Text(movie.title, style: AppTextStyles.h4()),
                          subtitle: Text('${movie.category} • ${movie.year}', style: AppTextStyles.bodySm()),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                          onTap: () => Navigator.pop(context),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Live FCM Notification Drawer Dialog
class _LiveNotificationDrawerDialog extends StatelessWidget {
  const _LiveNotificationDrawerDialog();

  @override
  Widget build(BuildContext context) {
    final backend = LiveBackendService.instance;
    final notifs = backend.notifications;

    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.topRight,
      insetPadding: const EdgeInsets.only(top: 80, right: 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: 380,
            height: 460,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Text('Live FCM Notifications', style: AppTextStyles.h3()),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Container(height: 1, color: AppColors.glassBorder),
                const SizedBox(height: 12),
                if (notifs.isEmpty) ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.notifications_off_rounded, color: AppColors.textMuted, size: 40),
                          const SizedBox(height: 12),
                          Text('No Active Notifications', style: AppTextStyles.h4()),
                          const SizedBox(height: 4),
                          Text('Broadcast notifications from FCM Notification Center', style: AppTextStyles.bodySm(), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ListView.separated(
                      itemCount: notifs.length,
                      separatorBuilder: (_, __) => Container(height: 1, color: AppColors.glassBorder),
                      itemBuilder: (_, i) {
                        final n = notifs[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title, style: AppTextStyles.h4().copyWith(fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(n.body, style: AppTextStyles.bodySm()),
                              const SizedBox(height: 4),
                              Text('Sent to ${n.target} • ${n.sentAt.toIso8601String().substring(0, 10)}', style: AppTextStyles.monoSm().copyWith(fontSize: 10)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
