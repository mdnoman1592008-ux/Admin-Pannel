import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../onboarding/onboarding_widgets.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, this.onVerified});
  final VoidCallback? onVerified;

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _auth = AuthService();
  bool _checking = false;
  String? _message;

  Future<void> _checkVerification() async {
    setState(() => _checking = true);
    try {
      final verified = await _auth.isCurrentEmailVerified();
      if (!mounted) return;
      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email verified. Your account is ready.')));
        widget.onVerified?.call();
      } else {
        setState(() => _message = 'We could not confirm it yet. Open the secure link in your email, then try again.');
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _checking = true);
    try {
      await _auth.sendEmailVerification();
      if (mounted) setState(() => _message = 'A fresh verification link has been sent.');
    } catch (_) {
      if (mounted) setState(() => _message = 'Unable to resend the verification email. Please try shortly.');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF050608),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const EtherLogoBadge(size: 72),
              const SizedBox(height: 28),
              const Text('Verify your email', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Text('We sent a secure verification link to your email address. Open it, return here, and confirm to activate your account.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFBBC9CF), height: 1.45)),
              if (_message != null) ...[
                const SizedBox(height: 22),
                Text(_message!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF00CFFF))),
              ],
              const SizedBox(height: 30),
              GlassPrimaryButton(label: _checking ? 'Checking...' : 'I verified my email', icon: Icons.verified_rounded, onPressed: _checking ? () {} : _checkVerification),
              TextButton(onPressed: _checking ? null : _resend, child: const Text('Resend verification email')),
            ]),
          ),
        ),
      ),
    ),
  );
}
