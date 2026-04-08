import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/kasrrat_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Total Rep perform display
  int totalReps = 0;
  // Total Session completed display
  int totalSessions = 0;
  // Current Streak display
  int streakCount = 0;
  String favoriteExercise = "Loading...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // User Stats and Streaks logic
  Future<void> _fetchDashboardData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // User session fetching
      final List<dynamic> data = await Supabase.instance.client
          .from('workout_sessions')
          .select()
          .eq('user_id', user.id);

      if (data.isNotEmpty) {
        int repsSum = 0;
        Map<String, int> counts = {};

        // Process sessions for stats
        for (var row in data) {
          repsSum += (row['reps_completed'] as int);
          String name = row['exercise_name'];
          counts[name] = (counts[name] ?? 0) + 1;
        }

        // Streak calculation
        final workoutDays = data.map((d) {
          DateTime date = DateTime.parse(d['created_at']).toLocal();
          return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        }).toSet();

        int count = 0;
        DateTime checkDate = DateTime.now();
        String todayStr =
            "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";

        DateTime streakCheck = workoutDays.contains(todayStr)
            ? checkDate
            : checkDate.subtract(const Duration(days: 1));
        while (workoutDays.contains(
          "${streakCheck.year}-${streakCheck.month.toString().padLeft(2, '0')}-${streakCheck.day.toString().padLeft(2, '0')}",
        )) {
          count++;
          streakCheck = streakCheck.subtract(const Duration(days: 1));
        }

        // Most practised exercise display
        var sortedExercises = counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (mounted) {
          setState(() {
            totalReps = repsSum;
            totalSessions = data.length;
            streakCount = count;
            favoriteExercise = sortedExercises.first.key;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Dashboard Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Weekly user goal
    const int weeklyGoal = 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Performance Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: streakCount > 0
                              ? Colors.orangeAccent
                              : Colors.grey,
                          size: 40,
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$streakCount Day Streak",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              "Keep up the momentum!",
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  // User Stats Card
                  Row(
                    children: [
                      _buildStatCard(
                        "Total Reps",
                        totalReps.toString(),
                        Icons.fitness_center_rounded,
                      ),
                      const SizedBox(width: 15),
                      _buildStatCard(
                        "Sessions",
                        totalSessions.toString(),
                        Icons.history,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  // Most Practiced exercise card
                  _buildSectionHeader("Most Practiced"),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 40,
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              favoriteExercise,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              "Your top exercise",
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  // Weekly goal Stats card
                  _buildSectionHeader("Weekly Goal"),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    // progress report calculation
                    value: (totalReps / weeklyGoal).clamp(0.0, 1.0),
                    backgroundColor: AppColors.surfaceGrey,
                    color: AppColors.primary,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${(totalReps / weeklyGoal * 100).toInt()}% of weekly goal completed",
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
  // Reuable stat card widget
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 15),
            Text(
              value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
