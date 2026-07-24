import 'package:flutter/material.dart';
import '../../core/downloads/encrypted_download_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class DownloadsScreen extends StatefulWidget {
  final VoidCallback? onExploreCatalog;

  const DownloadsScreen({
    super.key,
    this.onExploreCatalog,
  });

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final EncryptedDownloadManager _manager = EncryptedDownloadManager();
  String _selectedFilter = 'ALL';

  final List<String> _filters = const ['ALL', 'DOWNLOADING', 'COMPLETED', 'FAILED'];


  String _formatBytes(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } else {
      return '${(bytes / 1048576).toStringAsFixed(0)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF0F121C);

    return Scaffold(
      backgroundColor: bgDark,
      body: StreamBuilder<List<DownloadTask>>(
        stream: EncryptedDownloadManager.tasksStream,
        initialData: EncryptedDownloadManager.activeQueue,
        builder: (context, snapshot) {
          final allTasks = snapshot.data ?? EncryptedDownloadManager.activeQueue;

          // Apply tab filter
          final filteredTasks = allTasks.where((t) {
            if (_selectedFilter == 'DOWNLOADING') {
              return t.status == DownloadStatus.downloading || t.status == DownloadStatus.paused;
            } else if (_selectedFilter == 'COMPLETED') {
              return t.status == DownloadStatus.completed;
            } else if (_selectedFilter == 'FAILED') {
              return t.status == DownloadStatus.failed;
            }
            return true;
          }).toList();



          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Offline Downloads',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Downloaded movies and episodes for offline viewing',
                        style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),



                      // Filter Pills
                      SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(filter),
                                selected: isSelected,
                                selectedColor: const Color(0xFF6C5CE7),
                                backgroundColor: const Color(0xFF191F30),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 11,
                                ),
                                onSelected: (_) {
                                  setState(() => _selectedFilter = filter);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Downloads List or Empty State
              filteredTasks.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                        child: GlassContainer(
                          borderRadius: 24,
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C5CE7).withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.download_done_rounded,
                                  size: 48,
                                  color: Color(0xFF6C5CE7),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Downloads Found',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedFilter == 'ALL'
                                    ? 'Downloaded movies and episodes will appear here for offline viewing.'
                                    : 'No items in the $_selectedFilter category.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white60, fontSize: 13),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: widget.onExploreCatalog,
                                icon: const Icon(Icons.explore_rounded, size: 18),
                                label: const Text('Explore Catalog'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C5CE7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = filteredTasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassContainer(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Poster Thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        task.posterUrl,
                                        width: 60,
                                        height: 85,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 60,
                                          height: 85,
                                          color: Colors.white10,
                                          child: const Icon(Icons.movie, color: Colors.white38),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Content Meta
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white10,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  task.qualityLabel,
                                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${_formatBytes(task.downloadedBytes)} / ${_formatBytes(task.fileSizeBytes)}',
                                                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),

                                          // Download Progress bar
                                          if (task.status == DownloadStatus.downloading || task.status == DownloadStatus.paused) ...[
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: task.progress,
                                                backgroundColor: Colors.white10,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  task.status == DownloadStatus.paused ? Colors.orangeAccent : const Color(0xFF6C5CE7),
                                                ),
                                                minHeight: 4,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              task.status == DownloadStatus.paused
                                                  ? 'Paused • ${(task.progress * 100).toInt()}%'
                                                  : 'Downloading • ${(task.progress * 100).toInt()}% (14.2 MB/s)',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: task.status == DownloadStatus.paused ? Colors.orangeAccent : const Color(0xFF6C5CE7),
                                              ),
                                            ),
                                          ] else if (task.status == DownloadStatus.completed) ...[
                                            const Row(
                                              children: [
                                                Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 14),
                                                SizedBox(width: 4),
                                                Text('Ready for Offline Play', style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
                                              ],
                                            ),
                                          ] else ...[
                                            const Row(
                                              children: [
                                                Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 14),
                                                SizedBox(width: 4),
                                                Text('Download Interrupted', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Interactive Task Action Button
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                                      color: const Color(0xFF191F30),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      onSelected: (action) {
                                        if (action == 'pause') {
                                          EncryptedDownloadManager.pauseDownload(task.id);
                                        } else if (action == 'resume') {
                                          EncryptedDownloadManager.resumeDownload(task.id);
                                        } else if (action == 'retry') {
                                          EncryptedDownloadManager.retryDownload(task.id);
                                        } else if (action == 'delete') {
                                          EncryptedDownloadManager.deleteDownload(task.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        if (task.status == DownloadStatus.downloading)
                                          const PopupMenuItem(
                                            value: 'pause',
                                            child: Row(
                                              children: [
                                                Icon(Icons.pause_circle_outline, color: Colors.orangeAccent, size: 18),
                                                SizedBox(width: 8),
                                                Text('Pause Download', style: TextStyle(color: Colors.white, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        if (task.status == DownloadStatus.paused)
                                          const PopupMenuItem(
                                            value: 'resume',
                                            child: Row(
                                              children: [
                                                Icon(Icons.play_circle_outline, color: Color(0xFF6C5CE7), size: 18),
                                                SizedBox(width: 8),
                                                Text('Resume Download', style: TextStyle(color: Colors.white, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        if (task.status == DownloadStatus.failed)
                                          const PopupMenuItem(
                                            value: 'retry',
                                            child: Row(
                                              children: [
                                                Icon(Icons.refresh_rounded, color: Colors.greenAccent, size: 18),
                                                SizedBox(width: 8),
                                                Text('Retry Download', style: TextStyle(color: Colors.white, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                              SizedBox(width: 8),
                                              Text('Delete File', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: filteredTasks.length,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}
