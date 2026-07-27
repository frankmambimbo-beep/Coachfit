import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../domain/challenge.dart';
import '../domain/challenge_templates.dart';
import '../../profile/data/profile_repository.dart';

const String challengesBoxName = 'challengesBox';

final challengesRepositoryProvider =
    StateNotifierProvider<ChallengesRepository, List<Challenge>>((ref) {
  return ChallengesRepository(ref);
});

class ChallengesRepository extends StateNotifier<List<Challenge>> {
  final Ref ref;
  late Box<Challenge> _box;

  ChallengesRepository(this.ref) : super([]) {
    _init();
  }

  void _init() {
    _box = Hive.box<Challenge>(challengesBoxName);
    state = _box.values.toList();
  }

  bool isJoined(String templateId) =>
      state.any((c) => c.templateId == templateId && !c.completed && !c.isExpired);

  Future<void> joinChallenge(ChallengeTemplate template) async {
    if (isJoined(template.id)) return;

    final challenge = Challenge(
      id: const Uuid().v4(),
      templateId: template.id,
      title: template.title,
      category: template.category,
      durationDays: template.durationDays,
      startedAt: DateTime.now(),
      xpReward: template.xpReward,
    );
    await _box.put(challenge.id, challenge);
    state = _box.values.toList();
  }

  Future<void> leaveChallenge(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }

  // Marks today as checked in. Awards XP exactly once, the moment the
  // challenge's full duration is reached.
  Future<void> checkInToday(String id) async {
    final challenge = _box.get(id);
    if (challenge == null || challenge.completed) return;

    final today = Challenge.dateOnly(DateTime.now());
    final already = challenge.checkIns.any((d) => Challenge.dateOnly(d) == today);
    if (already) return;

    challenge.checkIns.add(today);

    if (challenge.checkIns.length >= challenge.durationDays) {
      challenge.completed = true;
      ref.read(profileRepositoryProvider.notifier).addXp(challenge.xpReward);
    }

    await challenge.save();
    state = _box.values.toList();
  }
}
