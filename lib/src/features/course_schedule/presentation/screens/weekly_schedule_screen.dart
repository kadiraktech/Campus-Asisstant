import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectv1/src/features/course_schedule/domain/models/course_model.dart';
import 'package:intl/intl.dart'; // For date/day formatting if needed later
import 'package:projectv1/generated/l10n/app_localizations.dart'; // Ensure this import is present
// Import TableCalendar
// Uncommented this line
// import 'package:projectv1/src/features/course_schedule/presentation/screens/add_edit_course_screen.dart'; // Uncomment if needed

class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Course>> _events = {};

  bool _isLoading = true;
  String? _error;

  // Define the order of days for mapping string day to int (Monday=1, Sunday=7 for DateTime)
  final Map<String, int> _dayMapping = {
    'Monday': DateTime.monday,
    'Tuesday': DateTime.tuesday,
    'Wednesday': DateTime.wednesday,
    'Thursday': DateTime.thursday,
    'Friday': DateTime.friday,
    'Saturday': DateTime.saturday,
    'Sunday': DateTime.sunday,
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    if (_currentUser != null) {
      _loadCoursesAndSetupEvents();
    } else {
      setState(() {
        _isLoading = false;
        _error = "User not logged in.";
      });
    }
  }

  Future<void> _loadCoursesAndSetupEvents() async {
    if (_currentUser == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _events = {}; // Clear previous events
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('courses')
              .where('userId', isEqualTo: _currentUser.uid)
              .get();

      final coursesFromDb =
          snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();

      Map<DateTime, List<Course>> tempEvents = {};

      for (var course in coursesFromDb) {
        int? targetWeekday = _dayMapping[course.dayOfWeek];
        if (targetWeekday == null) continue;

        List<String> startTimeParts = course.startTime.split(':');
        List<String> endTimeParts = course.endTime.split(':');
        if (startTimeParts.length != 2 || endTimeParts.length != 2) continue;

        // For TableCalendar, we need to associate events with specific dates.
        // Since courses repeat weekly, we'll add them to each corresponding weekday
        // for a reasonable range (e.g., current year or few months around focusedDay).
        // For simplicity here, let's populate for a few weeks around the initial focusedDay.
        DateTime anchorDate = _focusedDay; // Or DateTime.now();
        for (int i = -4; i <= 4; i++) {
          // Populate for ~2 months range (can be adjusted)
          DateTime referenceMonday = anchorDate
              .subtract(Duration(days: anchorDate.weekday - DateTime.monday))
              .add(Duration(days: i * 7));
          DateTime eventDate = referenceMonday.add(
            Duration(days: targetWeekday - DateTime.monday),
          );
          DateTime eventDateKey = DateTime.utc(
            eventDate.year,
            eventDate.month,
            eventDate.day,
          ); // Normalize to UTC for map key

          // Create a new course instance for this specific date if needed, or use the same one
          // if TableCalendar doesn't modify it or if its identity is based on more than just date.
          // Here, we are essentially saying this course occurs on this date.
          tempEvents.putIfAbsent(eventDateKey, () => []).add(course);
        }
      }

      if (mounted) {
        setState(() {
          _events = tempEvents;
        });
      }
    } catch (e) {
      // print("Error loading courses for TableCalendar: $e"); // Commented out print
      if (mounted) {
        setState(() {
          _error = "Failed to load schedule: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!; // Get localizations

    if (_currentUser == null) {
      // This should ideally be handled by AuthGate, but as a fallback:
      return Center(
        child: Text(localizations.mustBeLoggedInError),
      ); // Example of a general error
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.scheduleLoadingErrorTitle, // Use localization
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!, // Keep the specific error message from Firebase/logic
                style: TextStyle(
                  color: theme.colorScheme.error.withOpacity(0.8),
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(
                  localizations.scheduleLoadingErrorRetryButton,
                ), // Use localization
                onPressed: _loadCoursesAndSetupEvents,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Haftanın günleri ve grid için hazırlık
    final today = DateTime.now();
    final selectedDay = _selectedDay ?? today;
    final weekStart = selectedDay.subtract(
      Duration(days: selectedDay.weekday - 1),
    );
    final weekDates = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    // Her gün için dersleri bul
    List<List<Course>> weekCourses = List.generate(7, (i) {
      final date = weekDates[i];
      return _events[DateTime.utc(date.year, date.month, date.day)] ?? [];
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 7,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, i) {
          final date = weekDates[i];
          final isToday =
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          final isSelected =
              date.year == selectedDay.year &&
              date.month == selectedDay.month &&
              date.day == selectedDay.day;
          final courses = weekCourses[i];

          // Get current locale
          final locale = Localizations.localeOf(context).toString();

          // Use locale in DateFormat
          final dayShort = DateFormat('E', locale).format(date); // Wed
          final dateShort = DateFormat('d MMM', locale).format(date); // 14 May

          return _WeeklyDayBox(
            isSelected: isSelected,
            isToday: isToday,
            onTap: () {
              setState(() {
                _selectedDay = date;
              });
              showDialog(
                context: context,
                builder:
                    (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.scheduleDialogTitleFormat(
                                dayShort,
                                dateShort,
                              ), // Use localization
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 20),
                            if (courses.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  child: Text(
                                    localizations
                                        .scheduleNoCourses, // Use localization
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.4,
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: courses.length,
                                  padding: EdgeInsets.zero,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 6),
                                  itemBuilder: (context, courseIndex) {
                                    final course = courses[courseIndex];
                                    return ListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 0,
                                          ),
                                      leading: Icon(
                                        Icons.label_important_outline,
                                        size: 18,
                                        color: theme.colorScheme.primary,
                                      ),
                                      title: Text(
                                        course.name,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        "${course.startTime} - ${course.endTime} @ ${course.location}",
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                              fontSize: 11,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  localizations.scheduleCloseButton,
                                ), // Use localization
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayShort, // Kısa gün adı
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateShort, // Kısa tarih
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                if (courses.isEmpty)
                  Icon(Icons.remove, color: theme.dividerColor, size: 20)
                else
                  ...courses
                      .take(2)
                      .map(
                        (course) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  course.name.length > 8
                                      ? "${course.name.substring(0, 8)}..."
                                      : course.name,
                                  style: theme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                if (courses.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      localizations.scheduleMoreCoursesIndicator(
                        courses.length - 2,
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WeeklyDayBox extends StatefulWidget {
  final bool isSelected;
  final bool isToday;
  final Widget child;
  final VoidCallback? onTap;
  const _WeeklyDayBox({
    required this.isSelected,
    required this.isToday,
    required this.child,
    this.onTap,
  });

  @override
  State<_WeeklyDayBox> createState() => _WeeklyDayBoxState();
}

class _WeeklyDayBoxState extends State<_WeeklyDayBox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDesktop =
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux;
    Color bgColor =
        widget.isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.18)
            : widget.isToday
            ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.18)
            : theme.colorScheme.surface;
    return MouseRegion(
      onEnter: isDesktop ? (_) => setState(() => _isHovered = true) : null,
      onExit: isDesktop ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isHovered ? bgColor.withValues(alpha: 0.92) : bgColor,
          border:
              widget.isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  _isHovered
                      ? theme.colorScheme.primary.withValues(alpha: 0.18)
                      : Colors.grey.withValues(alpha: 0.10),
              blurRadius: _isHovered ? 24 : 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
