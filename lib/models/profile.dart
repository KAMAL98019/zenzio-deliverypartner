class Profile {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String emailAddress;
  final String address;
  final String vehicleType;
  final String vehicleModel;
  final String licensePlateNumber;
  final double rating;
  final String profileImageUrl;
  final String workType;
  final String workShift;
  final String breakStart;
  final String breakEnd;
  final BankDetails bankDetails;
  final NotificationSettings notificationSettings;
  final bool isOnline;

  Profile({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.emailAddress,
    required this.address,
    required this.vehicleType,
    required this.vehicleModel,
    required this.licensePlateNumber,
    required this.rating,
    required this.profileImageUrl,
    required this.workType,
    required this.workShift,
    required this.breakStart,
    required this.breakEnd,
    required this.bankDetails,
    required this.notificationSettings,
    this.isOnline = true,
  });

  Profile copyWith({
    String? id,
    String? fullName,
    String? mobileNumber,
    String? emailAddress,
    String? address,
    String? vehicleType,
    String? vehicleModel,
    String? licensePlateNumber,
    double? rating,
    String? profileImageUrl,
    String? workType,
    String? workShift,
    String? breakStart,
    String? breakEnd,
    BankDetails? bankDetails,
    NotificationSettings? notificationSettings,
    bool? isOnline,
  }) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      address: address ?? this.address,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      licensePlateNumber: licensePlateNumber ?? this.licensePlateNumber,
      rating: rating ?? this.rating,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      workType: workType ?? this.workType,
      workShift: workShift ?? this.workShift,
      breakStart: breakStart ?? this.breakStart,
      breakEnd: breakEnd ?? this.breakEnd,
      bankDetails: bankDetails ?? this.bankDetails,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class BankDetails {
  final String bankName;
  final String accountNumber;
  final String ifscCode;

  BankDetails({
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
  });
}

class NotificationSettings {
  final bool newDeliveryAssignments;
  final bool orderStatusUpdates;
  final bool earningsUpdates;
  final bool promotionalOffers;
  final bool criticalAlerts;
  final bool weeklyEarningsSummary;
  final bool monthlyEarningsStatement;
  final bool platformAnnouncements;

  NotificationSettings({
    required this.newDeliveryAssignments,
    required this.orderStatusUpdates,
    required this.earningsUpdates,
    required this.promotionalOffers,
    required this.criticalAlerts,
    required this.weeklyEarningsSummary,
    required this.monthlyEarningsStatement,
    required this.platformAnnouncements,
  });

  NotificationSettings copyWith({
    bool? newDeliveryAssignments,
    bool? orderStatusUpdates,
    bool? earningsUpdates,
    bool? promotionalOffers,
    bool? criticalAlerts,
    bool? weeklyEarningsSummary,
    bool? monthlyEarningsStatement,
    bool? platformAnnouncements,
  }) {
    return NotificationSettings(
      newDeliveryAssignments: newDeliveryAssignments ?? this.newDeliveryAssignments,
      orderStatusUpdates: orderStatusUpdates ?? this.orderStatusUpdates,
      earningsUpdates: earningsUpdates ?? this.earningsUpdates,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      criticalAlerts: criticalAlerts ?? this.criticalAlerts,
      weeklyEarningsSummary: weeklyEarningsSummary ?? this.weeklyEarningsSummary,
      monthlyEarningsStatement: monthlyEarningsStatement ?? this.monthlyEarningsStatement,
      platformAnnouncements: platformAnnouncements ?? this.platformAnnouncements,
    );
  }
}