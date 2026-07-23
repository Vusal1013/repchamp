import 'dart:io';
import 'package:flutter/material.dart';

class AvatarConfirmDialog extends StatefulWidget {
  final File imageFile;

  const AvatarConfirmDialog({super.key, required this.imageFile});

  @override
  State<AvatarConfirmDialog> createState() => _AvatarConfirmDialogState();
}

class _AvatarConfirmDialogState extends State<AvatarConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF201F1F),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_rounded, size: 64, color: Color(0xFF555555)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Confirm Avatar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFE5E2E1) : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Use this image as your profile picture?',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFBACBB6) : const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFBACBB6),
                      side: BorderSide(color: isDark ? const Color(0xFF353534) : const Color(0xFFDDDDDD)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Retake', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6CFF80),
                      foregroundColor: const Color(0xFF00390F),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Use as Avatar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
