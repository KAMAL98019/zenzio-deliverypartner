import '../models/profile.dart';
import '../data/dummy_data.dart';

class ProfileService {
  Profile _currentProfile = dummyProfile;

  Profile get currentProfile => _currentProfile;

  Future<Profile> getProfile() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentProfile;
  }

  Future<void> updateProfile(Profile newProfile) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    _currentProfile = newProfile;
  }

  Future<void> updateBankDetails(BankDetails newBankDetails) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    _currentProfile = _currentProfile.copyWith(bankDetails: newBankDetails);
  }

  Future<void> updateNotificationSettings(NotificationSettings newSettings) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    _currentProfile = _currentProfile.copyWith(notificationSettings: newSettings);
  }

  Future<void> updateWorkSchedule({
    required String workType,
    required String workShift,
    required String breakStart,
    required String breakEnd,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    _currentProfile = _currentProfile.copyWith(
      workType: workType,
      workShift: workShift,
      breakStart: breakStart,
      breakEnd: breakEnd,
    );
  }
}

final profileService = ProfileService();