import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';

class CitySelectScreen extends StatelessWidget {
  const CitySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Şehrini Seç',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Sana en yakın mekanları ve aktiviteleri listelemek için şehrini seçmelisin.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              // Eskişehir Pilot City Card
              GestureDetector(
                onTap: () {
                  context.go('/discover');
                },
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1549877452-9c387954fbc2?auto=format&fit=crop&q=80&w=1000',
                      ),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.2),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: BiCikalimTheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PİLOT ŞEHİR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Eskişehir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white70, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Porsuk Çayı, Odunpazarı Evleri...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Other Cities (Passive / Coming soon)
              const Text(
                'Yakında Eklenecek Şehirler',
                style: TextStyle(
                  color: BiCikalimTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _buildComingSoonCity(context, 'İstanbul', 'Tarih, kültür ve sınırsız mekan...'),
                    _buildComingSoonCity(context, 'Ankara', 'Başkentteki gizli eğlence noktaları...'),
                    _buildComingSoonCity(context, 'İzmir', 'Ege esintili samimi aktiviteler...'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonCity(BuildContext context, String name, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          name,
          style: const TextStyle(
            color: BiCikalimTheme.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: BiCikalimTheme.textLight,
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'YAKINDA',
            style: TextStyle(
              color: BiCikalimTheme.textLight,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
