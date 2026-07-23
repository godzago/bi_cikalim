import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Şifremi unuttum ekranı.
/// E-posta adresi girerek şifre sıfırlama linki alır.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // TODO: FastAPI backend entegrasyonunda gerçek şifre sıfırlama olacak.
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: BiCikalimTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
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
          onPressed: () => context.pop(),
        ),
        title: const Text('Şifremi Unuttum'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: _emailSent ? _buildSuccessState() : _buildFormState(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // İllustrasyon
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: BiCikalimTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset,
                color: BiCikalimTheme.primary,
                size: 56,
              ),
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Şifreni Sıfırla',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: BiCikalimTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kayıtlı e-posta adresini gir.\nŞifre sıfırlama bağlantısını e-postana gönderelim.',
            style: TextStyle(
              fontSize: 14,
              color: BiCikalimTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),

          AppTextField(
            label: 'E-posta Adresi',
            hintText: 'ornek@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendResetEmail(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'E-posta boş olamaz.';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                return 'Geçerli bir e-posta adresi girin.';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          PrimaryButton(
            label: 'Sıfırlama E-postası Gönder',
            onPressed: _sendResetEmail,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () => context.go(AppConstants.signInRoute),
              child: const Text(
                'Giriş ekranına dön',
                style: TextStyle(color: BiCikalimTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Başarı ikonu
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: BiCikalimTheme.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: BiCikalimTheme.success,
            size: 56,
          ),
        ),
        const SizedBox(height: 32),

        const Text(
          'E-posta Gönderildi! ✅',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: BiCikalimTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '${_emailController.text} adresine\nşifre sıfırlama bağlantısı gönderildi.\nLütfen e-postanı kontrol et.',
          style: const TextStyle(
            fontSize: 14,
            color: BiCikalimTheme.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        PrimaryButton(
          label: 'Giriş Ekranına Dön',
          onPressed: () => context.go(AppConstants.signInRoute),
          isLoading: false,
        ),
      ],
    );
  }
}
