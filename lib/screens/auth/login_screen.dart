import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../../services/local/translations_ext.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.tr;
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF6CFF80).withAlpha(80), width: 4),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Color(0xFF6CFF80),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'REPCHAMP',
                  style: TextStyle(
                    fontFamily: 'ArchivoNarrow',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.01,
                    color: Color(0xFF6CFF80),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t('fitness_duel'),
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBACBB6),
                  ),
                ),
                const SizedBox(height: 64),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF201F1F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF353534)),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Color(0xFFE5E2E1)),
                    decoration: InputDecoration(
                      hintText: t('email'),
                      hintStyle: const TextStyle(color: Color(0xFF859581)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF201F1F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF353534)),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Color(0xFFE5E2E1)),
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: t('password'),
                      hintStyle: const TextStyle(color: Color(0xFF859581)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: const Color(0xFF859581),
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB4AB).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFB4AB).withAlpha(77)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFFFB4AB), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Color(0xFFFFB4AB), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6CFF80),
                      foregroundColor: const Color(0xFF00390F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: const Color(0xFF353534),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00390F)),
                          )
                        : Text(
                            t('login'),
                            style: const TextStyle(
                              fontFamily: 'SpaceMono',
                              fontSize: 14,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: Text.rich(
                    TextSpan(
                      text: t('dont_have_account'),
                      style: const TextStyle(color: Color(0xFFBACBB6), fontSize: 13),
                      children: [
                        TextSpan(
                          text: t('sign_up'),
                          style: const TextStyle(color: Color(0xFF6CFF80), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
