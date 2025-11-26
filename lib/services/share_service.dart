import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareService {
  /// Share image to general platforms (WhatsApp, etc.)
  static Future<void> shareImage(
    File imageFile, {
    String? text,
    String? subject,
  }) async {
    try {
      final xFile = XFile(imageFile.path);
      await Share.shareXFiles(
        [xFile],
        text: text ?? 'Check out my StyleSnap outfit! ✨',
        subject: subject,
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  /// Share to Instagram Stories
  static Future<void> shareToInstagramStory(File imageFile) async {
    try {
      // Instagram Stories sharing requires native implementation
      // Using URL scheme approach
      final uri = Uri.parse('instagram-stories://share');

      if (await canLaunchUrl(uri)) {
        // For production, you'd need platform-specific code
        // to actually pass the image to Instagram
        await launchUrl(uri);
      } else {
        // Fallback to general share
        await shareImage(imageFile, text: 'Shared from StyleSnap 📸');
      }
    } catch (e) {
      debugPrint('Error sharing to Instagram: $e');
      // Fallback to general share
      await shareImage(imageFile);
    }
  }

  /// Share to Instagram Feed
  static Future<void> shareToInstagramFeed(File imageFile) async {
    try {
      final uri = Uri.parse('instagram://');

      if (await canLaunchUrl(uri)) {
        // Open Instagram app
        await launchUrl(uri);
        // User will manually share from their gallery
      } else {
        await shareImage(imageFile);
      }
    } catch (e) {
      debugPrint('Error opening Instagram: $e');
      await shareImage(imageFile);
    }
  }

  /// Share to TikTok
  static Future<void> shareToTikTok(File imageFile) async {
    try {
      // TikTok URL scheme
      final uri = Uri.parse('snssdk1233://');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await shareImage(imageFile);
      }
    } catch (e) {
      debugPrint('Error opening TikTok: $e');
      await shareImage(imageFile);
    }
  }

  /// Show share options dialog
  static Future<void> showShareDialog(
    BuildContext context,
    File imageFile,
  ) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Share Your Outfit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Share options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.camera_alt,
                  label: 'Instagram\nStory',
                  color: const Color(0xFFE4405F),
                  onTap: () {
                    Navigator.pop(context);
                    shareToInstagramStory(imageFile);
                  },
                ),
                _ShareOption(
                  icon: Icons.photo_library,
                  label: 'Instagram\nFeed',
                  color: const Color(0xFFC13584),
                  onTap: () {
                    Navigator.pop(context);
                    shareToInstagramFeed(imageFile);
                  },
                ),
                _ShareOption(
                  icon: Icons.music_note,
                  label: 'TikTok',
                  color: Colors.black,
                  onTap: () {
                    Navigator.pop(context);
                    shareToTikTok(imageFile);
                  },
                ),
                _ShareOption(
                  icon: Icons.more_horiz,
                  label: 'More',
                  color: Colors.grey[700]!,
                  onTap: () {
                    Navigator.pop(context);
                    shareImage(imageFile);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 1.2),
          ),
        ],
      ),
    );
  }
}
