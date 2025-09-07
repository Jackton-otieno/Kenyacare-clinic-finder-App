import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/hospital.dart';
import '../models/real_time_data.dart';
import '../models/hospital_review.dart';
import '../services/hospital_service.dart' as hospital_service;
import '../l10n/app_localizations.dart';

class HospitalDetailScreen extends StatefulWidget {
  final Hospital hospital;

  const HospitalDetailScreen({
    super.key,
    required this.hospital,
  });

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final hospital_service.HospitalService _hospitalService =
      hospital_service.HospitalService();

  RealTimeHospitalData? _realTimeData;
  List<HospitalReview> _reviews = [];
  bool _isLoadingRealTime = true;
  bool _isLoadingReviews = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRealTimeData();
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRealTimeData() async {
    try {
      final data =
          await _hospitalService.getHospitalRealTimeData(widget.hospital.id);
      if (mounted) {
        setState(() {
          _realTimeData = data;
          _isLoadingRealTime = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRealTime = false);
      }
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviews =
          await _hospitalService.getHospitalReviews(widget.hospital.id);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHospitalHeader(),
                _buildActionButtons(),
                _buildTabBar(),
                _buildTabContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: widget.hospital.imageUrl != null
            ? Image.network(
                widget.hospital.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.local_hospital, size: 64),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              )
            : Container(
                color: Colors.blue.shade100,
                child: const Icon(Icons.local_hospital,
                    size: 64, color: Colors.blue),
              ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareHospital,
        ),
      ],
    );
  }

  Widget _buildHospitalHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.hospital.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildRatingStars(widget.hospital.averageRating),
              const SizedBox(width: 8),
              Text(
                '${widget.hospital.averageRating.toStringAsFixed(1)} (${widget.hospital.totalReviews} reviews)',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.hospital.address,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          if (widget.hospital.distance != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.directions, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${widget.hospital.distance!.toStringAsFixed(1)} km away',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;

    if (_realTimeData?.operationalStatus ==
        OperationalStatus.fullyOperational) {
      badgeColor = Colors.green;
      statusText = 'Open';
    } else if (_realTimeData?.operationalStatus ==
        OperationalStatus.limitedServices) {
      badgeColor = Colors.orange;
      statusText = 'Limited';
    } else if (_realTimeData?.operationalStatus ==
        OperationalStatus.emergencyOnly) {
      badgeColor = Colors.red;
      statusText = 'Emergency Only';
    } else {
      badgeColor = Colors.grey;
      statusText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _getDirections(),
              icon: const Icon(Icons.directions),
              label: Text(AppLocalizations.of(context)!.directions),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _makePhoneCall(widget.hospital.phoneNumber),
              icon: const Icon(Icons.phone),
              label: Text(AppLocalizations.of(context)!.call),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _shareHospital(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            child: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Services'),
          Tab(text: 'Real-time'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 600,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildServicesTab(),
          _buildRealTimeTab(),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Contact Information', [
            _buildInfoRow(Icons.phone, 'Phone', widget.hospital.phoneNumber),
            if (widget.hospital.emergencyNumber != null)
              _buildInfoRow(Icons.emergency, 'Emergency',
                  widget.hospital.emergencyNumber!),
            if (widget.hospital.email != null)
              _buildInfoRow(Icons.email, 'Email', widget.hospital.email!,
                  onTap: () => _sendEmail(widget.hospital.email!)),
            if (widget.hospital.website != null)
              _buildInfoRow(Icons.web, 'Website', widget.hospital.website!,
                  onTap: () => _openUrl(widget.hospital.website!)),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Hospital Details', [
            _buildInfoRow(Icons.business, 'Type',
                widget.hospital.type.toString().split('.').last),
            _buildInfoRow(Icons.account_balance, 'Ownership',
                widget.hospital.ownership.toString().split('.').last),
            _buildInfoRow(Icons.local_hospital, 'Level',
                widget.hospital.level.toString().split('.').last),
            if (widget.hospital.bedCapacity != null)
              _buildInfoRow(Icons.bed, 'Bed Capacity',
                  '${widget.hospital.bedCapacity} beds'),
          ]),
          const SizedBox(height: 24),
          if (widget.hospital.operatingHours.isNotEmpty) _buildOperatingHours(),
          const SizedBox(height: 24),
          if (widget.hospital.accreditation.isNotEmpty) _buildAccreditation(),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.hospital.services.isNotEmpty) ...[
            _buildInfoSection(
                'Available Services',
                widget.hospital.services
                    .map((service) =>
                        _buildServiceItem(service.toString().split('.').last))
                    .toList()),
            const SizedBox(height: 24),
          ],
          if (widget.hospital.specialties.isNotEmpty) ...[
            _buildInfoSection(
                'Specialties',
                widget.hospital.specialties
                    .map((specialty) =>
                        _buildServiceItem(specialty.toString().split('.').last))
                    .toList()),
            const SizedBox(height: 24),
          ],
          if (widget.hospital.supportedLanguages.isNotEmpty) ...[
            _buildInfoSection(
                'Languages Supported',
                widget.hospital.supportedLanguages
                    .map((lang) => _buildServiceItem(lang))
                    .toList()),
          ],
        ],
      ),
    );
  }

  Widget _buildRealTimeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _isLoadingRealTime
          ? const Center(child: CircularProgressIndicator())
          : _realTimeData == null
              ? const Center(child: Text('Real-time data not available'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRealTimeSection('Bed Availability', [
                      _buildRealTimeItem('General Beds',
                          '${_realTimeData!.generalBedsAvailable}/${_realTimeData!.generalBedsTotal}'),
                      _buildRealTimeItem('ICU Beds',
                          '${_realTimeData!.icuBedsAvailable}/${_realTimeData!.icuBedsTotal}'),
                      _buildRealTimeItem('Emergency Beds',
                          '${_realTimeData!.emergencyBedsAvailable}/${_realTimeData!.emergencyBedsTotal}'),
                    ]),
                    const SizedBox(height: 24),
                    _buildRealTimeSection('Wait Times', [
                      _buildRealTimeItem('Emergency',
                          '${_realTimeData!.emergencyWaitTime} min'),
                      _buildRealTimeItem('Outpatient',
                          '${_realTimeData!.outpatientWaitTime} min'),
                    ]),
                    const SizedBox(height: 24),
                    _buildRealTimeSection('Current Status', [
                      _buildRealTimeItem(
                          'Operational Status',
                          _realTimeData!.operationalStatus
                              .toString()
                              .split('.')
                              .last),
                      _buildRealTimeItem(
                          'Emergency Level',
                          _realTimeData!.emergencyLevel
                              .toString()
                              .split('.')
                              .last),
                      _buildRealTimeItem('Last Updated',
                          _formatDateTime(_realTimeData!.lastUpdated)),
                    ]),
                  ],
                ),
    );
  }

  Widget _buildReviewsTab() {
    return _isLoadingReviews
        ? const Center(child: CircularProgressIndicator())
        : _reviews.isEmpty
            ? const Center(child: Text('No reviews yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reviews.length,
                itemBuilder: (context, index) =>
                    _buildReviewCard(_reviews[index]),
              );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: onTap != null ? Colors.blue : null,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String service) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(service)),
        ],
      ),
    );
  }

  Widget _buildOperatingHours() {
    return _buildInfoSection(
        'Operating Hours',
        widget.hospital.operatingHours.entries
            .map((entry) =>
                _buildInfoRow(Icons.access_time, entry.key, entry.value))
            .toList());
  }

  Widget _buildAccreditation() {
    return _buildInfoSection(
        'Accreditation',
        widget.hospital.accreditation.entries
            .map((entry) => _buildInfoRow(Icons.verified, entry.key,
                entry.value.toString().split('.').last))
            .toList());
  }

  Widget _buildRealTimeSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildRealTimeItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(HospitalReview review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Text(review.userName != null
                      ? review.userName![0].toUpperCase()
                      : 'U'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName ?? 'Anonymous',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDateTime(review.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRatingStars(review.overallRating),
              ],
            ),
            if (review.reviewText != null) ...[
              const SizedBox(height: 12),
              Text(review.reviewText!),
            ],
            if (review.helpfulCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${review.helpfulCount} people found this helpful',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _getDirections() async {
    final lat = widget.hospital.latitude;
    final lng = widget.hospital.longitude;
    final hospitalName = Uri.encodeComponent(widget.hospital.name);

    // Try different map applications in order of preference
    final urls = [
      // Google Maps (most common)
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$hospitalName',
      // Apple Maps (iOS)
      'https://maps.apple.com/?daddr=$lat,$lng&q=$hospitalName',
      // Generic geo URI (fallback)
      'geo:$lat,$lng?q=$lat,$lng($hospitalName)',
    ];

    bool launched = false;
    for (final url in urls) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open maps application'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch phone app';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to make phone call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _makeEmergencyCall(String emergencyNumber) async {
    // Show confirmation dialog for emergency calls
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Call'),
        content: Text(
            'Are you sure you want to call the emergency number: $emergencyNumber?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.callEmergency),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _makePhoneCall(emergencyNumber);
    }
  }

  Future<void> _shareHospital() async {
    final hospitalInfo = '''
${widget.hospital.name}
${widget.hospital.address}
Phone: ${widget.hospital.phoneNumber}
${widget.hospital.website != null ? 'Website: ${widget.hospital.website}' : ''}

Shared via AfyaMap Kenya
''';

    Share.share(
      hospitalInfo,
      subject: 'Hospital Information - ${widget.hospital.name}',
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch website';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open website: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse(
        'mailto:$email?subject=Inquiry about ${widget.hospital.name}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch email app';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to send email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _writeReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) =>
            _buildReviewForm(scrollController),
      ),
    );
  }

  Widget _buildReviewForm(ScrollController scrollController) {
    double rating = 5.0;
    final reviewController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Write a Review',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.hospital.name,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Rating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: _buildInteractiveRating(rating, (newRating) {
                        setState(() => rating = newRating);
                      }),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reviewController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Share your experience with this hospital...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                _submitReview(rating, reviewController.text),
                            child: const Text('Submit Review'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveRating(
      double rating, Function(double) onRatingUpdate) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingUpdate(index + 1.0),
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  Future<void> _submitReview(double rating, String reviewText) async {
    try {
      final review = HospitalReview(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        hospitalId: widget.hospital.id,
        userId: 'current_user_id',
        userName: 'Current User',
        overallRating: rating,
        categoryRatings: {
          ReviewCategory.overall: rating,
        },
        reviewText: reviewText.isNotEmpty ? reviewText : null,
        createdAt: DateTime.now(),
        isVerified: false,
        isAnonymous: false,
        reviewType: ReviewType.general,
        wouldRecommend: rating >= 4.0,
        tags: [],
        helpfulCount: 0,
        status: ReviewStatus.published,
      );

      final success = await _hospitalService.submitHospitalReview(review);

      if (mounted) {
        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!')),
          );
          _loadReviews();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Review saved offline and will be submitted when connected')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    }
  }
}
