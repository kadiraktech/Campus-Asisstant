import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:projectv1/src/features/course_schedule/domain/models/course_model.dart';
import 'package:projectv1/src/features/task_management/domain/models/task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:projectv1/src/features/course_schedule/presentation/screens/course_detail_screen.dart';
import 'package:projectv1/src/core/services/notification_service.dart';
import 'package:projectv1/src/features/task_management/presentation/screens/task_detail_screen.dart';
import 'package:projectv1/generated/l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  final bool showAppBar;
  const CalendarScreen({super.key, this.showAppBar = true});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  bool _isLoading = true;
  StreamSubscription? _coursesSubscription;
  StreamSubscription? _tasksSubscription;

  final NotificationService _notificationService = NotificationService();

  final Map<String, int> _dayOfWeekToInt = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchCalendarData();
  }

  @override
  void dispose() {
    _coursesSubscription?.cancel();
    _tasksSubscription?.cancel();
    super.dispose();
  }

  void _fetchCalendarData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final userId = _currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.calendarUserNotLoggedIn)),
        );
      }
      return;
    }

    Map<DateTime, List<dynamic>> newEvents = {};

    _coursesSubscription?.cancel();
    _coursesSubscription = FirebaseFirestore.instance
        .collection('courses')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
          List<Course> allCourses =
              snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();

          for (var course in allCourses) {
            int? courseDayOfWeek = _dayOfWeekToInt[course.dayOfWeek];
            if (courseDayOfWeek != null) {
              DateTime now = DateTime.now();
              for (int i = 0; i < 60; i++) {
                DateTime date = DateTime(now.year, now.month, now.day + i);
                if (date.weekday == courseDayOfWeek) {
                  DateTime normalizedDate = DateTime.utc(
                    date.year,
                    date.month,
                    date.day,
                  );
                  if (newEvents[normalizedDate] == null) {
                    newEvents[normalizedDate] = [];
                  }
                  newEvents[normalizedDate]!.add(course);
                }
              }
            }
          }
          _updateEventsState(newEvents);
        }, onError: (error) => _handleError(error, "courses"));

    _tasksSubscription?.cancel();
    _tasksSubscription = FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
          List<Task> allTasks =
              snapshot.docs
                  .map((doc) => Task.fromFirestore(doc, doc.id))
                  .toList();

          for (var task in allTasks) {
            DateTime normalizedDate = DateTime.utc(
              task.dueDate.year,
              task.dueDate.month,
              task.dueDate.day,
            );
            if (newEvents[normalizedDate] == null) {
              newEvents[normalizedDate] = [];
            }
            if (!newEvents[normalizedDate]!.any(
              (e) => e is Task && e.taskId == task.taskId,
            )) {
              newEvents[normalizedDate]!.add(task);
            }
          }
          _updateEventsState(newEvents);
        }, onError: (error) => _handleError(error, "tasks"));
  }

  void _updateEventsState(Map<DateTime, List<dynamic>> newEventsFromSource) {
    if (!mounted) return;

    Map<DateTime, List<dynamic>> combinedEvents = Map.from(_events);
    newEventsFromSource.forEach((date, eventsOnDate) {
      if (combinedEvents[date] == null) {
        combinedEvents[date] = [];
      }
      for (var event in eventsOnDate) {
        if (event is Course) {
          combinedEvents[date]!.removeWhere(
            (e) => e is Course && e.id == event.id,
          );
          combinedEvents[date]!.add(event);
        } else if (event is Task) {
          combinedEvents[date]!.removeWhere(
            (e) => e is Task && e.taskId == event.taskId,
          );
          combinedEvents[date]!.add(event);
        }
      }
      combinedEvents[date]!.sort((a, b) {
        DateTime? aTime =
            (a is Course) ? _parseTime(a.startTime, date) : (a as Task).dueDate;
        DateTime? bTime =
            (b is Course) ? _parseTime(b.startTime, date) : (b as Task).dueDate;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return aTime.compareTo(bTime);
      });
    });

    setState(() {
      _events = combinedEvents;
      _isLoading = false;
      if (_selectedDay != null) {
        _selectedEvents = _getEventsForDay(_selectedDay!);
      }
    });
  }

  DateTime? _parseTime(String time, DateTime onDate) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        return DateTime(
          onDate.year,
          onDate.month,
          onDate.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
    } catch (e) {
      // Zaman parse edilemezse
    }
    return null;
  }

  void _handleError(dynamic error, String sourceType) {
    final localizations = AppLocalizations.of(context)!;
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.calendarDataLoadError(sourceType, error.toString()),
          ),
        ),
      );
      debugPrint('Error loading $sourceType data: $error');
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar:
          widget.showAppBar
              ? AppBar(
                title: const Text('Calendar'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              )
              : null,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                color: theme.scaffoldBackgroundColor,
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TableCalendar<dynamic>(
                          locale: locale,
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate:
                              (day) => isSameDay(_selectedDay, day),
                          calendarFormat: _calendarFormat,
                          eventLoader: _getEventsForDay,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                            CalendarFormat.twoWeeks: '2 Weeks',
                            CalendarFormat.week: 'Week',
                          },
                          availableGestures: AvailableGestures.horizontalSwipe,
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          calendarStyle: CalendarStyle(
                            markerSize: 4.0,
                            markerMargin: const EdgeInsets.symmetric(
                              horizontal: 0.5,
                            ),
                            todayDecoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.18,
                              ),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            weekendTextStyle: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: 13,
                            ),
                            defaultTextStyle: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 13.5,
                            ),
                            outsideTextStyle: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            weekendStyle: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            leftChevronIcon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.chevron_left,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            rightChevronIcon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            titleTextFormatter:
                                (date, locale) =>
                                    DateFormat.yMMMM(
                                      locale,
                                    ).format(date).toUpperCase(),
                            titleTextStyle:
                                theme.textTheme.titleSmall ??
                                const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.1,
                                ),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                          ),
                          onDaySelected: _onDaySelected,
                          onFormatChanged: (format) {
                            if (_calendarFormat != format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            }
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child:
                            _selectedEvents.isEmpty
                                ? Center(
                                  child: Text(
                                    'No lessons or tasks for this day.',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                )
                                : ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: _selectedEvents.length,
                                  separatorBuilder:
                                      (context, index) => Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                        color: theme.dividerColor.withOpacity(
                                          0.1,
                                        ),
                                      ),
                                  itemBuilder: (context, index) {
                                    final event = _selectedEvents[index];
                                    if (event is Course) {
                                      return ListTile(
                                        visualDensity: VisualDensity.compact,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 2,
                                            ),
                                        leading: Icon(
                                          Icons.school_outlined,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        title: Text(
                                          event.name,
                                          style: theme.textTheme.titleSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          '${DateFormat.jm(locale).format(_parseTime(event.startTime, _selectedDay!)!)} - ${DateFormat.jm(locale).format(_parseTime(event.endTime, _selectedDay!)!)} @ ${event.location} (${event.classroom ?? 'N/A'})',
                                          style: theme.textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      CourseDetailScreen(
                                                        course: event,
                                                      ),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (event is Task) {
                                      final isCompleted = event.isCompleted;
                                      final localizedCategory =
                                          _getLocalizedCategory(
                                            context,
                                            event.category,
                                          );
                                      return ListTile(
                                        visualDensity: VisualDensity.compact,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 2,
                                            ),
                                        leading: Icon(
                                          isCompleted
                                              ? Icons.check_circle_outline
                                              : Icons
                                                  .radio_button_unchecked_outlined,
                                          size: 20,
                                          color:
                                              isCompleted
                                                  ? theme.disabledColor
                                                  : null,
                                        ),
                                        title: Text(
                                          event.taskName,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                decoration:
                                                    isCompleted
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none,
                                                color:
                                                    isCompleted
                                                        ? theme.disabledColor
                                                        : theme
                                                            .colorScheme
                                                            .onSurface,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          '$localizedCategory - ${localizations.dueDatePrefix}${DateFormat.yMd(locale).format(event.dueDate)}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    isCompleted
                                                        ? theme.disabledColor
                                                        : theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: Chip(
                                          label: Text(
                                            isCompleted
                                                ? localizations
                                                    .taskStatusCompleted
                                                : localizations
                                                    .taskStatusPending,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  isCompleted
                                                      ? theme
                                                          .colorScheme
                                                          .onSurface
                                                      : theme
                                                          .colorScheme
                                                          .onPrimary,
                                            ),
                                          ),
                                          backgroundColor:
                                              isCompleted
                                                  ? theme
                                                      .colorScheme
                                                      .surfaceContainerHighest
                                                  : theme.colorScheme.primary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          side: BorderSide.none,
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => TaskDetailScreen(
                                                    task: event,
                                                  ),
                                            ),
                                          ).then((_) => _fetchCalendarData());
                                        },
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  String _getLocalizedCategory(BuildContext context, String categoryKey) {
    final localizations = AppLocalizations.of(context)!;
    switch (categoryKey) {
      case 'Assignment':
        return localizations.taskCategoryAssignment;
      case 'Exam':
        return localizations.taskCategoryExam;
      case 'Reminder':
        return localizations.taskCategoryReminder;
      case 'Other':
        return localizations.taskCategoryOther;
      default:
        return categoryKey;
    }
  }

  Future<void> _toggleTaskCompletion(Task task, bool? newValue) async {
    if (newValue == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(task.taskId)
          .update({'isCompleted': newValue});

      if (newValue == true) {
        final int notificationId = "task_${task.taskId}".hashCode;
        await _notificationService.cancelNotification(notificationId);
        debugPrint(
          "Cancelled notification for completed task ${task.taskId} from CalendarScreen",
        );
      }

      setState(() {
        _events.forEach((date, eventsOnDate) {
          int taskIndex = eventsOnDate.indexWhere(
            (e) => e is Task && e.taskId == task.taskId,
          );
          if (taskIndex != -1) {
            (eventsOnDate[taskIndex] as Task).isCompleted = newValue;
          }
        });
        if (_selectedDay != null &&
            _events[DateTime.utc(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                )] !=
                null) {
          _selectedEvents = _getEventsForDay(_selectedDay!);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: ${e.toString()}')),
        );
      }
    }
  }
}
