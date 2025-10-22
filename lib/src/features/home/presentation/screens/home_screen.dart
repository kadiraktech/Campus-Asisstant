import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:projectv1/src/core/theme/theme_provider.dart'; // Import ThemeProvider
import 'package:projectv1/src/features/auth/presentation/screens/login_screen.dart'; // For navigation back to login
import 'package:projectv1/src/features/course_schedule/presentation/screens/course_list_screen.dart'; // Import CourseListScreen
import 'package:projectv1/src/features/course_schedule/presentation/screens/calendar_screen.dart'; // Import CalendarScreen
import 'package:projectv1/src/features/task_management/presentation/screens/task_list_screen.dart';
import 'package:projectv1/src/features/settings/presentation/screens/settings_screen.dart'; // Import SettingsScreen
// For date and day formatting
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectv1/src/features/course_schedule/domain/models/course_model.dart';
// Import AddEditTaskScreen
// Import EditProfileScreen
import 'package:projectv1/src/features/weather/domain/models/weather_forecast_model.dart'; // Import WeatherForecast model
import 'package:projectv1/src/features/weather/domain/services/weather_service.dart'; // Import WeatherService
import 'package:projectv1/src/features/user_profile/domain/services/user_profile_service.dart'; // Import UserProfileService
import 'package:projectv1/src/features/user_profile/domain/models/user_profile_model.dart'; // Import UserProfile for city
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:shared_preferences/shared_preferences.dart'; // For caching
// Ensure this import exists for AddEditCourseScreen
import 'package:projectv1/src/features/course_schedule/presentation/screens/weekly_schedule_screen.dart'; // Import WeeklyScheduleScreen
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'package:intl/intl.dart'; // For date formatting
import 'package:projectv1/src/features/task_management/domain/models/task_model.dart'; // Ensure Task model is imported
// Import AddEditTaskScreen
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Import curved_navigation_bar
import 'package:projectv1/src/features/weather/presentation/screens/five_day_forecast_screen.dart'; // Import the new screen
import 'package:projectv1/src/features/user_profile/presentation/screens/view_profile_screen.dart'; // Import ViewProfileScreen
import 'package:projectv1/src/core/providers/default_city_provider.dart'; // Import DefaultCityProvider
// For ImageFilter
import 'dart:math' as math; // Add for min function
import 'package:projectv1/src/features/course_schedule/presentation/screens/course_detail_screen.dart'; // Import CourseDetailScreen
import 'package:projectv1/src/features/task_management/presentation/screens/add_edit_task_screen.dart'; // Import AddEditTaskScreen

