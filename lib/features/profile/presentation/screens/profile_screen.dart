import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_menu_card.dart';
import '../../../../shared/widgets/app_section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: BiCikalimTheme.primary,
                        width: 3,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=300',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ulaş Demirkol',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BiCikalimTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Eskişehir Kaşifi',
                      style: TextStyle(
                        color: BiCikalimTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _buildStatItem('12', 'Yorum'),
                _buildStatItem('3', 'Başvuru'),
                _buildStatItem('8', 'Kaydedilen'),
              ],
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'İşletme Yönetimi & Başvurular'),
            const SizedBox(height: 12),
            AppMenuCard(
              icon: Icons.storefront,
              title: 'Yeni Mekan Ekle',
              subtitle: 'Şehrindeki bir mekanı listeye kaydet.',
              onTap: () => _showAddVenueSheet(context),
            ),
            const SizedBox(height: 12),
            AppMenuCard(
              icon: Icons.verified_user_outlined,
              title: 'Mekan Sahiplen',
              subtitle: 'Editör tarafından eklenen mekanın yönetimini devral.',
              onTap: () => _showClaimVenueSheet(context),
            ),
            const SizedBox(height: 12),
            AppMenuCard(
              icon: Icons.rule_folder_outlined,
              title: 'Başvuru Durumu',
              subtitle: '1 yeni mekan talebi, 1 sahiplenme talebi incelemede.',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'Genel Ayarlar'),
            const SizedBox(height: 12),
            AppMenuCard(
              icon: Icons.location_city,
              title: 'Şehir Değiştir',
              subtitle: 'Aktif şehri değiştirin (Seçili: Eskişehir)',
              onTap: () => context.go('/city-select'),
            ),
            const SizedBox(height: 12),
            AppMenuCard(
              icon: Icons.info_outline,
              title: 'Hakkımızda',
              subtitle: 'BiÇıkalım platformu hakkında bilgi edinin.',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: BiCikalimTheme.textPrimary,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: BiCikalimTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddVenueSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Yeni Mekan Ekleme Talebi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mekanın temel bilgilerini girin. Onay sürecinden sonra yayınlanacaktır.',
                ),
                const SizedBox(height: 20),
                const TextField(
                  decoration: InputDecoration(hintText: 'Mekan Adı'),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(hintText: 'İlçe / Bölge'),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Aktivite Kategorileri (Örn: Bilardo, Dart)',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mekan ekleme talebi gönderildi.'),
                          backgroundColor: BiCikalimTheme.success,
                        ),
                      );
                    },
                    child: const Text('Başvuruyu Gönder'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClaimVenueSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Mekan Sahiplenme Talebi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Doğrulama ve yetkilendirme işlemi için bilgilerinizi eksiksiz doldurun.',
                ),
                const SizedBox(height: 20),
                const TextField(
                  decoration: InputDecoration(hintText: 'Ad Soyad'),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'İşletmedeki Rolünüz (Sahibi, Müdür vb.)',
                  ),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Mekan Instagram Hesabı (@kullanici_adi)',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Mekan sahiplenme talebi başarıyla alındı.',
                          ),
                          backgroundColor: BiCikalimTheme.success,
                        ),
                      );
                    },
                    child: const Text('Talebi Gönder'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
