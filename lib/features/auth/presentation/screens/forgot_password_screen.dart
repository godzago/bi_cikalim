import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/responsive.dart';
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
    final layout = context.layout;
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
              padding: EdgeInsets.fromLTRB(
                layout.screenPadding,
                0,
                layout.screenPadding,
                MediaQuery.viewInsetsOf(context).bottom + layout.sectionGap,
              ),
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
          SizedBox(height: context.layout.sectionGap),

          // İllustrasyon
          Center(
            child: Container(
              width: context.layout.fluid(82, 92, 104),
              height: context.layout.fluid(82, 92, 104),
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
          SizedBox(height: context.layout.sectionGap),

          Text(
            'Şifreni Sıfırla',
            style: TextStyle(
              fontSize: context.layout.pageTitleSize,
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
          SizedBox(height: context.layout.sectionGap),

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
          SizedBox(height: context.layout.sectionGap),

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
          width: context.layout.fluid(82, 92, 104),
          height: context.layout.fluid(82, 92, 104),
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
        SizedBox(height: context.layout.sectionGap),

        Text(
          'E-posta Gönderildi! ✅',
          style: TextStyle(
            fontSize: context.layout.pageTitleSize,
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
        SizedBox(height: context.layout.sectionGap),

        PrimaryButton(
          label: 'Giriş Ekranına Dön',
          onPressed: () => context.go(AppConstants.signInRoute),
          isLoading: false,
        ),
      ],
    );
  }
}
