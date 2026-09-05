import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _importController = TextEditingController();
  bool _isRestoring = false;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final json = BackupService.exportAsString();
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup copied to clipboard — paste it somewhere safe (notes, email to yourself, etc.)'),
      ),
    );
  }

  Future<void> _confirmAndRestore() async {
    final text = _importController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste your backup text first.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text(
          'This will REPLACE all current data on this device — habits, goals, '
          'workouts, everything — with what\'s in the pasted backup. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Replace everything', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);
    try {
      await BackupService.restoreFromJson(text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restored. Restart the app to see all changes.')),
      );
      _importController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not restore: this doesn\'t look like a valid CoachFit backup.')),
      );
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.upload_outlined, color: AppColors.accentPrimary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Export',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Copies all your data — profile, habits, goals, workouts, nutrition, mood, everything — to your clipboard as text. Paste it somewhere safe, like a notes app or an email to yourself.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(onPressed: _export, child: const Text('Export & copy to clipboard')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.download_outlined, color: AppColors.danger),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Restore',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Paste a previously exported backup below. This REPLACES all current data on this device.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _importController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Paste your backup text here',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                  onPressed: _isRestoring ? null : _confirmAndRestore,
                  child: _isRestoring
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Restore from pasted backup'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
