import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/supabase/leaderboard_service.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final service = LeaderboardService();
  return service.getLeaderboard(limit: 20);
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: leaderboard.when(
                data: (entries) => _buildBody(entries),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6CFF80)),
                ),
                error: (_, __) => const Center(
                  child: Text(
                    'Failed to load leaderboard',
                    style: TextStyle(color: Color(0xFFFFB4AB)),
                  ),
                ),
              ),
            ),
            const FitDuelBottomNav(activeTab: NavTab.leaderboard),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        border: Border(
          bottom: BorderSide(color: Color(0xFF353534)),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF6CFF80), width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const Icon(Icons.person, size: 22, color: Color(0xFF6CFF80)),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6CFF80),
                        border: Border.all(color: const Color(0xFF131313), width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Text(
                'FITDUEL',
                style: TextStyle(
                  fontFamily: 'ArchivoNarrow',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.01,
                  color: const Color(0xFF6CFF80),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '12🔥',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6CFF80),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Body ────────────────────────────────────────
  Widget _buildBody(List<LeaderboardEntry> entries) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          child: Column(
            children: [
              _buildTabs(),
              const SizedBox(height: 32),
              _buildPodium(entries),
              const SizedBox(height: 32),
              _buildRankedList(entries),
            ],
          ),
        ),
        // User position sticky footer
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _buildUserFooter(),
        ),
      ],
    );
  }

  // ─── Tabs ────────────────────────────────────────
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF6CFF80).withAlpha(51),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF6CFF80).withAlpha(77)),
              ),
              child: Text(
                'GLOBAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF007226),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'FRIENDS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFBACBB6),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'WEEKLY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFBACBB6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Podium ──────────────────────────────────────
  Widget _buildPodium(List<LeaderboardEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final top3 = <LeaderboardEntry?>[
      entries.length > 1 ? entries[1] : null, // 2nd
      entries.isNotEmpty ? entries[0] : null,  // 1st
      entries.length > 2 ? entries[2] : null,  // 3rd
    ];

    final colors = [const Color(0xFFC0C0C0), const Color(0xFF6CFF80), const Color(0xFFCD7F32)];
    final labels = ['2ND', '1ST', '3RD'];
    final sizes = [16.0, 24.0, 16.0]; // avatar sizes
    final borderWidth = [2.0, 4.0, 2.0];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        final entry = top3[i];
        if (entry == null) return const Expanded(child: SizedBox.shrink());

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: i == 1 ? 0 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: sizes[i] * 4,
                  height: sizes[i] * 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors[i], width: borderWidth[i]),
                    boxShadow: i == 1
                        ? [BoxShadow(color: const Color(0xFF39FF6A).withAlpha(77), blurRadius: 30)]
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: entry.avatarUrl != null
                      ? null
                      : Icon(Icons.person, size: sizes[i] * 1.5, color: colors[i]),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors[i],
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0E0E0E),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.username,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: i == 1 ? const Color(0xFF6CFF80) : const Color(0xFFE5E2E1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatXp(entry.totalReps),
                  style: TextStyle(
                    fontFamily: 'ArchivoNarrow',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: colors[i],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── Ranked List ─────────────────────────────────
  Widget _buildRankedList(List<LeaderboardEntry> entries) {
    final listEntries = entries.length > 3 ? entries.sublist(3) : <LeaderboardEntry>[];

    return Column(
      children: List.generate(listEntries.length, (i) {
        final entry = listEntries[i];
        final rank = i + 4;
        final xp = _computeXp(entry.totalReps, entry.level);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFBACBB6),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF353534)),
                ),
                clipBehavior: Clip.antiAlias,
                child: const Icon(Icons.person, size: 22, color: Color(0xFFBACBB6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.username,
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE5E2E1),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatReps(entry.totalReps)} REPS',
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFFBACBB6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatXp(xp),
                    style: TextStyle(
                      fontFamily: 'ArchivoNarrow',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE5E2E1),
                    ),
                  ),
                  Text(
                    'XP',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6CFF80),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─── User Footer ─────────────────────────────────
  Widget _buildUserFooter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF6CFF80),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF39FF6A).withAlpha(128),
              blurRadius: 25,
            ),
          ],
          border: Border.all(color: const Color(0xFF00E556)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00390F),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '#42',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6CFF80),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOU',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00390F),
                  ),
                ),
                Text(
                  'TOP 12% THIS WEEK',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00390F).withAlpha(204),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '12,400',
                  style: TextStyle(
                    fontFamily: 'ArchivoNarrow',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00390F),
                  ),
                ),
                Text(
                  'TOTAL XP',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00390F).withAlpha(204),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────
  int _computeXp(int totalReps, int level) {
    return level * 500 + totalReps;
  }

  String _formatXp(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }

  String _formatReps(int reps) {
    if (reps >= 1000) {
      final parts = reps.toString().split('');
      final result = StringBuffer();
      for (int i = 0; i < parts.length; i++) {
        if (i > 0 && (parts.length - i) % 3 == 0) result.write(',');
        result.write(parts[i]);
      }
      return result.toString();
    }
    return reps.toString();
  }
}
