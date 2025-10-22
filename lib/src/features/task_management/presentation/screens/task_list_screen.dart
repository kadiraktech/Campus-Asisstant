import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'package:projectv1/src/features/task_management/domain/models/task_model.dart';
import 'add_edit_task_screen.dart'; // Import AddEditTaskScreen
import 'package:projectv1/src/core/services/notification_service.dart'; // Import NotificationService
import 'package:projectv1/generated/l10n/app_localizations.dart'; // Add this import
// Required for PageView dragStartBehavior

// Enum to represent the view state
enum TaskViewStatus { active, completed }

class TaskListScreen extends StatefulWidget {
  final bool showAppBar; // Added parameter
  const TaskListScreen({super.key, this.showAppBar = true}); // Default to true

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final NotificationService _notificationService =
      NotificationService(); // Add NotificationService instance

  // State variables for filtering
  String? _selectedCategoryFilter;
  // bool? _selectedCompletionStatus; // NO LONGER USED - Replaced by _selectedViewStatus

  // State for ToggleButtons
  TaskViewStatus _selectedViewStatus = TaskViewStatus.active;

  final List<String> _availableTaskCategories = [
    'Assignment',
    'Exam',
    'Reminder',
    'Other',
    // Add more categories if needed or fetch from Firestore
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _pageController.dispose(); // Dispose the controller - REMOVED
    super.dispose();
  }

  // Modified stream to fetch ALL tasks for the user (active and completed)
  // Filtering by completion status will happen client-side
  Stream<List<Task>> _getAllTasksStream() {
    if (_currentUser == null) {
      return Stream.value([]); // Return empty stream if no user
    }
    Query query = _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _currentUser.uid);

    // Category Filter (still applied if active)
    if (_selectedCategoryFilter != null) {
      query = query.where('category', isEqualTo: _selectedCategoryFilter);
    }

    // REMOVE completion status filter from the query
    // if (_selectedCompletionStatus != null) {
    //   query = query.where(\'isCompleted\', isEqualTo: _selectedCompletionStatus);
    // }

