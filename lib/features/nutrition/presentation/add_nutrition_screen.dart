import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../data/nutrition_repository.dart';
import '../domain/nutrition_entry.dart';

class AddNutritionScreen extends ConsumerStatefulWidget {
  const AddNutritionScreen({super.key});

  @override
  ConsumerState<AddNutritionScreen> createState() => _AddNutritionScreenState();
}

class _AddNutritionScreenState extends ConsumerState<AddNutritionScreen> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  MealType _mealType = MealType.breakfast;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final calories = int.tryParse(_caloriesController.text.trim());

    if (name.isEmpty || calories == null || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a name and a valid calorie count.')),
      );
      return;
    }

    ref.read(nutritionRepositoryProvider.notifier).addEntry(
          name: name,
          mealType: _mealType,
          calories: calories,
        );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Meal')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
                labelText: 'Food name', hintText: 'e.g. Grilled chicken salad'),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Meal', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            children: MealType.values.map((m) {
              return ChoiceChip(
                label: Text(m.name),
                selected: _mealType == m,
                onSelected: (_) => setState(() => _mealType = m),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Calories', hintText: 'e.g. 450'),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(onPressed: _save, child: const Text('Save meal')),
        ],
      ),
    );
  }
}
