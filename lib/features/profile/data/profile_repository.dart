import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/user_profile.dart';

// Must match the box name used in main.dart's Hive.openBox<UserProfile>(...)
const String profileBoxName = 'profileBox';
const String profileKey = 'current_profile';

/// Wraps the Hive box for UserProfile and exposes it as Riverpod state.
class ProfileRepository extends StateNotifier<UserProfile?> {
  ProfileRepository() : super(null) {
    _load();
  }

  Box<UserProfile> get _box => Hive.box<UserProfile>(profileBoxName);

  void _load() {
    state = _box.get(profileKey);
  }

  Future<void> save(UserProfile profile) async {
    await _box.put(profileKey, profile);
    state = profile;
  }

  Future<void> addXp(int amount) async {
    final profile = state;
    if (profile == null) return;

    profile.xp += amount;
    while (profile.xp >= profile.xpToNextLevel) {
      profile.xp -= profile.xpToNextLevel;
      profile.level += 1;
    }
    await profile.save();
    state = profile;
  }

  Future<void> clear() async {
    await _box.delete(profileKey);
    state = null;
  }

  bool get hasCompletedOnboarding => state != null;
}

final profileRepositoryProvider =
    StateNotifierProvider<ProfileRepository, UserProfile?>((ref) {
  return ProfileRepository();
});
