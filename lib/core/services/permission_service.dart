import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  bool _notificationPermissionGranted = false;
  bool _storagePermissionGranted = false;

  bool get notificationPermissionGranted => _notificationPermissionGranted;
  bool get storagePermissionGranted => _storagePermissionGranted;

  Future<bool> requestNotificationPermission(BuildContext context) async {
    if (_notificationPermissionGranted) return true;

    final status = await Permission.notification.status;
    if (status.isGranted) {
      _notificationPermissionGranted = true;
      return true;
    }

    final result = await Permission.notification.request();
    
    if (result.isGranted) {
      _notificationPermissionGranted = true;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification Permission Granted! You will receive live updates.'),
            backgroundColor: Color(0xFF6C5CE7),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } else if (result.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notifications are disabled. Please enable them in system settings.'),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
    return false;
  }

  Future<bool> requestStoragePermission(BuildContext context) async {
    if (_storagePermissionGranted) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141927),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0x3300CFFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.folder_special_rounded, color: Color(0xFF00CFFF), size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Storage Access Required',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ether Cinema requires device storage access to download and encrypt 4K video payloads for offline viewing.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            _buildPermissionFeature(Icons.lock_rounded, 'Encrypted AES-256 local storage'),
            _buildPermissionFeature(Icons.wifi_off_rounded, 'Full offline video playback support'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00CFFF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Grant Access', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result == true) {
      _storagePermissionGranted = true;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage Permission Granted! Download initiated.'),
            backgroundColor: Color(0xFF00CFFF),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage Permission Denied. Cannot save offline download.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
  }

  static Widget _buildPermissionFeature(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
