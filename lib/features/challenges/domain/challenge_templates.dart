import 'challenge.dart';

// A fixed catalog of challenges the user can join. Plain Dart objects —
// not stored in Hive, since the catalog itself never changes per-user
// (only the Challenge instances a user joins get persisted).
class ChallengeTemplate {
  final String id;
  final String title;
  final String description;
  final ChallengeCategory category;
  final int durationDays;
  final int xpReward;

  const ChallengeTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationDays,
    required this.xpReward,
  });
}

const List<ChallengeTemplate> challengeCatalog = [
  ChallengeTemplate(
    id: 'water_7',
    title: '7-Day Hydration Challenge',
    description: 'Check in every day for a week to build a water-drinking habit.',
    category: ChallengeCategory.nutrition,
    durationDays: 7,
    xpReward: 70,
  ),
  ChallengeTemplate(
    id: 'move_7',
    title: '7-Day Movement Streak',
    description: 'Do some form of physical activity every day for a week.',
    category: ChallengeCategory.fitness,
    durationDays: 7,
    xpReward: 100,
  ),
  ChallengeTemplate(
    id: 'discipline_14',
    title: '14-Day No Excuses',
    description: 'Show up for yourself daily for two weeks straight — no skipped days.',
    category: ChallengeCategory.discipline,
    durationDays: 14,
    xpReward: 200,
  ),
  ChallengeTemplate(
    id: 'mind_10',
    title: '10-Day Mindfulness Reset',
    description: 'A short daily mindfulness check-in for 10 days.',
    category: ChallengeCategory.mindfulness,
    durationDays: 10,
    xpReward: 120,
  ),
  ChallengeTemplate(
    id: 'move_30',
    title: '30-Day Consistency Challenge',
    description: 'The big one — a full month of daily check-ins.',
    category: ChallengeCategory.fitness,
    durationDays: 30,
    xpReward: 400,
  ),
];
