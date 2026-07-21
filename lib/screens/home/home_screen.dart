import 'package:flutter/material.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'FITDUEL',
                style: TextStyle(
                  fontFamily: 'ArchivoNarrow',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6CFF80),
                  letterSpacing: -0.01,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6CFF80).withAlpha(80), width: 4),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Color(0xFF6CFF80),
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FitDuelBottomNav(activeTab: NavTab.home),
    );
  }
}
