import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../providers/podcast_providers.dart';

class GenreChipList extends ConsumerWidget {
  const GenreChipList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genres = ref.watch(allGenresProvider);
    final selectedGenre = ref.watch(selectedGenreProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (genres.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: genres.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedGenre == null;
            return _buildChip(
              context: context,
              label: 'All',
              isSelected: isSelected,
              isDark: isDark,
              onTap: () =>
                  ref.read(selectedGenreProvider.notifier).select(null),
            )
                .animate()
                .fadeIn(delay: (index * 40).ms, duration: 300.ms)
                .slideX(begin: -0.2, end: 0, duration: 300.ms);
          }

          final genre = genres[index - 1];
          final isSelected = selectedGenre == genre.id;
          return _buildChip(
            context: context,
            label: genre.name,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () => ref.read(selectedGenreProvider.notifier).select(
                isSelected ? null : genre.id),
          )
              .animate()
              .fadeIn(delay: (index * 40).ms, duration: 300.ms)
              .slideX(begin: -0.2, end: 0, duration: 300.ms);
        },
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: isDark
            ? AppColors.primary.withAlpha(60)
            : AppColors.primary.withAlpha(30),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? AppColors.primary.withAlpha(80)
                : Colors.transparent,
          ),
        ),
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
