import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
enum FitnessLevel {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
}

@HiveType(typeId: 1)
enum PrimaryGoal {
  @HiveField(0)
  loseWeight,
  @HiveField(1)
  gainMuscle,
  @HiveField(2)
  buildDiscipline,
  @HiveField(3)
  improveHealth,
  @HiveField(4)
  increaseStrength,
  @HiveField(5)
  improveEndurance,
}

@HiveType(typeId: 2)
enum WorkoutLocation {
  @HiveField(0)
  home,
  @HiveField(1)
  gym,
}

@HiveType(typeId: 3)
class UserProfile extends HiveObject {
  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.fitnessLevel,
    required this.primaryGoal,
    required this.preferredWorkoutDays,
    required this.workoutLocation,
    required this.availableEquipment,
    required this.dailyReminderHour,
    required this.dailyReminderMinute,
    this.isGuest = false,
    this.level = 1,
    this.xp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  String gender;

  @HiveField(3)
  double heightCm;

  @HiveField(4)
  double weightKg;

  @HiveField(5)
  FitnessLevel fitnessLevel;

  @HiveField(6)
  PrimaryGoal primaryGoal;

  @HiveField(7)
  List<int> preferredWorkoutDays;

  @HiveField(8)
  WorkoutLocation workoutLocation;

  @HiveField(9)
  List<String> availableEquipment;

  @HiveField(10)
  int dailyReminderHour;

  @HiveField(11)
  int dailyReminderMinute;

  @HiveField(12)
  bool isGuest;

  @HiveField(13)
  int level;

  @HiveField(14)
  int xp;

  @HiveField(15)
  int currentStreak;

  @HiveField(16)
  int longestStreak;

  int get xpToNextLevel => 100 + (level - 1) * 50;

  double get levelProgress => (xp / xpToNextLevel).clamp(0, 1).toDouble();

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'fitnessLevel': fitnessLevel.name,
        'primaryGoal': primaryGoal.name,
        'preferredWorkoutDays': preferredWorkoutDays,
        'workoutLocation': workoutLocation.name,
        'availableEquipment': availableEquipment,
        'dailyReminderHour': dailyReminderHour,
        'dailyReminderMinute': dailyReminderMinute,
        'isGuest': isGuest,
        'level': level,
        'xp': xp,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String,
        age: json['age'] as int,
        gender: json['gender'] as String,
        heightCm: (json['heightCm'] as num).toDouble(),
        weightKg: (json['weightKg'] as num).toDouble(),
        fitnessLevel: FitnessLevel.values.byName(json['fitnessLevel'] as String),
        primaryGoal: PrimaryGoal.values.byName(json['primaryGoal'] as String),
        preferredWorkoutDays: (json['preferredWorkoutDays'] as List).cast<int>(),
        workoutLocation: WorkoutLocation.values.byName(json['workoutLocation'] as String),
        availableEquipment: (json['availableEquipment'] as List).cast<String>(),
        dailyReminderHour: json['dailyReminderHour'] as int,
        dailyReminderMinute: json['dailyReminderMinute'] as int,
        isGuest: json['isGuest'] as bool,
        level: json['level'] as int,
        xp: json['xp'] as int,
        currentStreak: json['currentStreak'] as int,
        longestStreak: json['longestStreak'] as int,
      );
}
