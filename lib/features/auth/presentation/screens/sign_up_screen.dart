import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/user_session_provider.dart';

/// Yeni kullanıcı kayıt ekranı.
class SignUpScreen extends ConsumerStatefulWidget {
  final String accountType;

  const SignUpScreen({super.key, this.accountType = 'user'});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(userSessionProvider.notifier)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
            fullName: _nameController.text.trim(),
            role: widget.accountType,
          );

      if (!mounted) return;
      if (widget.accountType == 'venue_owner') {
        context.go(AppConstants.venueOwnerRoute);
      } else {
        context.go(AppConstants.citySelectRoute);
      }
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BiCikalimTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BiCikalimTheme.background,
      appBar: AppBar(
        backgroundColor: BiCikalimTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go(
            '${AppConstants.signInRoute}?accountType=${widget.accountType}',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Başlık
                Text(
                  widget.accountType == 'venue_owner'
                      ? 'İşletme Hesabı Oluştur'
                      : 'Hesap Oluştur',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: BiCikalimTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'BiÇıkalım\'a katıl ve şehrindeki\naktiviteleri keşfetmeye başla! 🚀',
                  style: TextStyle(
                    fontSize: 14,
                    color: BiCikalimTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Ad Soyad
                AppTextField(
                  label: 'Ad Soyad',
                  hintText: 'Adın ve soyadın',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'İsim boş olamaz.';
                    }
                    if (v.trim().length < 2) {
                      return 'İsim en az 2 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kullanıcı Adı
                AppTextField(
                  label: 'Kullanıcı Adı',
                  hintText: 'zago',
                  controller: _usernameController,
                  prefixIcon: Icons.alternate_email,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Kullanıcı adı boş olamaz.';
                    }
                    if (v.trim().length < 3) {
                      return 'Kullanıcı adı en az 3 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // E-posta
                AppTextField(
                  label: 'E-posta Adresi',
                  hintText: 'ornek@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'E-posta boş olamaz.';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return 'Geçerli bir e-posta adresi girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Şifre
                AppTextField(
                  label: 'Şifre',
                  hintText: 'En az 8 karakter',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Şifre boş olamaz.';
                    if (v.length < 8) {
                      return 'Şifre en az 8 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Şifre Tekrar
                AppTextField(
                  label: 'Şifre Tekrar',
                  hintText: 'Şifreni tekrar gir',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signUp(),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Şifre tekrar boş olamaz.';
                    }
                    if (v != _passwordController.text) {
                      return 'Şifreler eşleşmiyor.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Kayıt Ol Butonu
                PrimaryButton(
                  label: 'Hesap Oluştur',
                  onPressed: _signUp,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),

                // Kullanım Koşulları
                Center(
                  child: Text(
                    'Kaydolarak Gizlilik Politikası\'nı ve\nKullanım Koşulları\'nı kabul etmiş olursunuz.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Giriş Yap yönlendirmesi
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Zaten hesabın var mı?  ',
                      style: TextStyle(
                        color: BiCikalimTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(
                        '${AppConstants.signInRoute}?accountType=${widget.accountType}',
                      ),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(
                          color: BiCikalimTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