    // Order by completion status first (false first), then by due date
    // This helps slightly with client-side separation but sorting is primarily client-side.
    query = query.orderBy('isCompleted').orderBy('dueDate');

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => Task.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                  doc.id,
                ),
              )
              .toList(),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryFilter = null;
      // _selectedCompletionStatus = null; // No longer needed here
    });
  }

  // Reusable Task List Builder - Now takes the list of tasks AND the desired status
  Widget _buildTaskListWidget(
    BuildContext context,
    List<Task> allTasks, // Changed parameter name for clarity
    TaskViewStatus statusToShow, // Use enum for status
  ) {
    // Filter tasks based on the selected status
    final filteredTasks =
        allTasks
            .where(
              (task) =>
                  task.isCompleted ==
                  (statusToShow == TaskViewStatus.completed),
            )
            .toList();

    // Sort tasks: Active tasks by due date ascending, Completed tasks by due date descending
    filteredTasks.sort((a, b) {
      // Completed tasks: newest completion (latest due date) first
      if (statusToShow == TaskViewStatus.completed) {
        return b.dueDate.compareTo(a.dueDate);
      }
      // Active tasks: earliest due date first
      return a.dueDate.compareTo(b.dueDate);
    });

    if (filteredTasks.isEmpty) {
      final bool categoryFilterActive = _selectedCategoryFilter != null;
      String emptyMessage;
      String suggestionMessage = '';

      if (categoryFilterActive) {
        emptyMessage =
            statusToShow == TaskViewStatus.completed
                ? 'No completed tasks match your filter.'
                : 'No active tasks match your filter.';
        suggestionMessage = 'Try adjusting or clearing the category filter.';
      } else {
        emptyMessage =
            statusToShow == TaskViewStatus.completed
                ? 'No completed tasks yet.'
                : 'No active tasks. Well done!';
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                categoryFilterActive
                    ? Icons.filter_alt_off_outlined
                    : (statusToShow == TaskViewStatus.completed
                        ? Icons.history_toggle_off_outlined
                        : Icons.check_circle_outline),
                size: 60,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              if (suggestionMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    suggestionMessage,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Task List Rendering
    return ListView.builder(
      padding: const EdgeInsets.only(
        bottom: 80,
        top: 8,
      ), // Padding for FAB and top spacing
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        Task task = filteredTasks[index];
        final theme = Theme.of(context);
        bool isTaskCompleted =
            task.isCompleted; // Determine based on task property
        String formattedDueDate;
        try {
          formattedDueDate = DateFormat.yMMMd().format(task.dueDate.toLocal());
        } catch (e) {
          formattedDueDate = task.dueDate.toLocal().toString().split(' ')[0];
          debugPrint("Error formatting due date: $e");
        }

        Color textColor = theme.colorScheme.onSurface;
        Color iconColor = theme.colorScheme.onSurfaceVariant;
        TextDecoration textDecoration = TextDecoration.none;

        if (isTaskCompleted) {
          textColor = Colors.grey.shade600;
          iconColor = Colors.grey.shade600;
          textDecoration = TextDecoration.lineThrough;
        }

        return Card(
          elevation: 1.5, // Reduced elevation
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ), // Reduced margins
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.0,
            ), // Slightly smaller radius
          ),
          color:
              isTaskCompleted
                  ? theme.cardColor.withAlpha(180)
                  : theme.cardColor,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditTaskScreen(task: task),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10.0),
                child: Padding(
                  // Reduced padding
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 1.0, // Slightly reduced checkbox scale
                        child: Checkbox(
                          value: isTaskCompleted,
                          onChanged: (bool? value) async {
                            if (value != null) {
                              // Optimistically update UI
                              setState(() {
                                task.isCompleted = value;
                              });
                              try {
                                await _firestore
                                    .collection('tasks')
                                    .doc(task.taskId)
                                    .update({'isCompleted': value});
                                if (value == true) {
                                  final int notificationId =
                                      "task_${task.taskId}".hashCode;
                                  await _notificationService.cancelNotification(
                                    notificationId,
                                  );
                                  debugPrint(
                                    "Cancelled notification for completed task ${task.taskId}",
                                  );
                                } else {
                                  // Reschedule notification logic could be added here
                                }
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error updating task: $e'),
                                  ),
                                );
                                setState(() => task.isCompleted = !value);
                              }
                            }
                          },
                          activeColor: theme.colorScheme.primary,
                          checkColor: theme.colorScheme.onPrimary,
                          visualDensity:
                              VisualDensity.compact, // Compact checkbox
                          side: BorderSide(
                            color:
                                isTaskCompleted
                                    ? Colors.grey.shade400
                                    : theme.colorScheme.outline,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              task.taskName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                // Changed to titleSmall
                                fontWeight: FontWeight.w600,
                                decoration: textDecoration,
                                color: textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4), // Reduced spacing
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13, // Reduced icon size
                                  color: iconColor,
                                ),
                                const SizedBox(width: 4), // Reduced spacing
                                Text(
                                  formattedDueDate,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: iconColor,
                                    fontSize: 11, // Slightly smaller font
                                  ),
                                ),
                                const SizedBox(width: 8), // Reduced Spacing
                                Icon(
                                  Icons.label_outline,
                                  size: 13, // Reduced icon size
                                  color: iconColor,
                                ),
                                const SizedBox(width: 4), // Reduced spacing
                                Flexible(
                                  child: Text(
                                    task.category,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: iconColor,
                                      fontSize: 11, // Slightly smaller font
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (task.description != null &&
                                task.description!.isNotEmpty &&
                                !isTaskCompleted) ...[
                              const SizedBox(height: 4), // Reduced spacing
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 30, // Space for menu button
                                ),
                                child: Text(
                                  task.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11, // Slightly smaller font
                                    color: textColor.withAlpha(
                                      (0.7 * 255).round(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0, // Adjust position
                right: 0, // Adjust position
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: iconColor.withAlpha((0.7 * 255).round()),
                    size: 18, // Reduced icon size
                  ),
                  tooltip: 'More options',
                  onSelected: (String result) {
                    if (result == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditTaskScreen(task: task),
                        ),
                      );
                    } else if (result == 'delete') {
                      _showDeleteConfirmDialog(context, task.taskId);
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined, size: 20),
                            title: Text('Edit'),
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ), // Adjust padding
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            title: Text(
                              'Delete',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ), // Adjust padding
                          ),
                        ),
                      ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Start: Filter Bottom Sheet (Old - kept for reference if needed, will be removed later) ---
  void _showFilterBottomSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use StatefulBuilder to manage the state within the bottom sheet if needed
        // For simple selection like this, direct setState on the main screen might be sufficient
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter by Category', style: theme.textTheme.titleLarge),
                  TextButton(
                    onPressed: () {
                      if (_selectedCategoryFilter != null) {
                        setState(() {
                          _selectedCategoryFilter = null;
                        });
                        Navigator.pop(
                          context,
                        ); // Close bottom sheet after clearing
                      }
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children:
                    _availableTaskCategories.map((category) {
                      final isSelected = _selectedCategoryFilter == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategoryFilter = category;
                            } else {
                              // If a ChoiceChip is deselected, it means we might want to clear
                              // but standard ChoiceChip behavior doesn't allow direct deselect.
                              // The 'Clear' button handles removing the filter.
                              // If it must be deselectable, FilterChip might be better.
                              _selectedCategoryFilter =
                                  null; // Or handle as needed
                            }
                          });
                          Navigator.pop(
                            context,
                          ); // Close bottom sheet after selection
                        },
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.onPrimaryContainer,
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  // --- End: Filter Bottom Sheet (Old - kept for reference if needed, will be removed later) ---

  // +++ Start: Unified Filter Bottom Sheet +++
  void _showUnifiedFilterBottomSheet() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!; // Add this line
    // Temporary state holders for the bottom sheet
    // bool? tempCompletionStatus = _selectedCompletionStatus; // REMOVE - No longer needed
    String? tempCategoryFilter = _selectedCategoryFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow sheet to take more height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage sheet's internal state
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 20.0,
                // Add padding for bottom safe area (keyboard, navigation bar)
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by Category',
                        style: theme.textTheme.titleLarge,
                      ), // Updated title
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            // tempCompletionStatus = null; // REMOVE
                            tempCategoryFilter = null;
                          });
                        },
                        child: const Text(
                          'Clear Filter',
                        ), // Updated button text
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // REMOVE Status Filter Section
                  // Text('Status', style: theme.textTheme.titleMedium),
                  // const SizedBox(height: 8),
                  // Wrap(
                  //   spacing: 8.0,
                  //   children: <Widget>[
                  //     ChoiceChip(
                  //       label: const Text('All'),
                  //       selected: tempCompletionStatus == null,
                  //       onSelected: (selected) {
                  //         if (selected) {
                  //           setModalState(() => tempCompletionStatus = null);
                  //         }
                  //       },
                  //     ),
                  //     ChoiceChip(
                  //       label: const Text('Active'),
                  //       selected: tempCompletionStatus == false,
                  //       onSelected: (selected) {
                  //         if (selected) {
                  //           setModalState(() => tempCompletionStatus = false);
                  //         }
                  //       },
                  //     ),
                  //     ChoiceChip(
                  //       label: const Text('Completed'),
                  //       selected: tempCompletionStatus == true,
                  //       onSelected: (selected) {
                  //         if (selected) {
                  //           setModalState(() => tempCompletionStatus = true);
                  //         }
                  //       },
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 20),

                  // Category Filter
                  Text('Category', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children:
                        _availableTaskCategories.map((category) {
                          return FilterChip(
                            label: Text(category),
                            selected: tempCategoryFilter == category,
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  tempCategoryFilter = category;
                                } else {
                                  // If deselected, clear the filter
                                  tempCategoryFilter = null;
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Just close
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Apply the temporary filters to the main screen state
                          setState(() {
                            // _selectedCompletionStatus = tempCompletionStatus; // REMOVE
                            _selectedCategoryFilter = tempCategoryFilter;
                          });
                          Navigator.pop(context); // Close the bottom sheet
                        },
                        child: const Text(
                          'Apply Filter',
                        ), // Updated button text
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // +++ End: Unified Filter Bottom Sheet +++

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!; // Add this line
    // Determine if category filter is active
    final bool isCategoryFilterActive = _selectedCategoryFilter != null;

    return Scaffold(
      appBar:
          widget.showAppBar
              ? AppBar(
                title: const Text('My Tasks'),
                actions: [
                  IconButton(
                    // Use category filter status for icon state
                    icon: Icon(
                      isCategoryFilterActive
                          ? Icons.filter_list_alt
                          : Icons.filter_list,
                    ),
                    tooltip: 'Filter by Category', // Update tooltip
                    // Use category filter status for color
                    color:
                        isCategoryFilterActive
                            ? theme.colorScheme.primary
                            : null,
                    onPressed: _showUnifiedFilterBottomSheet,
                  ),
                ],
              )
              : null,
      body: Column(
        children: [
          // Page Indicators (Active/Completed Buttons)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: ToggleButtons(
              isSelected: [
                _selectedViewStatus == TaskViewStatus.active,
                _selectedViewStatus == TaskViewStatus.completed,
              ],
              onPressed: (int index) {
                setState(() {
                  _selectedViewStatus = TaskViewStatus.values[index];
                });
              },
              borderRadius: BorderRadius.circular(12),
              selectedColor: theme.colorScheme.onPrimary,
              fillColor: theme.colorScheme.primary,
              color: theme.colorScheme.primary,
              constraints: BoxConstraints(
                minHeight: 40.0,
                minWidth:
                    (MediaQuery.of(context).size.width - 32 - 4) /
                    2, // Adjust width based on padding
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  // Use localization key
                  child: Text(localizations.activeTasksTab ?? 'Active'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  // Use localization key
                  child: Text(localizations.completedTasksTab ?? 'Completed'),
                ),
              ],
            ),
          ),

          // PageView
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _getAllTasksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // Updated empty state check: Check if snapshot has data and if it's empty *after filtering*
                // The main empty state (no tasks at all) is handled before this.
                final allTasks = snapshot.data ?? []; // Handle null case

                // Filter tasks first based on the toggle button state
                final tasksToShow =
                    allTasks
                        .where(
                          (task) =>
                              task.isCompleted ==
                              (_selectedViewStatus == TaskViewStatus.completed),
                        )
                        .toList();

                // Combined check for initial load (no data yet) or empty list (either no tasks or none match filter)
                if (!snapshot.hasData || tasksToShow.isEmpty) {
                  // Determine if *any* tasks exist, regardless of filter
                  final bool anyTasksExist = allTasks.isNotEmpty;
                  final bool categoryFilterActive =
                      _selectedCategoryFilter != null;

                  String emptyMessage;
                  String suggestionMessage = '';

                  if (!anyTasksExist && !categoryFilterActive) {
                    // Case: No tasks at all for the user
                    emptyMessage = 'No tasks found.';
                    suggestionMessage =
                        'Tap the "+" button to add your first task.';
                  } else {
                    // Case: Tasks exist, but none match current view/filter
                    if (categoryFilterActive) {
                      emptyMessage =
                          _selectedViewStatus == TaskViewStatus.completed
                              ? 'No completed tasks match your filter.'
                              : 'No active tasks match your filter.';
                      suggestionMessage =
                          'Try adjusting or clearing the category filter.';
                    } else {
                      emptyMessage =
                          _selectedViewStatus == TaskViewStatus.completed
                              ? 'No completed tasks yet.'
                              : 'No active tasks. Well done!';
                      // No suggestion needed if no category filter is active
                    }
                  }

                  // Build the empty state UI
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            // Choose icon based on why it's empty
                            !anyTasksExist && !categoryFilterActive
                                ? Icons
                                    .task_alt_outlined // General task icon
                                : categoryFilterActive
                                ? Icons
                                    .filter_alt_off_outlined // Filtered empty
                                : (_selectedViewStatus ==
                                        TaskViewStatus.completed
                                    ? Icons
                                        .history_toggle_off_outlined // Completed empty
                                    : Icons
                                        .check_circle_outline), // Active empty
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            emptyMessage,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (suggestionMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                suggestionMessage,
                                style: const TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                // If we reach here, tasksToShow is not empty
                // Pass *all* tasks to the builder, it will filter internally again
                // (This is slightly redundant but matches the current _buildTaskListWidget structure)
                // Alternatively, modify _buildTaskListWidget to accept the already filtered list.
                // Let's keep it as is for now to minimize changes.
                return _buildTaskListWidget(
                  context,
                  allTasks,
                  _selectedViewStatus,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    String taskId,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this task?'),
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
                foregroundColor:
                    Theme.of(
                      dialogContext,
                    ).colorScheme.error, // Changed context to dialogContext
              ),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Pop before async operation
                _deleteTask(taskId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      // Assuming _taskService.deleteTask and _notificationService.cancelTaskReminder are async
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();

      // Cancel the notification for the deleted task
      final int notificationId = "task_$taskId".hashCode;
      await _notificationService.cancelNotification(notificationId);
      debugPrint("Cancelled notification for deleted task $taskId");

      if (!mounted) {
        return;
      } // Guard after async operations
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      } // Guard in catch block after potential async operations before this point (if any)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: ${e.toString()}')),
      );
      debugPrint('Error deleting task: $e');
    }
  }
}
