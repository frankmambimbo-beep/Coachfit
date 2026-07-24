import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/user_profile.dart';

/// Multi-step onboarding wizard. Collects every field from the product
/// brief (name, body stats, fitness level, goal, workout days/location/
/// equipment, reminder time), then saves a UserProfile to Hive and
/// routes into the dashboard.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key, this.isGuest = false});

  final bool isGuest;

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  // PageController drives the swipeable step-by-step form
  final _pageController = PageController();
  int _step = 0;
  static const int _totalSteps = 6;

  // Text controllers hold the live value typed into each text field
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Everything else is stored directly as local state
  String _gender = 'Female';
  FitnessLevel _fitnessLevel = FitnessLevel.beginner;
  PrimaryGoal _goal = PrimaryGoal.buildDiscipline;
  final Set<int> _workoutDays = {1, 3, 5}; // Mon/Wed/Fri by default
  WorkoutLocation _location = WorkoutLocation.home;
  final Set<String> _equipment = {};
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  void dispose() {
    // Always dispose controllers to avoid memory leaks
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageController.nextPage(duration: AppDurations.medium, curve: Curves.easeOutCubic);
    } else {
      _finish(); // last step — save everything and move on
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(duration: AppDurations.medium, curve: Curves.easeOutCubic);
    } else {
      context.pop(); // leave onboarding entirely if on the first step
    }
  }

  Future<void> _finish() async {
    final profile = UserProfile(
      name: _nameController.text.trim().isEmpty ? 'Athlete' : _nameController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 25,
      gender: _gender,
      heightCm: double.tryParse(_heightController.text) ?? 170,
      weightKg: double.tryParse(_weightController.text) ?? 70,
      fitnessLevel: _fitnessLevel,
      primaryGoal: _goal,
      preferredWorkoutDays: _workoutDays.toList()..sort(),
      workoutLocation: _location,
      availableEquipment: _equipment.toList(),
      dailyReminderHour: _reminderTime.hour,
      dailyReminderMinute: _reminderTime.minute,
      isGuest: widget.isGuest,
    );
    await ref.read(profileRepositoryProvider.notifier).save(profile);
    if (mounted) context.go('/dashboard');
  }

  // Disables the Continue button until the current step has valid input
  bool get _canAdvance {
    switch (_step) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _ageController.text.isNotEmpty && _heightController.text.isNotEmpty && _weightController.text.isNotEmpty;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            _StepProgress(step: _step, totalSteps: _totalSteps),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: PageView(
                controller: _pageController,
                // Prevents swiping directly — forces use of the button
                // so we can validate each step before advancing
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _NameStep(controller: _nameController, onChanged: () => setState(() {})),
                  _BodyStatsStep(
                    ageController: _ageController,
                    heightController: _heightController,
                    weightController: _weightController,
                    gender: _gender,
                    onGenderChanged: (g) => setState(() => _gender = g),
                    onChanged: () => setState(() {}),
                  ),
                  _FitnessLevelStep(selected: _fitnessLevel, onSelected: (v) => setState(() => _fitnessLevel = v)),
                  _GoalStep(selected: _goal, onSelected: (v) => setState(() => _goal = v)),
                  _WorkoutSetupStep(
                    workoutDays: _workoutDays,
                    location: _location,
                    equipment: _equipment,
                    onLocationChanged: (v) => setState(() => _location = v),
                    onDayToggled: (d) => setState(() {
                      _workoutDays.contains(d) ? _workoutDays.remove(d) : _workoutDays.add(d);
                    }),
                    onEquipmentToggled: (e) => setState(() {
                      _equipment.contains(e) ? _equipment.remove(e) : _equipment.add(e);
                    }),
                  ),
                  _ReminderStep(time: _reminderTime, onTimeChanged: (t) => setState(() => _reminderTime = t)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: ElevatedButton(
                onPressed: _canAdvance ? _next : null, // null disables the button
                child: Text(_step == _totalSteps - 1 ? 'Finish Setup' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Small helper widgets used only within this file ---

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step, required this.totalSteps});
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final active = i <= step;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 4,
            decoration: BoxDecoration(
              color: active ? AppColors.accentPrimary : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        );
      }),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.title, this.subtitle);
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle("What's your name?", "We'll use this to personalize your coaching."),
          TextField(
            controller: controller,
            onChanged: (_) => onChanged(), // re-checks _canAdvance on every keystroke
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Your name'),
          ),
        ],
      ),
    );
  }
}

