import 'package:flutter/material.dart';
import 'package:projectv1/src/features/course_schedule/domain/models/course_model.dart';
import 'package:projectv1/src/features/course_schedule/presentation/screens/add_edit_course_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:projectv1/src/features/course_schedule/presentation/screens/course_detail_screen.dart';
import 'package:projectv1/src/core/services/notification_service.dart';

class CourseListScreen extends StatefulWidget {
  final bool showAppBar; // Added parameter
  const CourseListScreen({
    super.key,
    this.showAppBar = true,
  }); // Default to true

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  List<Course> _courses = []; // This will be fetched from Firestore
  bool _isLoading = true; // To show a loading indicator while fetching
  StreamSubscription? _coursesSubscription; // To manage the stream
  final NotificationService _notificationService =
      NotificationService(); // Add NotificationService

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  @override
  void dispose() {
    _coursesSubscription
        ?.cancel(); // Cancel subscription to prevent memory leaks
    super.dispose();
  }

  Future<void> _fetchCourses() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in. Cannot fetch courses.'),
          ),
        );
      }
      return;
    }

    _coursesSubscription?.cancel(); // Cancel any existing subscription
    _coursesSubscription = FirebaseFirestore.instance
        .collection('courses')
        .where('userId', isEqualTo: userId)
        // .orderBy('dayOfWeek') // Add specific ordering if needed, consider custom sort for days
        .snapshots()
        .listen(
          (snapshot) {
            if (mounted) {
              setState(() {
                _courses =
                    snapshot.docs
                        .map((doc) => Course.fromFirestore(doc))
                        .toList();
                // Custom sort for days of the week if needed, then by time
                _courses.sort((a, b) {
                  final daysOrder = [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday',
                  ];
                  int dayCompare = daysOrder
                      .indexOf(a.dayOfWeek)
                      .compareTo(daysOrder.indexOf(b.dayOfWeek));
                  if (dayCompare != 0) return dayCompare;
                  return a.startTime.compareTo(b.startTime);
                });
                _isLoading = false;
              });
            }
          },
          onError: (error) {
            // print("Error fetching courses: $error");
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error fetching courses: ${error.toString()}'),
                ),
              );
            }
          },
        );
  }

  void _navigateToAddEditScreen([Course? course]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCourseScreen(course: course),
      ),
    );
    // No need to explicitly call _fetchCourses here if using snapshots,
    // but if pop result is true (meaning a save happened), it doesn't hurt.
    // If not using snapshots, _fetchCourses() would be essential here.
    if (result == true) {
      // _fetchCourses(); // Listens to snapshots, so automatically updates. Can be kept for non-snapshot scenarios.
    }
  }

  Future<void> _deleteCourse(String courseId) async {
    if (!mounted) return;
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .delete();

      // Cancel notification
      final int notificationId = "course_$courseId".hashCode;
      await _notificationService.cancelNotification(notificationId);
      debugPrint("Cancelled notification for deleted course $courseId");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully')),
        );
      }
      // _fetchCourses(); // Not needed if using snapshots, list updates automatically
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting course: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme for styling

    return Scaffold(
      appBar:
          widget.showAppBar ? AppBar(title: const Text('My Courses')) : null,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _courses.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 80,
                      color: theme.colorScheme.onSurface.withAlpha(
                        (255 * 0.5).round(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No courses added yet.',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(
                          (255 * 0.7).round(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the \'+\' button to add your first course.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(
                          (255 * 0.6).round(),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : _buildCourseListView(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddEditScreen(); // Call without arguments for new course
        },
        tooltip: 'Add Course',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCourseListView(ThemeData theme) {
    // Calculate aspect ratio based on typical screen width and desired card height
    // This is an estimate and might need adjustment based on testing
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth =
        (screenWidth - 8 * 2 - 10 * 2) /
        2; // (width - listPadding*2 - gridSpacing*2) / columnCount
    double desiredHeight =
        130; // Approximate desired height for the compact card
    double aspectRatio = itemWidth / desiredHeight;

    return GridView.builder(
      padding: const EdgeInsets.only(
        bottom: 80, // Padding for FAB
        top: 12, // Top padding
        left: 12, // Left padding
        right: 12, // Right padding
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two columns
        crossAxisSpacing: 10.0, // Spacing between columns
        mainAxisSpacing: 10.0, // Spacing between rows
        childAspectRatio: aspectRatio, // Adjust based on content height
      ),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];

        // Re-using the compact Card structure from previous step
        return Card(
          elevation: 2.0,
          // No horizontal margin needed as grid provides spacing
          margin: EdgeInsets.zero, // Let GridView handle spacing
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(course: course),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10.0),
                child: Padding(
                  // Slightly adjust padding for grid view if needed
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    // Use Column again for vertical stacking within grid item
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Distribute space
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize:
                            MainAxisSize.min, // Take only needed space
                        children: [
                          Text(
                            course.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2, // Limit to 2 lines
                            overflow:
                                TextOverflow
                                    .ellipsis, // Add ellipsis if overflows
                            softWrap: true, // Explicitly set softWrap
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "${course.dayOfWeek.substring(0, 3)}, ${course.startTime} - ${course.endTime}", // Abbreviate day
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11, // Slightly smaller font
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize:
                            MainAxisSize.min, // Take only needed space
                        children: [
                          if (course.location.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            _buildInfoRow(
                              theme,
                              Icons.location_on_outlined,
                              course.location,
                            ),
                          ],
                          if (course.classroom != null &&
                              course.classroom!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            _buildInfoRow(
                              theme,
                              Icons.meeting_room_outlined,
                              course.classroom!,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  tooltip: 'More options',
                  onSelected: (String result) {
                    if (result == 'edit') {
                      _navigateToAddEditScreen(course);
                    } else if (result == 'delete') {
                      _showDeleteConfirmDialog(
                        context,
                        course.id!,
                        course.name,
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    // Theme can be accessed here
                    final popupTheme = Theme.of(context);
                    return <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color:
                                popupTheme
                                    .colorScheme
                                    .primary, // Use popupTheme
                          ),
                          title: Text(
                            'Edit',
                            style:
                                popupTheme
                                    .textTheme
                                    .bodySmall, // Use popupTheme
                          ),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                          title: Text(
                            'Delete',
                            style: popupTheme.textTheme.bodySmall?.copyWith(
                              // Use popupTheme
                              color: Colors.redAccent,
                            ),
                          ),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ];
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    String courseId,
    String courseName,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete the course "$courseName"?',
                ),
                const SizedBox(height: 8),
                const Text(
                  'This action cannot be undone.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteCourse(courseId);
              },
            ),
          ],
        );
      },
    );
  }

  // Helper widget for icon + text rows (re-usable)
  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
