# RepChamp — Fitness Rep Counter App (Flutter + ML Kit + Supabase)

## Tech Stack
- **Framework:** Flutter (stable), Dart 3+
- **Pose Detection:** `google_mlkit_pose_detection`
- **Camera:** `camera` (Flutter team)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Backend:** Supabase (`supabase_flutter`) — Auth, Postgres, Realtime, RLS
- **Navigation:** `go_router`
- **Animations:** `flutter_animate`
- **Local Storage:** `shared_preferences`
- **Fonts:** Google Fonts (Inter/Poppins)

---

## Folder Structure

```
lib/
  main.dart
  app.dart

  core/
    theme/
      app_theme.dart
      app_colors.dart
    constants/
      pose_landmarks.dart
      exercise_thresholds.dart
    utils/
      angle_calculator.dart
      smoothing_buffer.dart

  models/
    pose_landmark_model.dart
    exercise_type.dart
    rep_session_model.dart
    duel_model.dart
    user_profile_model.dart

  services/
    pose_detection_service.dart
    rep_counter_engine.dart
    supabase/
      supabase_client.dart
      auth_service.dart
      profile_service.dart
      workout_service.dart
      duel_service.dart
      leaderboard_service.dart
    local/
      preferences_service.dart

  providers/
    pose_detection_provider.dart
    rep_counter_provider.dart
    duel_provider.dart
    auth_provider.dart
    user_profile_provider.dart

  screens/
    auth/
      login_screen.dart
      signup_screen.dart
    home/
      home_screen.dart
    workout/
      solo_workout_screen.dart
      workout_summary_screen.dart
    duel/
      duel_lobby_screen.dart
      duel_screen.dart
      duel_result_screen.dart
    leaderboard/
      leaderboard_screen.dart
    profile/
      profile_screen.dart

  widgets/
    camera/
      camera_preview_widget.dart
      skeleton_painter.dart
    common/
      rep_counter_display.dart
      duel_progress_bar.dart
      countdown_timer_widget.dart
      primary_button.dart

test/
  angle_calculator_test.dart
```

---

## Implementation Plan (10 Phases)

### Phase 1 — Project Setup
- Create Flutter project
- `pubspec.yaml` with all dependencies (exact versions)
- Folder structure with placeholder files (TODO comments)
- `main.dart` — `Supabase.initialize()`, `ProviderScope`, `MaterialApp.router`
- `app.dart` — `GoRouter` config with all routes, dark theme

### Phase 2 — Supabase Schema
- Single `.sql` file with:
  - All 5 tables (`profiles`, `workout_sessions`, `duel_rooms`, `duel_players`, `friendships`)
  - RLS policies for each table
  - Indexes for performance
  - Helper function for leaderboard (RPC)

### Phase 3 — Core Utils
- `angle_calculator.dart` — 3-point angle calculation + unit test
- `smoothing_buffer.dart` — moving average buffer (last N frames)
- `exercise_thresholds.dart` — angle thresholds for push-up / squat
- `pose_landmarks.dart` — landmark index constants

### Phase 4 — Pose Detection Service
- `pose_detection_service.dart` — ML Kit wrapper with camera input
- Frame throttling (every 3rd frame)
- Platform-specific `InputImage` conversion
- `pose_detection_provider.dart` — Riverpod provider exposing pose data stream

### Phase 5 — Rep Counter Engine
- State machine (`up → down → up` cycle)
- Per-exercise thresholds + smoothing buffer integration
- Low-likelihood frame filtering (<0.6)
- `rep_counter_provider.dart` — `StateNotifier<RepState>`

### Phase 6 — Skeleton Overlay
- `skeleton_painter.dart` — `CustomPainter` drawing landmarks + bones
- Coordinate transform (camera → screen)
- Green (#00FF66) accent, glow effects
- `camera_preview_widget.dart` — `Stack` with CameraPreview + SkeletonPainter

### Phase 7 — Solo Workout Screen
- Full-screen camera with skeleton overlay
- Rep counter display with pulse animation
- "Give Up" button + session end logic
- `workout_summary_screen.dart` — results after session

### Phase 8 — Auth & Profile
- `auth_service.dart` — signUp, signIn, signOut, currentUser
- `profile_service.dart` — CRUD for profiles table
- `login_screen.dart`, `signup_screen.dart` — auth UI
- Auth Riverpod providers

### Phase 9 — Duel Mode
- `duel_service.dart` — full CRUD + Realtime subscriptions
- `duel_lobby_screen.dart` — create / join rooms
- `duel_screen.dart` — split view: camera + opponent stats
- `duel_result_screen.dart` — winner/loser display
- 60s countdown timer, progress bars, live rep sync

### Phase 10 — Leaderboard & Profile
- `leaderboard_service.dart` — aggregate queries via Supabase RPC
- `leaderboard_screen.dart` — top players list
- `profile_screen.dart` — stats, streak, edit username

---

## Database Schema (Supabase PostgreSQL)

### Tables
1. **profiles** — extends `auth.users`
2. **workout_sessions** — solo workout history
3. **duel_rooms** — duel game rooms with status
4. **duel_players** — per-player rep tracking in duels
5. **friendships** — friend connections (pending/accepted)

### RLS Policies
- All tables: `enable row level security`
- `profiles`: read all, update own
- `workout_sessions`: read/write own only
- `duel_rooms` / `duel_players`: participants only
- `friendships`: involved users only

---

## Rep Counter State Machine

```
States: [up] → [down] → [up] (1 rep counted)
```

- **Push-up**: arms straight (≥160°) → arms bent (≤90°) → arms straight
- **Squat**: legs straight (≥160°) → legs bent (≤100°) → legs straight
- Smoothing: average of last 5 frames
- Minimum landmark likelihood: 0.6

---

## Color Palette
| Token | Hex |
|---|---|
| Background | `#0D0D0D` |
| Surface | `#1A1A1A` |
| Accent (P1) | `#00FF66` |
| Accent (P2) | `#3B82F6` |
| Text Primary | `#FFFFFF` |
| Text Secondary | `#9CA3AF` |

---

## Duel Flow
1. User A creates room → status=`waiting`
2. User B joins room → status=`waiting` → both `ready=true` → status=`active`
3. 60s timer starts, both stream `reps` via Realtime
4. When timer ends: status=`finished`, `winner_id` set
5. Result saved to `workout_sessions` for both
6. Both redirected to `duel_result_screen`
