import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/auth/auth_service.dart';
import '../onboarding/onboarding_widgets.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscured = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your email address and password.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final user = await _auth.signInWithEmailPassword(email, password);
      if (mounted) Navigator.of(context).pop(user);
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to sign in right now. Try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email first, then request a reset link.');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent. Check your inbox.')),
      );
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: Stack(children: [
        const Positioned.fill(child: _AuthBackdrop()),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                  ),
                  const EtherLogoBadge(size: 68),
                  const SizedBox(height: 24),
                  const Text('Welcome back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30)),
                  const SizedBox(height: 8),
                  const Text('Sign in securely to continue your cinema.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFBBC9CF))),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xE80D111A),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0x6600CFFF)),
                      boxShadow: const [BoxShadow(color: Color(0x2200CFFF), blurRadius: 34)],
                    ),
                    child: Column(children: [
                      if (_error != null) ...[
                        _ErrorText(message: _error!),
                        const SizedBox(height: 16),
                      ],
                      _field(controller: _email, label: 'Email address', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      _field(controller: _password, label: 'Password', icon: Icons.lock_outline_rounded, obscure: _obscured, suffix: IconButton(icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined), color: const Color(0xFF00CFFF), onPressed: () => setState(() => _obscured = !_obscured))),
                      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _submitting ? null : _resetPassword, child: const Text('Forgot password?'))),
                      const SizedBox(height: 6),
                      GlassPrimaryButton(label: _submitting ? 'Signing in...' : 'Sign in securely', icon: Icons.login_rounded, onPressed: _submitting ? () {} : _signIn),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _field({required TextEditingController controller, required String label, required IconData icon, bool obscure = false, Widget? suffix, TextInputType? keyboardType}) => TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    textInputAction: label == 'Password' ? TextInputAction.done : TextInputAction.next,
    onSubmitted: label == 'Password' ? (_) => _signIn() : null,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: const Color(0xFF00CFFF)), suffixIcon: suffix, filled: true, fillColor: Colors.white.withOpacity(.055), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
  );
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(-.7, -.8), radius: 1.25, colors: [Color(0xFF14283A), Color(0xFF090B13), Color(0xFF050608)])),
  );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0x33FF3B30), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x88FF3B30))),
    child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
  );
}
