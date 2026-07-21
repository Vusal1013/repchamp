import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum NavTab { home, leaderboard, duel, profile }

class FitDuelBottomNav extends StatelessWidget {
  final NavTab activeTab;

  const FitDuelBottomNav({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        border: const Border(
          top: BorderSide(color: Color(0xFF353534)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF39FF6A).withAlpha(38),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(context, Icons.home_rounded, NavTab.home, '/home'),
              _item(context, Icons.leaderboard_rounded, NavTab.leaderboard, '/leaderboard'),
              _item(context, Icons.fitness_center_rounded, NavTab.duel, '/duel/lobby'),
              _item(context, Icons.person_rounded, NavTab.profile, '/profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, NavTab tab, String route) {
    final isActive = tab == activeTab;

    return GestureDetector(
      onTap: isActive ? null : () => context.go(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF39FF6A).withAlpha(51)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF39FF6A).withAlpha(102),
                    blurRadius: 15,
                  ),
                ]
              : null,
        ),
        child: Transform.scale(
          scale: isActive ? 1.1 : 1.0,
          child: Icon(
            icon,
            color: isActive
                ? const Color(0xFF6CFF80)
                : const Color(0xFFBACBB6),
            size: 28,
          ),
        ),
      ),
    );
  }
}
