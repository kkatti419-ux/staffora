import 'package:staffora/data/firebase_services/firebase_profile_services.dart';
import 'package:staffora/data/models/firebase_model/profile/profile_model.dart';
import 'package:staffora/domain/repositories/i_profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  final FirebaseProfileServices service;
  ProfileRepository(this.service);

  @override
  Future<UserProfile?> getProfileDetails() async {
    final data = await service.getCurrentUserProfile();
    if (data == null) return null;

    return UserProfile.fromJson(data);
  }

  @override
  Future<bool> updateProfile(UserProfile profile) async {
    try {
      final result = await service.updateUserProfile(
        profile.userId,
        profile.toJson(),
      );
      return result;
    } catch (e) {
      print("Error in ProfileRepository.updateProfile: $e");
      return false;
    }
  }
}
