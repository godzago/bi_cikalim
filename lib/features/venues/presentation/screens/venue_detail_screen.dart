import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/event_list_card.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  final String venueId;

  const VenueDetailScreen({super.key, required this.venueId});

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(ApiVenue venue) async {
    if (_isTogglingFavorite) return;
    setState(() => _isTogglingFavorite = true);

    try {
      final service = ref.read(venueApiServiceProvider);
      if (venue.isFavorite) {
        await service.removeFavoriteVenue(venue.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mekan kaydedilenlerden çıkarıldı.')),
        );
      } else {
        await service.addFavoriteVenue(venue.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mekan kaydedilenlere eklendi.')),
        );
      }
      ref.invalidate(venueDetailProvider(widget.venueId));
      ref.invalidate(favoriteVenuesProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem başarısız oldu: $e')),
      );
    } finally {
      setState(() => _isTogglingFavorite = false);
    }
  }

  void _showAddReviewDialog(ApiVenue venue) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Yorum Yaz'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Puanın:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<int>(
                    value: rating,
                    isExpanded: true,
                    items: List.generate(5, (index) => 5 - index).map((val) {
                      return DropdownMenuItem<int>(
                        value: val,
                        child: Row(
                          children: List.generate(
                            5,
                            (starIndex) => Icon(
                              starIndex < val ? Icons.star : Icons.star_border,
                              color: BiCikalimTheme.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => rating = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Yorumun:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Mekan hakkındaki görüşlerinizi yazın...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BiCikalimTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    try {
                      final service = ref.read(interactionApiServiceProvider);
                      await service.createReview(venue.id, rating, commentController.text);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Yorumunuz başarıyla eklendi.')),
                      );
                      ref.invalidate(venueReviewsProvider(venue.id));
                      ref.invalidate(venueDetailProvider(widget.venueId));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Yorum eklenirken hata: $e')),
                      );
                    }
                  },
                  child: const Text('Gönder', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final venueAsync = ref.watch(venueDetailProvider(widget.venueId));
    final eventsAsync = ref.watch(eventsListProvider(EventFilters(venueSlug: widget.venueId)));
    final reviewsAsync = ref.watch(venueReviewsProvider(widget.venueId));

    return Scaffold(
      body: venueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: BiCikalimTheme.primary)),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Mekan detayları yüklenemedi: $error', textAlign: TextAlign.center),
          ),
        ),
        data: (venue) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: BiCikalimTheme.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: AppNetworkImage(imageUrl: venue.coverImageUrl),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.85),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMetaPill(
                            Icons.star_rounded,
                            '${venue.averageRating} puan',
                          ),
                          _buildMetaPill(
                            Icons.chat_bubble_outline,
                            '${venue.reviewCount} yorum',
                          ),
                          _buildMetaPill(
                            Icons.category_outlined,
                            '${venue.activitySummary.length} aktivite',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              venue.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: venue.verificationStatus == 'verified'
                                  ? BiCikalimTheme.success.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  venue.verificationStatus == 'verified'
                                      ? Icons.verified
                                      : Icons.help_outline,
                                  color: venue.verificationStatus == 'verified'
                                      ? BiCikalimTheme.success
                                      : Colors.grey,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  venue.verificationStatus == 'verified'
                                      ? 'Onaylı Mekan'
                                      : 'Doğrulanmamış',
                                  style: TextStyle(
                                    color: venue.verificationStatus == 'verified'
                                        ? BiCikalimTheme.success
                                        : Colors.grey.shade700,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: BiCikalimTheme.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              venue.address ?? '${venue.districtName}, ${venue.cityName}',
                              style: const TextStyle(
                                color: BiCikalimTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildQuickAction(Icons.directions, 'Yol Tarifi', () {}),
                          _buildQuickAction(Icons.phone, 'Ara', () {}),
                          _buildQuickAction(Icons.camera_alt, 'Instagram', () {}),
                          _buildQuickAction(
                            venue.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                            venue.isFavorite ? 'Kaydedildi' : 'Kaydet',
                            () => _toggleFavorite(venue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: BiCikalimTheme.primary,
                  unselectedLabelColor: BiCikalimTheme.textSecondary,
                  indicatorColor: BiCikalimTheme.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Genel'),
                    Tab(text: 'Aktiviteler'),
                    Tab(text: 'Etkinlikler'),
                    Tab(text: 'Yorumlar'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGeneralTab(venue),
                      _buildActivitiesTab(venue.activitySummary),
                      eventsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Center(child: Text('Etkinlikler yüklenemedi: $err')),
                        data: (events) => _buildEventsTab(events, venue),
                      ),
                      reviewsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Center(child: Text('Yorumlar yüklenemedi: $err')),
                        data: (reviews) => _buildReviewsTab(reviews, venue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: BiCikalimTheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BiCikalimTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: BiCikalimTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: BiCikalimTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(ApiVenue venue) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hakkında',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            venue.description ?? 'Açıklama bulunmuyor.',
            style: const TextStyle(
              color: BiCikalimTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Çalışma Saatleri',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (venue.openingHours.isEmpty)
            const Text('Hafta İçi & Hafta Sonu: 09:00 - 23:00 (Varsayılan)', style: TextStyle(color: BiCikalimTheme.textSecondary))
          else
            ...venue.openingHours.map((oh) {
              final days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
              final dayName = oh.dayOfWeek >= 1 && oh.dayOfWeek <= 7 ? days[oh.dayOfWeek - 1] : 'Gün';
              final timeStr = oh.isClosed ? 'Kapalı' : '${oh.opensAt ?? "09:00"} - ${oh.closesAt ?? "23:00"}';
              return _buildInfoRow(dayName, timeStr);
            }),
          const SizedBox(height: 24),
          const Text(
            'Mekan Özellikleri',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: venue.tags.isEmpty
                ? [
                    _buildFeatureChip('Grup dostu'),
                    _buildFeatureChip('Rezervasyon uygun'),
                  ]
                : venue.tags.map((t) => _buildFeatureChip(t.name)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: BiCikalimTheme.textSecondary),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Chip(
      backgroundColor: Colors.grey.shade50,
      side: BorderSide(color: Colors.grey.shade200),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: BiCikalimTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildActivitiesTab(List<ApiVenueActivitySummary> activities) {
    if (activities.isEmpty) {
      return const AppEmptyState(
        icon: Icons.notes,
        message: 'Bu mekana ait aktivite envanteri henüz eklenmemiş.',
        padding: EdgeInsets.all(32),
      );
    }

    final grouped = <String, List<ApiVenueActivitySummary>>{};
    for (final venueActivity in activities) {
      final mockAct = MockDatabase.activities.firstWhere(
        (a) => a.id == venueActivity.activityId,
        orElse: () => MockDatabase.activities.first,
      );
      final categoryId = mockAct.categoryId;
      grouped.putIfAbsent(categoryId, () => []);
      grouped[categoryId]!.add(venueActivity);
    }

    final orderedCategoryIds = grouped.keys.toList()
      ..sort((a, b) {
        final left = MockDatabase.categories.firstWhere((cat) => cat.id == a, orElse: () => MockDatabase.categories.first).order;
        final right = MockDatabase.categories.firstWhere((cat) => cat.id == b, orElse: () => MockDatabase.categories.first).order;
        return left.compareTo(right);
      });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...orderedCategoryIds.map((categoryId) {
          final mockCat = MockDatabase.categories.firstWhere(
            (cat) => cat.id == categoryId,
            orElse: () => MockDatabase.categories.first,
          );
          final inventory = grouped[categoryId]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: BiCikalimTheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          mockCat.icon,
                          color: BiCikalimTheme.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          mockCat.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${inventory.length} kalem',
                        style: const TextStyle(
                          color: BiCikalimTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...inventory.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        _buildCompactInventoryRow(item),
                        if (index != inventory.length - 1)
                          Divider(height: 16, color: Colors.grey.shade100),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCompactInventoryRow(ApiVenueActivitySummary item) {
    final mockAct = MockDatabase.activities.firstWhere(
      (a) => a.id == item.activityId,
      orElse: () => MockDatabase.activities.first,
    );
    final subcategory = MockDatabase.getSubcategoryById(mockAct.subcategoryId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: BiCikalimTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            mockAct.icon,
            size: 18,
            color: BiCikalimTheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.activityName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: BiCikalimTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.isFree ? 'Ücretsiz' : 'Ücretli',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: item.isFree ? BiCikalimTheme.success : BiCikalimTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                [
                  if (subcategory != null) subcategory.name,
                  '${mockAct.minPeople}-${mockAct.maxPeople} kişi',
                ].join(' - '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.45,
                  color: BiCikalimTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsTab(List<ApiEvent> events, ApiVenue venue) {
    if (events.isEmpty) {
      return const AppEmptyState(
        icon: Icons.event_busy,
        message: 'Yakın zamanda planlanmış etkinlik bulunmuyor.',
        padding: EdgeInsets.all(32),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventListCard(event: event, venue: venue, onTap: () {});
      },
    );
  }

  Widget _buildReviewsTab(List<ApiReview> reviews, ApiVenue venue) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    '${venue.averageRating}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: BiCikalimTheme.primary,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < venue.averageRating.floor() ? Icons.star : Icons.star_border,
                        color: BiCikalimTheme.primary,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${venue.reviewCount} yorum',
                    style: const TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, reviews.where((r) => r.rating == 5).length / (reviews.isEmpty ? 1 : reviews.length)),
                    _buildRatingBar(4, reviews.where((r) => r.rating == 4).length / (reviews.isEmpty ? 1 : reviews.length)),
                    _buildRatingBar(3, reviews.where((r) => r.rating == 3).length / (reviews.isEmpty ? 1 : reviews.length)),
                    _buildRatingBar(2, reviews.where((r) => r.rating == 2).length / (reviews.isEmpty ? 1 : reviews.length)),
                    _buildRatingBar(1, reviews.where((r) => r.rating == 1).length / (reviews.isEmpty ? 1 : reviews.length)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kullanıcı Yorumları',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.rate_review,
                  size: 16,
                  color: BiCikalimTheme.primary,
                ),
                label: const Text(
                  'Yorum Yaz',
                  style: TextStyle(color: BiCikalimTheme.primary),
                ),
                onPressed: () => _showAddReviewDialog(venue),
              ),
            ],
          ),
        ),
        Expanded(
          child: reviews.isEmpty
              ? const AppEmptyState(
                  icon: Icons.rate_review_outlined,
                  message: 'Bu mekan için henüz yorum yapılmamış.',
                  padding: EdgeInsets.all(32),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: BiCikalimTheme.primary.withValues(alpha: 0.08),
                                radius: 18,
                                child: Text(
                                  review.userDisplayName[0],
                                  style: const TextStyle(
                                    color: BiCikalimTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.userDisplayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (starIndex) {
                                        return Icon(
                                          starIndex < review.rating ? Icons.star : Icons.star_border,
                                          color: BiCikalimTheme.primary,
                                          size: 12,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review.comment ?? '',
                            style: const TextStyle(
                              color: BiCikalimTheme.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(height: 1, color: Colors.grey.shade100),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int stars, double ratio) {
    return Row(
      children: [
        Text(
          '$stars',
          style: const TextStyle(
            fontSize: 11,
            color: BiCikalimTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                BiCikalimTheme.primary,
              ),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}
