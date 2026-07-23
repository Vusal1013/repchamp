import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/duel_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/supabase/profile_service.dart';
import '../../services/supabase/supabase_client.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (picked == null) return;

    setState(() => _isLoading = true);
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;

      final file = File(picked.path);
      final ext = picked.path.split('.').last;
      final path = '$userId/avatar.$ext';

      await SupabaseClientManager.client.storage.from('avatars').upload(path, file, fileOptions: FileOptions(upsert: true));
      final url = SupabaseClientManager.client.storage.from('avatars').getPublicUrl(path);

      await ProfileService().updateProfile(userId: userId, avatarUrl: url);
      setState(() {
        _success = 'Avatar updated!';
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _error = 'Username cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;

      await ProfileService().updateProfile(userId: userId, username: username);
      setState(() {
        _success = 'Username updated!';
        _error = null;
      });
      _usernameController.clear();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password.isEmpty || password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      await SupabaseClientManager.client.auth.updateUser(UserAttributes(password: password));
      setState(() {
        _success = 'Password updated!';
        _error = null;
      });
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(color: Color(0xFFE5E2E1))),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Color(0xFFBACBB6))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFBACBB6))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out', style: TextStyle(color: Color(0xFFFFB4AB))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await SupabaseClientManager.client.auth.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings.themeMode == ThemeMode.dark || (settings.themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF131313) : Colors.white,
        title: Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFE5E2E1) : const Color(0xFF1A1A1A),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? const Color(0xFF6CFF80) : const Color(0xFF1B5E20)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Avatar ──────────────────────────────
            _sectionHeader('AVATAR', isDark),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF6CFF80), width: 2),
                        color: const Color(0xFF201F1F),
                      ),
                      child: const Icon(Icons.person, size: 48, color: Color(0xFF6CFF80)),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6CFF80),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Color(0xFF00390F)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Tap to change avatar',
                style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFBACBB6) : const Color(0xFF666666)),
              ),
            ),

            const SizedBox(height: 32),

            // ─── Account ──────────────────────────────
            _sectionHeader('ACCOUNT', isDark),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _usernameController,
              hint: 'New username',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildButton(
              label: 'UPDATE USERNAME',
              onPressed: _isLoading ? null : _updateUsername,
              isDark: isDark,
            ),

            const SizedBox(height: 16),
            _buildInputField(
              controller: _passwordController,
              hint: 'New password',
              obscure: true,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _confirmPasswordController,
              hint: 'Confirm password',
              obscure: true,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildButton(
              label: 'UPDATE PASSWORD',
              onPressed: _isLoading ? null : _updatePassword,
              isDark: isDark,
            ),

            const SizedBox(height: 32),

            // ─── Appearance ──────────────────────────
            _sectionHeader('APPEARANCE', isDark),
            const SizedBox(height: 8),
            _buildThemeSelector(isDark, settings),

            const SizedBox(height: 32),

            // ─── Language ────────────────────────────
            _sectionHeader('LANGUAGE', isDark),
            const SizedBox(height: 8),
            _buildLanguageSelector(isDark, settings),

            const SizedBox(height: 32),

            // ─── Sign Out ────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  'SIGN OUT',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFB4AB),
                  side: BorderSide(color: const Color(0xFFFFB4AB).withAlpha(102)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Messages ────────────────────────────
            if (_error != null) _buildMessageBanner(_error!, isError: true, isDark: isDark),
            if (_success != null) _buildMessageBanner(_success!, isError: false, isDark: isDark),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              Center(
                child: CircularProgressIndicator(
                  color: isDark ? const Color(0xFF6CFF80) : const Color(0xFF1B5E20),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Shared Widgets ────────────────────────────────

  Widget _sectionHeader(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        letterSpacing: 1,
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFFBACBB6) : const Color(0xFF666666),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF201F1F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF353534) : const Color(0xFFDDDDDD)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: isDark ? const Color(0xFFE5E2E1) : const Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? const Color(0xFF859581) : const Color(0xFFAAAAAA)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF6CFF80) : const Color(0xFF1B5E20),
          foregroundColor: isDark ? const Color(0xFF00390F) : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(bool isDark, SettingsState settings) {
    final options = [
      (ThemeMode.dark, 'Dark', Icons.dark_mode),
      (ThemeMode.light, 'Light', Icons.light_mode),
      (ThemeMode.system, 'System', Icons.settings_brightness),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF353534) : const Color(0xFFDDDDDD)),
      ),
      child: Column(
        children: options.map((opt) {
          final (mode, label, icon) = opt;
          final selected = settings.themeMode == mode;
          return InkWell(
            onTap: () => ref.read(settingsProvider.notifier).setThemeMode(mode),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: selected ? const Color(0xFF6CFF80) : (isDark ? const Color(0xFF859581) : const Color(0xFFAAAAAA))),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: selected ? const Color(0xFFE5E2E1) : (isDark ? const Color(0xFFBACBB6) : const Color(0xFF666666)),
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle_rounded, size: 18, color: isDark ? const Color(0xFF6CFF80) : const Color(0xFF1B5E20)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDark, SettingsState settings) {
    final options = [
      (const Locale('en'), 'English', '🇬🇧'),
      (const Locale('tr'), 'Türkçe', '🇹🇷'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF353534) : const Color(0xFFDDDDDD)),
      ),
      child: Column(
        children: options.map((opt) {
          final (locale, label, flag) = opt;
          final selected = settings.locale.languageCode == locale.languageCode;
          return InkWell(
            onTap: () => ref.read(settingsProvider.notifier).setLocale(locale),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: selected ? const Color(0xFFE5E2E1) : (isDark ? const Color(0xFFBACBB6) : const Color(0xFF666666)),
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle_rounded, size: 18, color: isDark ? const Color(0xFF6CFF80) : const Color(0xFF1B5E20)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageBanner(String message, {required bool isError, required bool isDark}) {
    final color = isError ? const Color(0xFFFFB4AB) : const Color(0xFF6CFF80);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Row(
          children: [
            Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_rounded, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: TextStyle(color: color, fontSize: 13))),
          ],
        ),
      ),
    );
  }
}
