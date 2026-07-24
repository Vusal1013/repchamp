import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/localization_provider.dart';
import '../../services/local/translations_ext.dart';

class OfflineScreen extends ConsumerStatefulWidget {
  final Widget child;
  const OfflineScreen({super.key, required this.child});

  @override
  ConsumerState<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends ConsumerState<OfflineScreen> {
  bool _isOffline = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkConnectivity());
  }

  Future<void> _checkConnectivity() async {
    try {
      await Socket.connect('8.8.8.8', 53, timeout: const Duration(seconds: 3)).then((s) => s.destroy());
      if (mounted) setState(() => _isOffline = false);
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      final t = ref.tr;
      return Scaffold(
        backgroundColor: const Color(0xFF131313),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF353534),
                  ),
                  child: const Icon(Icons.wifi_off_rounded, color: Color(0xFFBACBB6), size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  t('no_connection'),
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE5E2E1),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t('check_internet'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFBACBB6),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _checkConnectivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6CFF80),
                      foregroundColor: const Color(0xFF00390F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      t('retry'),
                      style: const TextStyle(
                        fontSize: 14,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
