import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_sizes.dart';

class BottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      items: [
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.squares2x2,
            size: AppSizes.iconMd,
            color: AppColors.onSurfaceVariant,
          ),
          activeIcon: HeroIcon(
            HeroIcons.squares2x2,
            size: AppSizes.iconMd,
            color: AppColors.primary,
          ),
          label: AppStrings.navGoals,
        ),
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.bell,
            size: AppSizes.iconMd,
            color: AppColors.onSurfaceVariant,
          ),
          activeIcon: HeroIcon(
            HeroIcons.bell,
            size: AppSizes.iconMd,
            color: AppColors.primary,
          ),
          label: AppStrings.navNotifications,
        ),
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.sparkles,
            size: AppSizes.iconMd,
            color: AppColors.onSurfaceVariant,
          ),
          activeIcon: HeroIcon(
            HeroIcons.sparkles,
            size: AppSizes.iconMd,
            color: AppColors.primary,
          ),
          label: AppStrings.navStart,
        ),
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.users,
            size: AppSizes.iconMd,
            color: AppColors.onSurfaceVariant,
          ),
          activeIcon: HeroIcon(
            HeroIcons.users,
            size: AppSizes.iconMd,
            color: AppColors.primary,
          ),
          label: AppStrings.navFriends,
        ),
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.user,
            size: AppSizes.iconMd,
            color: AppColors.onSurfaceVariant,
          ),
          activeIcon: HeroIcon(
            HeroIcons.user,
            size: AppSizes.iconMd,
            color: AppColors.primary,
          ),
          label: AppStrings.navProfile,
        ),
      ],
    );
  }
}