class _BodyStatsStep extends StatelessWidget {
  const _BodyStatsStep({
    required this.ageController,
    required this.heightController,
    required this.weightController,
    required this.gender,
    required this.onGenderChanged,
    required this.onChanged,
  });

  final TextEditingController ageController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final String gender;
  final ValueChanged<String> onGenderChanged;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('Tell us about your body', 'This helps us tailor workouts and calorie estimates.'),
          TextField(
            controller: ageController,
            onChanged: (_) => onChanged(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Age'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: ['Male', 'Female', 'Other'].map((g) {
              final selected = gender == g;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(label: Text(g), selected: selected, onSelected: (_) => onGenderChanged(g)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: heightController,
            onChanged: (_) => onChanged(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Height (cm)'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: weightController,
            onChanged: (_) => onChanged(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Weight (kg)'),
          ),
        ],
      ),
    );
  }
}

class _FitnessLevelStep extends StatelessWidget {
  const _FitnessLevelStep({required this.selected, required this.onSelected});
  final FitnessLevel selected;
  final ValueChanged<FitnessLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('Fitness level', 'Be honest — this shapes your starting plan.'),
          // Loops over every enum value so adding a new FitnessLevel
          // later automatically shows up here with no extra code.
          ...FitnessLevel.values.map((level) => _SelectableTile(
                label: level.name[0].toUpperCase() + level.name.substring(1),
                selected: selected == level,
                onTap: () => onSelected(level),
              )),
        ],
      ),
    );
  }
}

// Shared between this file and the profile screen, so it's public (no underscore)
const Map<PrimaryGoal, String> goalLabels = {
  PrimaryGoal.loseWeight: 'Lose Weight',
  PrimaryGoal.gainMuscle: 'Gain Muscle',
  PrimaryGoal.buildDiscipline: 'Build Discipline',
  PrimaryGoal.improveHealth: 'Improve Health',
  PrimaryGoal.increaseStrength: 'Increase Strength',
  PrimaryGoal.improveEndurance: 'Improve Endurance',
};

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.selected, required this.onSelected});
  final PrimaryGoal selected;
  final ValueChanged<PrimaryGoal> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('Primary goal', 'What matters most to you right now?'),
          ...goalLabels.entries.map((e) => _SelectableTile(
                label: e.value,
                selected: selected == e.key,
                onTap: () => onSelected(e.key),
              )),
        ],
      ),
    );
  }
}

const List<String> weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> equipmentOptions = ['None (bodyweight)', 'Dumbbells', 'Resistance Bands', 'Pull-up Bar', 'Full Gym'];

class _WorkoutSetupStep extends StatelessWidget {
  const _WorkoutSetupStep({
    required this.workoutDays,
    required this.location,
    required this.equipment,
    required this.onLocationChanged,
    required this.onDayToggled,
    required this.onEquipmentToggled,
  });

  final Set<int> workoutDays;
  final WorkoutLocation location;
  final Set<String> equipment;
  final ValueChanged<WorkoutLocation> onLocationChanged;
  final ValueChanged<int> onDayToggled;
  final ValueChanged<String> onEquipmentToggled;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('Your workout setup', 'Pick your days, location, and equipment.'),
          Wrap(
            spacing: AppSpacing.sm,
            children: List.generate(7, (i) {
              final day = i + 1; // 1 = Monday
              return ChoiceChip(label: Text(weekdayLabels[i]), selected: workoutDays.contains(day), onSelected: (_) => onDayToggled(day));
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: WorkoutLocation.values.map((loc) {
              final selected = location == loc;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(loc == WorkoutLocation.home ? 'Home' : 'Gym'),
                    selected: selected,
                    onSelected: (_) => onLocationChanged(loc),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Equipment available', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: equipmentOptions.map((eq) => FilterChip(label: Text(eq), selected: equipment.contains(eq), onSelected: (_) => onEquipmentToggled(eq))).toList(),
          ),
        ],
      ),
    );
  }
}

class _ReminderStep extends StatelessWidget {
  const _ReminderStep({required this.time, required this.onTimeChanged});
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('Daily reminder', 'When should we nudge you each day?'),
          Center(
            child: GestureDetector(
              onTap: () async {
                // showTimePicker returns null if the user cancels
                final picked = await showTimePicker(context: context, initialTime: time);
                if (picked != null) onTimeChanged(picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Text(time.format(context), style: Theme.of(context).textTheme.headlineMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentPrimary.withOpacity(0.15) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: selected ? AppColors.accentPrimary : Colors.transparent, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
              if (selected) const Icon(Icons.check_circle, color: AppColors.accentPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
