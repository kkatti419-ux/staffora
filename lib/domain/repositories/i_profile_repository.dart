import 'package:staffora/data/models/firebase_model/profile/profile_model.dart';

abstract class IProfileRepository {
  Future<bool> updateProfile(UserProfile product);

  Future<UserProfile?> getProfileDetails();
}