// Import AppLocalizations using the new path
import 'package:projectv1/generated/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Default to the first tab (Dashboard/Home)
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final UserProfileService _userProfileService =
      UserProfileService(); // Initialize UserProfileService
  late WeatherService _weatherService; // Declare WeatherService

  WeatherForecast? _weatherForecast;
  bool _isLoadingWeather = false;
  String? _weatherError;
  String?
  _currentCityFromProvider; // To store city from provider and detect changes

  // State for course expansion
  bool _coursesExpanded = false;

  // State for task expansion
  bool _tasksExpanded = false;

  // For dashboard weather
  static const String _weatherCacheKeyPrefix = 'weather_cache_';
  static const Duration _weatherCacheDuration = Duration(hours: 1);

  // Helper method to get a stream of upcoming courses
  Stream<List<Course>> _getUpcomingCoursesStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }
    DateTime now = DateTime.now();
    // Define today and the day after tomorrow at midnight for filtering
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    DateTime dayAfterTomorrowStart = DateTime(
      now.year,
      now.month,
      now.day + 2,
    ); // Courses within today and tomorrow

    return FirebaseFirestore.instance
        .collection('courses')
        .where('userId', isEqualTo: _currentUser.uid)
        .snapshots()
        .map((snapshot) {
          List<Course> allUserCourses =
              snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();

          // Filter for courses that are upcoming WITHIN THE NEXT 2 DAYS
          List<Course> upcomingCourses =
              allUserCourses.where((course) {
                final dayOrder = [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday',
                ];
                int courseDayIndex = dayOrder.indexOf(course.dayOfWeek);
                if (courseDayIndex == -1) return false; // Should not happen

                // Calculate the date of the next occurrence of this course day
                DateTime nextCourseDate = todayStart;
                while (nextCourseDate.weekday != courseDayIndex + 1) {
                  nextCourseDate = nextCourseDate.add(const Duration(days: 1));
                }

                // Check if this next occurrence is within the next 2 days (inclusive of today)
                if (nextCourseDate.isBefore(dayAfterTomorrowStart)) {
                  // Also check time if it's today
                  if (nextCourseDate.isAtSameMomentAs(todayStart)) {
                    TimeOfDay courseStartTime = TimeOfDay(
                      hour: int.parse(course.startTime.split(':')[0]),
                      minute: int.parse(course.startTime.split(':')[1]),
                    );
                    TimeOfDay nowTime = TimeOfDay.fromDateTime(now);
                    return courseStartTime.hour > nowTime.hour ||
                        (courseStartTime.hour == nowTime.hour &&
                            courseStartTime.minute >= nowTime.minute);
                  }
                  return true; // Course is tomorrow or later today
                }

                return false; // Not within the next 2 days
              }).toList();

          // Sort them by day and then by time (using the calculated next date)
          upcomingCourses.sort((a, b) {
            final dayOrder = [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday',
            ];
            int dayCompare = dayOrder
                .indexOf(a.dayOfWeek)
                .compareTo(dayOrder.indexOf(b.dayOfWeek));
            // Adjust comparison based on proximity to 'now'
            DateTime dateA = todayStart;
            while (dateA.weekday != dayOrder.indexOf(a.dayOfWeek) + 1) {
              dateA = dateA.add(const Duration(days: 1));
            }
            DateTime dateB = todayStart;
            while (dateB.weekday != dayOrder.indexOf(b.dayOfWeek) + 1) {
              dateB = dateB.add(const Duration(days: 1));
            }

            int dateCompare = dateA.compareTo(dateB);
            if (dateCompare != 0) return dateCompare;

            // If same day, compare by time
            return a.startTime.compareTo(b.startTime);
          });

          // No need to limit here, we'll limit in the UI based on expansion state
          // return upcomingCourses.take(3).toList();
          return upcomingCourses;
        });
  }

  // Helper method to get a stream of upcoming tasks
  Stream<List<Task>> _getUpcomingTasksStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }
    DateTime today = DateTime.now();

    return FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: _currentUser.uid)
        .where('isCompleted', isEqualTo: false) // Only fetch incomplete tasks
        .where(
          'dueDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(today.year, today.month, today.day),
          ),
        )
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => Task.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService();
    if (_currentUser != null) {
      // _fetchInitialData(); // Bu çağrı didChangeDependencies'e taşınacak veya oradan tetiklenecek
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to DefaultCityProvider
    final cityProvider = Provider.of<DefaultCityProvider>(context);
    final newCity = cityProvider.defaultCity;

    if (_currentCityFromProvider != newCity) {
      _currentCityFromProvider = newCity;
      // Kullanıcı profili ve ilk şehir yüklemesi için _fetchInitialData çağrılabilir.
      // Eğer _currentUser null değilse ve _currentCityFromProvider henüz ayarlanmamışsa (ilk yükleme) veya değişmişse.
      if (_currentUser != null) {
        _fetchUserCityAndThenWeather(); // Provider'dan gelen şehirle hava durumunu getir
      }
    }
    // Eğer _currentUser var ama _currentCityFromProvider hala null ise (provider'dan henüz değer gelmediyse ve ilk yükleme ise)
    // ve _weatherForecast da null ise (henüz hava durumu yüklenmediyse), initial datayı fetch etmeyi deneyebiliriz.
    // Bu, uygulama açıldığında provider'dan değer gelene kadar beklemek yerine bir ilk yükleme sağlar.
    else if (_currentUser != null &&
        _currentCityFromProvider == null &&
        _weatherForecast == null &&
        !_isLoadingWeather) {
      _fetchInitialData(); // Bu, kullanıcının kayıtlı şehrini (varsa) yükler ve hava durumunu getirir.
    }
  }

  Future<void> _fetchInitialData() async {
    // Bu metod, kullanıcının profilinden şehri alıp provider'ı güncelleyebilir (eğer provider boşsa)
    // ve ardından _fetchUserCityAndThenWeather'ı çağırabilir.
    // Ya da doğrudan _fetchUserCityAndThenWeather'ı çağırır ve o metod provider'ı kullanır.
    // Mevcut yapıda _fetchUserCityAndThenWeather zaten şehri alıp hava durumunu getiriyor.
    // Provider entegrasyonu ile bu metodun rolü değişebilir.
    // Şimdilik, sadece hava durumu getirme işlemini tetiklesin.
    await _fetchUserCityAndThenWeather();
  }

  Future<void> _fetchUserCityAndThenWeather() async {
    if (_currentUser == null) return;
    if (!mounted) return;

    // Şehri provider'dan al
    final String? cityForWeather =
        Provider.of<DefaultCityProvider>(context, listen: false).defaultCity;

    // Eğer provider'dan şehir gelmediyse ve _currentCityFromProvider da boşsa (ilk yükleme olabilir),
    // kullanıcının Firestore'daki profilinden şehri okumayı dene.
    String? cityToFetch = cityForWeather;
    if (cityToFetch == null || cityToFetch.isEmpty) {
      UserProfile? userProfile = await _userProfileService.getUserProfile(
        _currentUser.uid,
      );
      if (mounted &&
          userProfile?.defaultCity != null &&
          userProfile!.defaultCity!.isNotEmpty) {
        cityToFetch = userProfile.defaultCity;
        // Provider'ı güncelle, böylece bir sonraki sefer buradan okunur.
        // Bu, uygulama ilk açıldığında ve provider'da şehir yoksa faydalı olur.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Provider.of<DefaultCityProvider>(
              context,
              listen: false,
            ).updateDefaultCity(cityToFetch);
          }
        });
      }
    }

    if (cityToFetch == null || cityToFetch.isEmpty) {
      if (mounted) {
        setState(() {
          _weatherError = AppLocalizations.of(context)!.weatherSetCityPrompt;
          _weatherForecast = null;
          _isLoadingWeather = false;
        });
      }
      return;
    }

    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      final String cacheKey = _weatherCacheKeyPrefix + cityToFetch;
      final String? cachedWeatherString = prefs.getString(cacheKey);

      if (cachedWeatherString != null) {
        try {
          final Map<String, dynamic> cachedWeatherData =
              jsonDecode(cachedWeatherString) as Map<String, dynamic>;
          final WeatherForecast cachedForecast = WeatherForecast.fromCachedJson(
            cachedWeatherData,
          );
          if (DateTime.now().difference(cachedForecast.date) <
              _weatherCacheDuration) {
            if (mounted) {
              setState(() {
                _weatherForecast = cachedForecast;
                _isLoadingWeather = false;
              });
            }
            return;
          }
        } catch (e) {
          await prefs.remove(cacheKey);
        }
      }

      if (!mounted) return;
      _weatherForecast = await _weatherService.getCurrentWeather(cityToFetch);
      if (!mounted) return;
      await prefs.setString(cacheKey, jsonEncode(_weatherForecast!.toJson()));
    } catch (e) {
      if (!mounted) return;
      _weatherError = AppLocalizations.of(
        context,
      )!.weatherLoadError(cityToFetch, e.toString());
      _weatherForecast = null;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }

  List<String> _getAppBarTitles(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return <String>[
      localizations.dashboardTitle,
      localizations.myCoursesTitle,
      localizations.calendarTitle,
      localizations.myTasksTitle,
      localizations.weeklyScheduleTitle,
    ];
  }

  List<Widget> _widgetOptions(BuildContext context) => <Widget>[
    _buildDashboard(context),
    const CourseListScreen(showAppBar: false),
    const CalendarScreen(showAppBar: false),
    const TaskListScreen(showAppBar: false),
    const WeeklyScheduleScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 4) {
      // Profile Screen index
      Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const ViewProfileScreen()),
      ).then((settingsChanged) {
        if (settingsChanged == true) {
          // If settings were changed (e.g., default city), refresh weather data
          _fetchUserCityAndThenWeather();
        }
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildDashboard(BuildContext context) {
    if (_currentUser == null) {
      return const Center(child: Text("Please log in to see your dashboard."));
    }
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final String displayName =
        _currentUser.displayName ?? _currentUser.email ?? "User";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildWelcomeSection(theme, displayName, localizations),
          const SizedBox(height: 16), // Reduced spacing
          _buildSectionTitle(
            theme,
            localizations.todaysWeatherTitle,
            Icons.wb_sunny_outlined,
          ),
          _buildWeatherCard(theme, localizations),
          const SizedBox(height: 16), // Reduced spacing
          _buildSectionTitle(
            theme,
            localizations.upcomingCoursesTitle,
            Icons.school_outlined,
          ),
          _buildUpcomingCoursesSection(theme, localizations),
          const SizedBox(height: 16), // Reduced spacing
          _buildSectionTitle(
            theme,
            localizations.pendingTasksTitle,
            Icons.list_alt_outlined,
          ),
          _buildUpcomingTasksSection(theme, localizations),
          const SizedBox(height: 16), // Reduced spacing
          // Add more sections as needed
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Reduced padding
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 22,
          ), // Slightly smaller icon
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600, // Use titleLarge for section headers
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(
    ThemeData theme,
    String userName,
    AppLocalizations localizations,
  ) {
    String greeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return localizations.goodMorning;
      if (hour < 17) return localizations.goodAfternoon;
      return localizations.goodEvening;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${greeting()},',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          userName,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(ThemeData theme, AppLocalizations localizations) {
    final String? cityToNavigate = _currentCityFromProvider;
    WeatherDisplayData? displayData;
    if (_weatherForecast != null) {
      displayData = _weatherForecast!.getDisplayData(context);
    }
    final isDark = theme.brightness == Brightness.dark;
    // Responsive, consistent card
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxCardWidth = 500;
        final double cardWidth =
            constraints.maxWidth < maxCardWidth
                ? constraints.maxWidth
                : maxCardWidth;
        return Center(
          child: Container(
            width: cardWidth,
            margin: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 0,
            ), // Reduced vertical margin
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  if (cityToNavigate != null && cityToNavigate.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                FiveDayForecastScreen(city: cityToNavigate),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('City not available to view forecast.'),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: _getWeatherGradient(
                      _weatherForecast?.condition,
                      isDark,
                      theme,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, // Slightly reduced horizontal padding
                    vertical: 12, // Reduced vertical padding
                  ),
                  child:
                      _isLoadingWeather
                          ? _buildShimmerLoading(height: 64)
                          : _weatherError != null
                          ? Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _weatherError ==
                                          AppLocalizations.of(
                                            context,
                                          )!.weatherSetCityPrompt
                                      ? AppLocalizations.of(
                                        context,
                                      )!.weatherSetCityPrompt
                                      : AppLocalizations.of(
                                        context,
                                      )!.weatherLoadError(
                                        cityToNavigate ?? 'Unknown City',
                                        _weatherError ?? 'Unknown Error',
                                      ),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : displayData != null && _weatherForecast != null
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildWeatherIcon(
                                _weatherForecast!.condition,
                                isDark,
                                theme,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_weatherForecast!.temperature.toStringAsFixed(1)}°C',
                                    key: ValueKey(
                                      _weatherForecast!.temperature,
                                    ),
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onPrimary,
                                          fontSize: 28,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _weatherForecast!.city,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.onPrimary
                                          .withAlpha((0.92 * 255).round()),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getLocalizedWeatherCondition(
                                      _weatherForecast!.condition,
                                      localizations,
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimary
                                          .withAlpha((0.85 * 255).round()),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              Icon(
                                Icons.wb_sunny_outlined,
                                size: 32,
                                color: theme.colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                localizations.weatherDataNotAvailable,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Theme-aware gradient backgrounds
  LinearGradient _getWeatherGradient(
    String? condition,
    bool isDark,
    ThemeData theme,
  ) {
    // Use theme colors for fallback
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    switch ((condition ?? '').toLowerCase()) {
      case 'rain':
      case 'shower rain':
      case 'drizzle':
        return LinearGradient(
          colors:
              isDark
                  ? [
                    primary.withValues(alpha: 0.7),
                    secondary.withValues(alpha: 0.7),
                  ]
                  : [const Color(0xFF4FC3F7), const Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'thunderstorm':
        return LinearGradient(
          colors:
              isDark
                  ? [
                    primary.withValues(alpha: 0.8),
                    secondary.withValues(alpha: 0.8),
                  ]
                  : [const Color(0xFF7B1FA2), const Color(0xFF512DA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'snow':
        return LinearGradient(
          colors:
              isDark
                  ? [
                    primary.withValues(alpha: 0.5),
                    secondary.withValues(alpha: 0.5),
                  ]
                  : [const Color(0xFFE3F2FD), const Color(0xFF90CAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'clouds':
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
      case 'overcast clouds':
        return LinearGradient(
          colors:
              isDark
                  ? [
                    primary.withValues(alpha: 0.6),
                    secondary.withValues(alpha: 0.6),
                  ]
                  : [const Color(0xFF90A4AE), const Color(0xFF607D8B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'mist':
      case 'fog':
        return LinearGradient(
          colors:
              isDark
                  ? [
                    primary.withValues(alpha: 0.4),
                    secondary.withValues(alpha: 0.4),
                  ]
                  : [const Color(0xFFB0BEC5), const Color(0xFF78909C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'clear':
      default:
        return LinearGradient(
          colors:
              isDark
                  ? [primary, secondary]
                  : [const Color(0xFFFFD54F), const Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  // Theme-aware weather icon
  Widget _buildWeatherIcon(String condition, bool isDark, ThemeData theme) {
    IconData iconData;
    Color iconColor = theme.colorScheme.onPrimary;
    switch (condition.toLowerCase()) {
      case 'rain':
      case 'shower rain':
      case 'drizzle':
        iconData = Icons.grain;
        break;
      case 'thunderstorm':
        iconData = Icons.flash_on;
        break;
      case 'snow':
        iconData = Icons.ac_unit;
        break;
      case 'clouds':
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
      case 'overcast clouds':
        iconData = Icons.cloud;
        break;
      case 'mist':
      case 'fog':
        iconData = Icons.blur_on;
        break;
      case 'clear':
      default:
        iconData = Icons.wb_sunny_outlined;
        break;
    }
    return Icon(
      iconData,
      key: ValueKey<String>(condition),
      size: 64,
      color: iconColor,
    );
  }

  Widget _buildUpcomingCoursesSection(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return StreamBuilder<List<Course>>(
      stream: _getUpcomingCoursesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading(itemCount: 2);
        }
        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(color: theme.colorScheme.error),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                localizations.noUpcomingCourses,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),
          );
        }

        final courses = snapshot.data!;
        // Determine how many courses to show based on expansion state
        final displayCount =
            _coursesExpanded ? courses.length : math.min(courses.length, 2);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayCount,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  elevation: 0.5,
                  margin: const EdgeInsets.only(bottom: 6.0), // Reduced margin
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, // Reduced vertical padding
                      horizontal: 12.0,
                    ),
                    visualDensity:
                        VisualDensity.compact, // Make ListTile more compact
                    leading: Icon(
                      Icons.schedule,
                      color: theme.colorScheme.primary,
                      size: 20, // Smaller icon
                    ),
                    title: Text(
                      course.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Smaller font size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            theme,
                            Icons.calendar_today_outlined,
                            '${course.dayOfWeek}, ${course.startTime} - ${course.endTime}',
                          ),
                          if (course.location.isNotEmpty)
                            _buildInfoRow(
                              theme,
                              Icons.location_on_outlined,
                              course.location,
                            ),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 20, // Smaller icon
                      color: theme.hintColor,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CourseDetailScreen(
                                course: course, // Pass the full course object
                                // courseId: course.id, // Removed incorrect parameter
                                // showAppBar: true, // Assuming CourseDetailScreen handles its own AppBar
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            if (courses.length > 2) // Show toggle button if more than 2 courses
              TextButton(
                onPressed: () {
                  setState(() {
                    _coursesExpanded = !_coursesExpanded;
                  });
                },
                child: Text(
                  _coursesExpanded
                      ? localizations.showLess
                      : localizations.showMore,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingTasksSection(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return StreamBuilder<List<Task>>(
      stream: _getUpcomingTasksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading(itemCount: 2);
        }
        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(color: theme.colorScheme.error),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                localizations.noPendingTasks,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),
          );
        }

        final tasks = snapshot.data!;
        // Determine how many tasks to show based on expansion state
        final displayCount =
            _tasksExpanded ? tasks.length : math.min(tasks.length, 2);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayCount,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  elevation: 0.5,
                  margin: const EdgeInsets.only(bottom: 6.0), // Reduced margin
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, // Reduced vertical padding
                      horizontal: 12.0,
                    ),
                    visualDensity:
                        VisualDensity.compact, // Make ListTile more compact
                    leading: Icon(
                      Icons.task_alt, // Consistent icon
                      color: theme.colorScheme.secondary, // Use secondary color
                      size: 20, // Smaller icon
                    ),
                    title: Text(
                      task.taskName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Smaller font size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.dueDate != null)
                            _buildInfoRow(
                              theme,
                              Icons.event_available_outlined,
                              DateFormat(
                                'EEE, MMM d, yyyy',
                              ).format(task.dueDate!),
                            ),
                          _buildInfoRow(
                            theme,
                            Icons.category_outlined,
                            task.category,
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 20, // Smaller icon
                      color: theme.hintColor,
                    ),
                    onTap: () {
                      // Navigate to AddEditTaskScreen in view/edit mode
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddEditTaskScreen(
                                task: task, // Pass the existing task
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            if (tasks.length > 2) // Show toggle button if more than 2 tasks
              TextButton(
                onPressed: () {
                  setState(() {
                    _tasksExpanded = !_tasksExpanded;
                  });
                },
                child: Text(
                  _tasksExpanded
                      ? localizations.showLess
                      : localizations.showMore,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
          ],
        );
      },
    );
  }

  // Helper widget for info rows within list tiles
  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    // Hardcoded compact sizes inside the method
    const double iconSize = 14.0;
    const double fontSize = 11.0;

    return Padding(
      padding: const EdgeInsets.only(top: 2.0), // Consistent small top padding
      child: Row(
        children: [
          Icon(
            icon,
            size: iconSize,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
          ),
          const SizedBox(width: 4), // Consistent small spacing
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
                fontSize: fontSize,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading({
    double height = 50.0,
    double? width,
    int itemCount = 1,
  }) {
    final theme = Theme.of(context); // Get theme for shimmer colors
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest.withAlpha(
        // 150/255 = 0.588
        (0.588 * 255)
            .round(), // fallback for withAlpha, but should use withValues
      ), // Use theme color
      highlightColor: theme.colorScheme.surfaceContainerHighest.withAlpha(
        // 220/255 = 0.862
        (0.862 * 255)
            .round(), // fallback for withAlpha, but should use withValues
      ), // Use theme color
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context); // Get current theme
    final List<Widget> currentWidgetOptions = _widgetOptions(context);
    final List<String> appBarTitles = _getAppBarTitles(
      context,
    ); // Get localized titles
    final localizations =
        AppLocalizations.of(context)!; // Get localizations here

    // Define icons for CurvedNavigationBar
    final List<Widget> navBarItems = <Widget>[
      Icon(
        Icons.dashboard_outlined,
        size: 30,
        color:
            _selectedIndex == 0
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
      ),
      Icon(
        Icons.list_alt_outlined,
        size: 30,
        color:
            _selectedIndex == 1
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
      ),
      Icon(
        Icons.calendar_today_outlined,
        size: 30,
        color:
            _selectedIndex == 2
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
      ),
      Icon(
        Icons.task_alt_outlined,
        size: 30,
        color:
            _selectedIndex == 3
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
      ),
      Icon(
        Icons.view_week_outlined,
        size: 30,
        color:
            _selectedIndex == 4
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[_selectedIndex]), // Use localized title
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark ||
                      (themeProvider.themeMode == ThemeMode.system &&
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              themeProvider.toggleTheme(context);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile Menu',
            offset: const Offset(
              0,
              50,
            ), // Add offset to position the menu lower
            onSelected: (String result) {
              switch (result) {
                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewProfileScreen(),
                    ),
                  );
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ).then((_) => _checkForCityChange());
                  break;
                case 'logout':
                  _confirmLogout();
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text(
                        localizations.profileMenuProfile,
                      ), // Use localization
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings_outlined),
                      title: Text(
                        localizations.profileMenuSettings,
                      ), // Use localization
                    ),
                  ),
                  const PopupMenuDivider(), // This should be valid
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: theme.colorScheme.error,
                      ),
                      title: Text(
                        localizations.profileMenuLogout, // Use localization
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Center(child: currentWidgetOptions.elementAt(_selectedIndex)),
      // Replace BottomNavigationBar with CurvedNavigationBar
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0, // Adjust height as needed
        items: navBarItems,
        color: theme.colorScheme.surfaceContainerHighest, // Navbar color
        buttonBackgroundColor:
            theme.colorScheme.primary, // Selected button background color
        backgroundColor:
            Colors
                .transparent, // Make it transparent to show body behind (optional)
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // You might need to manually update icon colors if they don't refresh automatically
          // This can be done by calling setState again or ensuring the color logic for icons is reactive
        },
        letIndexChange: (index) => true,
      ),
    );
  }

  // --- START: Navigation and Helper Methods ---

  void _navigateToCourseDetail(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
  }

  void _navigateToTaskDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddEditTaskScreen(
              task: task,
            ), // Assuming AddEditTaskScreen can view/edit
      ),
    );
  }

  // Helper to get an icon based on task category
  IconData _getIconForTaskCategory(String category) {
    switch (category) {
      case 'Assignment':
        return Icons.assignment_outlined;
      case 'Exam':
        return Icons.edit_note_outlined; // Or Icons.school_outlined
      case 'Reminder':
        return Icons.alarm_outlined;
      case 'Other':
      default:
        return Icons.task_alt_outlined;
    }
  }

  // Add this method back
  Future<void> _checkForCityChange() async {
    // Fetch the full profile first
    UserProfile? profile = await _userProfileService.getUserProfile(
      _currentUser!.uid,
    );
    if (!mounted || profile == null) return;

    final String? currentCitySetting = profile.defaultCity;

    // Compare with the city used by the weather widget
    if (currentCitySetting != null &&
        currentCitySetting != _currentCityFromProvider) {
      setState(() {
        _currentCityFromProvider =
            currentCitySetting; // Update local state to match setting
        _weatherForecast = null; // Clear old weather data
        _weatherError = null; // Clear old error
      });
      _fetchUserCityAndThenWeather(); // Fetch new weather data using the potentially updated city
    }
  }

  // Add this method back
  Future<void> _confirmLogout() async {
    final localizations = AppLocalizations.of(context)!; // Get localizations
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.logoutConfirmTitle), // Use localization
          content: Text(localizations.logoutConfirmContent), // Use localization
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancelAction), // Use localization
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.logoutAction), // Use localization
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // --- END: Navigation and Helper Methods ---

  // Helper function to get localized weather condition string
  String _getLocalizedWeatherCondition(
    String condition,
    AppLocalizations localizations,
  ) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return localizations.weatherConditionClear;
      case 'clouds':
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
      case 'overcast clouds':
        return localizations.weatherConditionClouds;
      case 'rain':
      case 'shower rain':
        return localizations.weatherConditionRain;
      case 'drizzle':
        return localizations.weatherConditionDrizzle;
      case 'thunderstorm':
        return localizations.weatherConditionThunderstorm;
      case 'snow':
        return localizations.weatherConditionSnow;
      case 'mist':
        return localizations.weatherConditionMist;
      case 'fog':
        return localizations.weatherConditionFog;
      default:
        // Return the original condition or a generic unknown string if mapping fails
        return localizations.weatherConditionUnknown;
    }
  }
}
