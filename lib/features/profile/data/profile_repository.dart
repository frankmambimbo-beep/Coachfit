import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/user_profile.dart';

const String profileBoxName = 'user_profile_box';
const String profileKey = 'current_profile';

/// Wraps the Hive box for UserProfile and exposes it as Riverpod state.
/// Any widget that "watches" this provider automatically rebuilds
/// whenever the profile changes — e.g. after a workout awards XP,
/// the dashboard's level/XP display updates itself with no extra code.
class ProfileRepository extends StateNotifier<UserProfile?> {
  ProfileRepository() : super(null) {
    _load(); // try to load an existing profile as soon as this is created
  }

  Box<UserProfile> get _box => Hive.box<UserProfile>(profileBoxName);

  void _load() {
    state = _box.get(profileKey);
  }

  /// Called at the end of onboarding, and any time profile fields change.
  Future<void> save(UserProfile profile) async {
    await _box.put(profileKey, profile);
    state = profile; // triggers rebuilds in anything watching this
  }

  /// Adds XP and handles leveling up (possibly multiple levels at once
  /// if a big XP reward crosses more than one threshold).
  Future<void> addXp(int amount) async {
    final profile = state;
    if (profile == null) return;

    profile.xp += amount;
    while (profile.xp >= profile.xpToNextLevel) {
      profile.xp -= profile.xpToNextLevel;
      profile.level += 1;
    }
    await profile.save(); // HiveObject's built-in save method
    state = profile;
  }

  /// Wipes the profile — used by "Reset & Restart Onboarding".
  Future<void> clear() async {
    await _box.delete(profileKey);
    state = null;
  }

  bool get hasCompletedOnboarding => state != null;
}

// This is what the rest of the app actually imports and uses:
// ref.watch(profileRepositoryProvider) to read the profile,
// ref.read(profileRepositoryProvider.notifier) to call methods on it.
final profileRepositoryProvider = StateNotifierProvider<ProfileRepository, UserProfile?>((ref) {
  return ProfileRepository();
});
