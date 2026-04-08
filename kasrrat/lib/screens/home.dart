import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../core/kasrrat_colors.dart';
// Navigation from exercise card to GetReadyScreen
import 'get_ready_screen.dart'; 
// Edit profile screen import
import 'edit_profile_screen.dart'; 
// Dashboard screen import
import 'dashboard_screen.dart';

// dynamic data handling
class HomeScreen extends StatefulWidget { 
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables for real-time streak data
  int streakCount = 0; 
  Set<String> workoutDays = {}; 

  @override
  void initState() {
    super.initState();
    _fetchUserStreak(); // Fetch user data on load
  }

  // Streak calculation logic
  Future<void> _fetchUserStreak() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Fetching all workout dates for this user from the supabase table
      final List<dynamic> data = await Supabase.instance.client
          .from('workout_sessions')
          .select('created_at')
          .eq('user_id', user.id);

      // Converting timestamps to unique YYYY-MM-DD dates with proper 0-padding
      final processedDays = data.map((d) {
        DateTime date = DateTime.parse(d['created_at']).toLocal();
        return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }).toSet();

      // consecutive days calculation logic
      int count = 0;
      DateTime today = DateTime.now();
      String todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // If worked out today, start from today. Otherwise, check if yesterday was part of a streak.
      DateTime checkDate = processedDays.contains(todayStr) ? today : today.subtract(const Duration(days: 1));
      
      while (processedDays.contains("${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}")) {
        count++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      if (mounted) {
        setState(() {
          streakCount = count;
          workoutDays = processedDays; // highlights circles for streak 
        });
      }
    } catch (e) {
      debugPrint("Error calculating streak: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current user from Supabase
    final user = Supabase.instance.client.auth.currentUser;

    // Get the username
    final String userName = user?.userMetadata?['full_name'] ?? "User";

    // Date display logic for the weekly circles
    final List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final DateTime now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Text("Hello, $userName!", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
      ),
      body: RefreshIndicator( // pull-to-refresh for streak update
        onRefresh: _fetchUserStreak,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), 
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User progress 
              // Dynamic Streak Counter
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    // Flame / Streak Count
                    Column(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded, 
                          color: streakCount > 0 ? Colors.orangeAccent : Colors.grey, 
                          size: 45
                        ),
                        Text(
                          "$streakCount", 
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                      ],
                    ),
                    const SizedBox(width: 25),
                    
                    // Weekly Calendar View
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your streak", 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (index) {
                              // Current Week days display
                              DateTime dayDate = now.subtract(Duration(days: now.weekday - 1 - index));
                              String dateKey = "${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}";
                              
                              bool isToday = dayDate.day == now.day && dayDate.month == now.month;
                              bool hasWorkout = workoutDays.contains(dateKey); // NEW: Checks if this specific day has data

                              return Column(
                                children: [
                                  // Date Circle
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isToday ? AppColors.primary : (hasWorkout ? AppColors.primary.withValues(alpha: 0.5) : Colors.white24),
                                        width: 1.5
                                      ),
                                      // Blue Circle if a workout exists for that day
                                      color: hasWorkout ? AppColors.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${dayDate.day}",
                                        style: TextStyle(
                                          color: hasWorkout || isToday ? Colors.white : Colors.white38,
                                          fontSize: 12,
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Day Label
                                  Text(
                                    weekDays[index],
                                    style: TextStyle(
                                      color: isToday ? Colors.white : AppColors.textGrey,
                                      fontSize: 11,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              const Text("Choose your workout for today", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Workout Grid
              GridView.count(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                crossAxisCount: 2, // 2 exercise per row
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  // adding Icons images to the exercise cards
                  _workoutCard(context, "Squats", "assets/icons/Squats_icon.png"),
                  _workoutCard(context, "Pushups", "assets/icons/PushUp_icon.png"),
                  _workoutCard(context, "Lateral Raises", "assets/icons/LateralRaises_icon.png"),
                  _workoutCard(context, "Bicep Curls", "assets/icons/BicepsCurls_icon.png"),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      // footer logic
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surfaceGrey,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        currentIndex: 1, // active Screen Home page
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Navigate to Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else if (index == 2) {
            // Navigate to Edit Profile
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          }
        },
      ),
    );
  }

  // workout card build function
  // ImagePath parameter
  Widget _workoutCard(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GetReadyScreen(exerciseName: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using Image.asset to display images
            Image.asset(
              imagePath,
              width: 60, // icon size
              height: 60,
              // icon color
              color: AppColors.primary, 
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(height: 15),
            Text(
              title, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ],
        ),
      ),
    );
  }
}