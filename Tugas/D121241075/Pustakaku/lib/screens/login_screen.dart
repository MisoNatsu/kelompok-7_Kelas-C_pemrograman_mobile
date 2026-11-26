import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/extensions.dart';
import '../core/mixins.dart';
import '../core/demo_mode.dart';
import '../providers/providers.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with ValidatorsMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Mode demo (emulator lokal): isi akun contoh lalu langsung masuk.
  Future<void> _loginDemo(String email, String password) async {
    _email.text = email;
    _password.text = password;
    await _submit();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(authControllerProvider.notifier)
        .signIn(_email.text, _password.text);
    // Navigasi otomatis ditangani AuthGate (authStateProvider berubah).
  }

  Future<void> _forgot() async {
    if (validateEmail(_email.text) != null) {
      context.showSnack('Masukkan email yang valid dulu untuk reset kata sandi.');
      return;
    }
    final ok =
        await ref.read(authControllerProvider.notifier).resetPassword(_email.text);
    if (ok && mounted) context.showSnack('Tautan reset dikirim ke ${_email.text.trim()}');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    // Tampilkan error sebagai snackbar setiap kali state berubah ke error.
    ref.listen(authControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        context.showSnack('$error', error: true);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandHeader(),
                    const SizedBox(height: 36),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                          labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Kata sandi',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: validatePassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: auth.isLoading ? null : _forgot,
                          child: const Text('Lupa kata sandi?')),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: auth.isLoading ? null : _submit,
                      child: auth.isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Masuk'),
                    ),
                    if (isDemoMode) ...[
                      const SizedBox(height: 20),
                      Row(children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('MODE DEMO (emulator lokal)',
                              style: context.text.labelSmall
                                  ?.copyWith(color: context.colors.outline)),
                        ),
                        const Expanded(child: Divider()),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: auth.isLoading
                                ? null
                                : () => _loginDemo('admin@pustakaku.id', 'admin123'),
                            icon: const Icon(Icons.shield_outlined, size: 18),
                            label: const Text('Admin demo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: auth.isLoading
                                ? null
                                : () => _loginDemo('budi@pustakaku.id', 'budi123'),
                            icon: const Icon(Icons.person_outline, size: 18),
                            label: const Text('Pengguna demo'),
                          ),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum punya akun?', style: TextStyle(color: context.palette.muted)),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text('Daftar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// Logo, nama aplikasi, dan deretan punggung buku sebagai identitas visual.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const spines = <(double, int)>[(54, 0), (70, 3), (62, 1), (78, 2), (58, 4), (66, 5)];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (height, color) in spines)
              Container(
                width: 18,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: p.covers[color],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                ),
              ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset('assets/brand/logo_rounded.png', width: 78, height: 78),
            ),
          ],
        ),
        Container(height: 4, width: 230, color: p.lineStrong),
        const SizedBox(height: 24),
        Text('Pustakaku', style: context.text.displaySmall, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          'Cari, simpan, dan ulas buku favoritmu',
          style: context.text.bodyLarge?.copyWith(color: p.muted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
