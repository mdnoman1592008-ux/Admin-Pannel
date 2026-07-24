import '../supabase/supabase_initializer.dart';

/// Sends non-sensitive authentication notifications through the server-side
/// Resend integration. The Resend key never reaches a Flutter client.
class AuthEmailService {
  const AuthEmailService();

  Future<void> sendWelcome({required String email, required String name}) =>
      _send(event: 'welcome', email: email, name: name);

  Future<void> sendLoginAlert({required String email, required String name}) =>
      _send(event: 'login_alert', email: email, name: name);

  Future<void> _send({
    required String event,
    required String email,
    required String name,
  }) async {
    if (email.isEmpty) return;
    await SupabaseInitializer.client.functions.invoke(
      'send-auth-email',
      body: {'event': event, 'email': email, 'name': name},
    );
  }
}
