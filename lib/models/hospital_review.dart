class HospitalReview {
  final String id;
  final String hospitalId;
  final String userId;
  final String? userName;
  final double overallRating;
  final Map<ReviewCategory, double> categoryRatings;
  final String? reviewText;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final bool isAnonymous;
  final ReviewType reviewType;
  final bool wouldRecommend;
  final List<String> tags;
  final int helpfulCount;
  final int notHelpfulCount;
  final ReviewStatus status;
  final String? moderatorNotes;
  final DateTime? moderatedAt;
  final String? moderatorId;

  const HospitalReview({
    required this.id,
    required this.hospitalId,
    required this.userId,
    this.userName,
    required this.overallRating,
    required this.categoryRatings,
    this.reviewText,
    required this.createdAt,
    this.updatedAt,
    required this.isVerified,
    required this.isAnonymous,
    required this.reviewType,
    required this.wouldRecommend,
    required this.tags,
    required this.helpfulCount,
    this.notHelpfulCount = 0,
    required this.status,
    this.moderatorNotes,
    this.moderatedAt,
    this.moderatorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hospitalId': hospitalId,
      'userId': userId,
      'userName': userName,
      'overallRating': overallRating,
      'categoryRatings':
          categoryRatings.map((key, value) => MapEntry(key.index, value)),
      'reviewText': reviewText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isVerified': isVerified,
      'isAnonymous': isAnonymous,
      'reviewType': reviewType.index,
      'wouldRecommend': wouldRecommend,
      'tags': tags,
      'helpfulCount': helpfulCount,
      'notHelpfulCount': notHelpfulCount,
      'status': status.index,
      'moderatorNotes': moderatorNotes,
      'moderatedAt': moderatedAt?.toIso8601String(),
      'moderatorId': moderatorId,
    };
  }

  factory HospitalReview.fromJson(Map<String, dynamic> json) {
    return HospitalReview(
      id: json['id'],
      hospitalId: json['hospitalId'],
      userId: json['userId'],
      userName: json['userName'],
      overallRating: json['overallRating'].toDouble(),
      categoryRatings: (json['categoryRatings'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(ReviewCategory.values[int.parse(key)], value.toDouble()),
      ),
      reviewText: json['reviewText'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isVerified: json['isVerified'],
      isAnonymous: json['isAnonymous'],
      reviewType: ReviewType.values[json['reviewType']],
      wouldRecommend: json['wouldRecommend'],
      tags: List<String>.from(json['tags']),
      helpfulCount: json['helpfulCount'],
      notHelpfulCount: json['notHelpfulCount'] ?? 0,
      status: ReviewStatus.values[json['status']],
      moderatorNotes: json['moderatorNotes'],
      moderatedAt: json['moderatedAt'] != null
          ? DateTime.parse(json['moderatedAt'])
          : null,
      moderatorId: json['moderatorId'],
    );
  }

  HospitalReview copyWith({
    String? id,
    String? hospitalId,
    String? userId,
    String? userName,
    double? overallRating,
    Map<ReviewCategory, double>? categoryRatings,
    String? reviewText,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? isAnonymous,
    ReviewType? reviewType,
    bool? wouldRecommend,
    List<String>? tags,
    int? helpfulCount,
    int? notHelpfulCount,
    ReviewStatus? status,
    String? moderatorNotes,
    DateTime? moderatedAt,
    String? moderatorId,
  }) {
    return HospitalReview(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      overallRating: overallRating ?? this.overallRating,
      categoryRatings: categoryRatings ?? this.categoryRatings,
      reviewText: reviewText ?? this.reviewText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      reviewType: reviewType ?? this.reviewType,
      wouldRecommend: wouldRecommend ?? this.wouldRecommend,
      tags: tags ?? this.tags,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      notHelpfulCount: notHelpfulCount ?? this.notHelpfulCount,
      status: status ?? this.status,
      moderatorNotes: moderatorNotes ?? this.moderatorNotes,
      moderatedAt: moderatedAt ?? this.moderatedAt,
      moderatorId: moderatorId ?? this.moderatorId,
    );
  }

  String get displayName {
    if (isAnonymous) return 'Anonymous User';
    return userName ?? 'User';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get hasImages => false; // Removed imageUrls field
  bool get hasReviewText => reviewText != null && reviewText!.isNotEmpty;
}

class HospitalRatingSummary {
  final String hospitalId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final Map<ReviewCategory, double> categoryAverages;
  final List<String> mostCommonTags;
  final double recommendationRate;
  final DateTime lastUpdated;
  final int verifiedReviewsCount;
  final Map<ReviewType, int> reviewTypeDistribution;

  const HospitalRatingSummary({
    required this.hospitalId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.categoryAverages,
    required this.mostCommonTags,
    required this.recommendationRate,
    required this.lastUpdated,
    required this.verifiedReviewsCount,
    required this.reviewTypeDistribution,
  });

  Map<String, dynamic> toJson() {
    final categoryAveragesJson = <String, dynamic>{};
    for (final entry in categoryAverages.entries) {
      categoryAveragesJson[entry.key.toString().split('.').last] = entry.value;
    }

    final reviewTypeDistributionJson = <String, dynamic>{};
    for (final entry in reviewTypeDistribution.entries) {
      reviewTypeDistributionJson[entry.key.toString().split('.').last] =
          entry.value;
    }

    return {
      'hospitalId': hospitalId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution,
      'categoryAverages': categoryAveragesJson,
      'mostCommonTags': mostCommonTags,
      'recommendationRate': recommendationRate,
      'lastUpdated': lastUpdated.toIso8601String(),
      'verifiedReviewsCount': verifiedReviewsCount,
      'reviewTypeDistribution': reviewTypeDistributionJson,
    };
  }

  factory HospitalRatingSummary.fromJson(Map<String, dynamic> json) {
    final categoryAveragesMap = <ReviewCategory, double>{};
    final categoryAveragesJson =
        json['categoryAverages'] as Map<String, dynamic>;

    for (final entry in categoryAveragesJson.entries) {
      final category = ReviewCategory.values.firstWhere(
        (e) => e.toString().split('.').last == entry.key,
        orElse: () => ReviewCategory.overall,
      );
      categoryAveragesMap[category] = (entry.value as num).toDouble();
    }

    final reviewTypeDistributionMap = <ReviewType, int>{};
    final reviewTypeDistributionJson =
        json['reviewTypeDistribution'] as Map<String, dynamic>;

    for (final entry in reviewTypeDistributionJson.entries) {
      final reviewType = ReviewType.values.firstWhere(
        (e) => e.toString().split('.').last == entry.key,
        orElse: () => ReviewType.general,
      );
      reviewTypeDistributionMap[reviewType] = entry.value as int;
    }

    return HospitalRatingSummary(
      hospitalId: json['hospitalId'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      ratingDistribution: Map<int, int>.from(json['ratingDistribution']),
      categoryAverages: categoryAveragesMap,
      mostCommonTags: (json['mostCommonTags'] as List<dynamic>).cast<String>(),
      recommendationRate: (json['recommendationRate'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      verifiedReviewsCount: json['verifiedReviewsCount'] as int,
      reviewTypeDistribution: reviewTypeDistributionMap,
    );
  }

  String get ratingText {
    if (averageRating >= 4.5) return 'Excellent';
    if (averageRating >= 4.0) return 'Very Good';
    if (averageRating >= 3.5) return 'Good';
    if (averageRating >= 3.0) return 'Average';
    if (averageRating >= 2.0) return 'Below Average';
    return 'Poor';
  }

  bool get hasEnoughReviews => totalReviews >= 5;

  double get verificationRate {
    if (totalReviews == 0) return 0.0;
    return verifiedReviewsCount / totalReviews;
  }
}

enum ReviewCategory {
  overall,
  cleanliness,
  staffFriendliness,
  waitTime,
  facilityQuality,
  medicalCare,
  valueForMoney,
  accessibility,
  communication,
  emergencyResponse,
}

enum ReviewType {
  general,
  emergency,
  outpatient,
  inpatient,
  specialist,
  maternity,
  pediatric,
}

enum ReviewStatus {
  draft,
  pending,
  published,
  flagged,
  removed,
}

class HospitalRating {
  final String hospitalId;
  final double overallRating;
  final int totalReviews;
  final Map<ReviewCategory, double> categoryRatings;
  final Map<int, int> ratingDistribution; // star rating -> count
  final DateTime lastUpdated;

  const HospitalRating({
    required this.hospitalId,
    required this.overallRating,
    required this.totalReviews,
    required this.categoryRatings,
    required this.ratingDistribution,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'hospitalId': hospitalId,
      'overallRating': overallRating,
      'totalReviews': totalReviews,
      'categoryRatings':
          categoryRatings.map((key, value) => MapEntry(key.index, value)),
      'ratingDistribution': ratingDistribution
          .map((key, value) => MapEntry(key.toString(), value)),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory HospitalRating.fromJson(Map<String, dynamic> json) {
    return HospitalRating(
      hospitalId: json['hospitalId'],
      overallRating: json['overallRating'].toDouble(),
      totalReviews: json['totalReviews'],
      categoryRatings: (json['categoryRatings'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(ReviewCategory.values[int.parse(key)], value.toDouble()),
      ),
      ratingDistribution:
          (json['ratingDistribution'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(int.parse(key), value),
      ),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

enum ReviewSortBy {
  newest,
  oldest,
  highestRated,
  lowestRated,
  mostHelpful,
}

enum ReviewFilter {
  all,
  verified,
  recent,
  highRating,
  lowRating,
  withText,
}
