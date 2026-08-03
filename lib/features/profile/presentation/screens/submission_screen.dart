import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../shared/widgets/app_refreshable_content.dart';
import '../../../auth/presentation/providers/user_session_provider.dart';

enum SubmissionType { venueSuggestion, ownership, taxonomy }

class SubmissionScreen extends ConsumerStatefulWidget {
  final SubmissionType type;

  const SubmissionScreen({super.key, required this.type});

  @override
  ConsumerState<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends ConsumerState<SubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _secondary = TextEditingController();
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();
  final _contactEmail = TextEditingController();
  final _url = TextEditingController();
  final _note = TextEditingController();
  String _taxonomyType = 'activity';
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.read(currentUserProvider);
    if (_contactName.text.isEmpty) _contactName.text = user?.displayName ?? '';
    if (_contactEmail.text.isEmpty) _contactEmail.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _secondary.dispose();
    _contactName.dispose();
    _contactPhone.dispose();
    _contactEmail.dispose();
    _url.dispose();
    _note.dispose();
    super.dispose();
  }

  String get _title => switch (widget.type) {
    SubmissionType.venueSuggestion => 'Eksik Mekan Öner',
    SubmissionType.ownership => 'Mekan Sahiplenme Başvurusu',
    SubmissionType.taxonomy => 'Aktivite/Kategori Talebi',
  };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _busy) return;
    final city = ref.read(selectedCityProvider).value;
    if (widget.type == SubmissionType.venueSuggestion && city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir şehir seçmelisiniz.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final service = ref.read(submissionApiServiceProvider);
      switch (widget.type) {
        case SubmissionType.venueSuggestion:
          await service.createVenueSuggestion(
            cityId: city!.id,
            name: _name.text.trim(),
            address: _emptyToNull(_secondary.text),
            googleMapsUrl: _emptyToNull(_url.text),
            note: _emptyToNull(_note.text),
          );
          break;
        case SubmissionType.ownership:
          await service.createOwnershipApplication(
            requestedVenueName: _name.text.trim(),
            businessName: _emptyToNull(_secondary.text),
            contactName: _contactName.text.trim(),
            contactPhone: _contactPhone.text.trim(),
            contactEmail: _contactEmail.text.trim(),
            message: _emptyToNull(_note.text),
          );
          break;
        case SubmissionType.taxonomy:
          await service.createTaxonomyRequest(
            requestType: _taxonomyType,
            name: _name.text.trim(),
            description: _emptyToNull(_note.text),
          );
          break;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Talebiniz admin onayına gönderildi.')),
      );
      context.pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _refreshPrerequisites() async {
    ref.invalidate(selectedCityProvider);
    await ref.read(selectedCityProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = ref.watch(isLoggedInProvider);
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: !loggedIn
          ? AppRefreshableContent(
              onRefresh: _refreshPrerequisites,
              child: Center(
                child: FilledButton(
                  onPressed: () => context.push('/sign-in'),
                  child: const Text('Başvuru için giriş yap'),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshPrerequisites,
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    context.layout.screenPadding,
                    8,
                    context.layout.screenPadding,
                    MediaQuery.viewInsetsOf(context).bottom +
                        context.layout.sectionGap,
                  ),
                  children: [
                    if (widget.type == SubmissionType.taxonomy)
                      DropdownButtonFormField<String>(
                        initialValue: _taxonomyType,
                        decoration: const InputDecoration(
                          labelText: 'Talep türü',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'activity',
                            child: Text('Aktivite'),
                          ),
                          DropdownMenuItem(
                            value: 'category',
                            child: Text('Kategori'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _taxonomyType = value ?? 'activity'),
                      ),
                    if (widget.type == SubmissionType.taxonomy)
                      const SizedBox(height: 12),
                    TextFormField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: widget.type == SubmissionType.taxonomy
                            ? 'Talep adı'
                            : 'Mekan adı',
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 2
                          ? 'En az 2 karakter girin.'
                          : null,
                    ),
                    if (widget.type != SubmissionType.taxonomy) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _secondary,
                        decoration: InputDecoration(
                          labelText:
                              widget.type == SubmissionType.venueSuggestion
                              ? 'Adres'
                              : 'İşletme adı',
                        ),
                      ),
                    ],
                    if (widget.type == SubmissionType.venueSuggestion) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _url,
                        decoration: const InputDecoration(
                          labelText: 'Google Maps URL',
                        ),
                      ),
                    ],
                    if (widget.type == SubmissionType.ownership) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactName,
                        decoration: const InputDecoration(
                          labelText: 'İletişim adı',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactPhone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Telefon'),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'E-posta'),
                        validator: _required,
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _note,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama / not',
                      ),
                    ),
                    SizedBox(height: context.layout.sectionGap),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: Text(
                        _busy ? 'Gönderiliyor...' : 'Admin Onayına Gönder',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Bu alan zorunludur.' : null;
  }
}
