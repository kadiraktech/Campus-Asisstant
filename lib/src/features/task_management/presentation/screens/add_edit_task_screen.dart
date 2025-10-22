import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:projectv1/src/features/task_management/domain/models/task_model.dart';
import 'package:projectv1/src/core/services/notification_service.dart'; // Import NotificationService
import 'package:projectv1/src/features/user_profile/domain/models/user_profile_model.dart'; // Import UserProfile
import 'package:projectv1/src/features/user_profile/domain/services/user_profile_service.dart'; // Import UserProfileService
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:projectv1/generated/l10n/app_localizations.dart'; // Import localizations
// Import main.dart for the global plugin instance
// import 'package:projectv1/src/core/theme/app_theme.dart'; // AppTheme.elevatedButtonStyle was an issue

class AddEditTaskScreen extends StatefulWidget {
  final Task?
  task; // Null if adding a new task, otherwise editing existing task

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _taskNameController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedReminderTime; // For reminder time
  String? _selectedCategory;
  bool _isLoading = false;
  final NotificationService _notificationService =
      NotificationService(); // Updated instantiation
  final UserProfileService _userProfileService =
      UserProfileService(); // Add UserProfileService
  UserProfile? _userProfile; // Add UserProfile state

  // Define categories using localization keys
  List<String> _getLocalizedTaskCategories(AppLocalizations localizations) {
    return [
      localizations.taskCategoryAssignment,
      localizations.taskCategoryExam,
      localizations.taskCategoryReminder,
      localizations.taskCategoryOther,
    ];
  }

  // Modify _taskCategories initialization if needed, or use the method above directly
  // Let's keep _taskCategories for now to minimize structural changes, but populate it later

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize categories here where context is available
    final localizations = AppLocalizations.of(context)!;
    _taskCategories = _getLocalizedTaskCategories(localizations);

    // Re-run the logic to handle existing task category if it's not standard
    if (widget.task != null &&
        _selectedCategory != null &&
        !_taskCategories.contains(_selectedCategory!)) {
      _taskCategories.add(_selectedCategory!);
    } else if (widget.task != null &&
        _selectedCategory == null &&
        widget.task!.category.isNotEmpty) {
      _selectedCategory = widget.task!.category;
      if (!_taskCategories.contains(_selectedCategory!)) {
        _taskCategories.add(_selectedCategory!);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.task?.taskName);
    _descriptionController = TextEditingController(
      text: widget.task?.description,
    );
    _selectedDueDate = widget.task?.dueDate;
    _selectedCategory = widget.task?.category;

    if (widget.task?.reminderTime != null) {
      _selectedReminderTime = TimeOfDay.fromDateTime(
        widget.task!.reminderTime!,
      );
    }
    _loadUserProfile(); // Load profile in initState
  }

  Future<void> _loadUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final profile = await _userProfileService.getUserProfile(
          currentUser.uid,
        );
        if (mounted) {
          setState(() {
            _userProfile = profile;
          });
        }
      } catch (e) {
        if (mounted) {
          debugPrint("Error loading user profile in AddEditTaskScreen: $e");
          // Handle error - for now, if profile is null, reminder scheduling might be skipped or use defaults
        }
      }
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // Allow up to one year in past
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 5),
      ), // Allow 5 years in future
    );
    if (pickedDate != null && pickedDate != _selectedDueDate) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  void _showModernReminderTimePicker(AppLocalizations localizations) {
    // Pass localizations
    final initial = _selectedReminderTime ?? TimeOfDay.now();
    Navigator.of(context).push(
      showPicker(
        context: context,
        value: Time(hour: initial.hour, minute: initial.minute),
        is24HrFormat: true,
        accentColor: Theme.of(context).colorScheme.primary,
        okText: localizations.timePickerOkText, // Use localization
        cancelText: localizations.timePickerCancelText, // Use localization
        blurredBackground: true,
        onChange: (Time newTime) {
          setState(() {
            _selectedReminderTime = TimeOfDay(
              hour: newTime.hour,
              minute: newTime.minute,
            );
          });
        },
      ),
    );
  }

  Future<void> _saveTask() async {
    final localizations =
        AppLocalizations.of(context)!; // Get localizations instance

    if (!_formKey.currentState!.validate()) {
      return; // Validation failed
    }
    // _formKey.currentState!.save(); // save() is called by FormFields themselves, not needed here explicitly if not using onSaved directly for other logic

    if (_selectedDueDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.selectDueDateError),
          ), // Use localization
        );
      }
      return;
    }

    // Category is now validated by DropdownButtonFormField's validator

    DateTime? finalReminderDateTime;
    if (_selectedReminderTime != null) {
      // Use the selected due date for the reminder's date part
      finalReminderDateTime = DateTime(
        _selectedDueDate!.year,
        _selectedDueDate!.month,
        _selectedDueDate!.day,
        _selectedReminderTime!.hour,
        _selectedReminderTime!.minute,
      );

      // Validate that reminder time is before due date (if both are set)
      // Combine due date with a default time (e.g., end of day for comparison, or just compare dates if reminder is on a previous day)
      // For simplicity, let's ensure reminder is strictly before the due date if on the same day,
      // or on a previous day.
      // A more precise due date time might be needed if tasks have specific due times.
      // Assuming due date means by end of that day for this comparison.
      final DateTime effectiveDueDate = DateTime(
        _selectedDueDate!.year,
        _selectedDueDate!.month,
        _selectedDueDate!.day,
        23,
        59,
        59,
      );

      if (finalReminderDateTime.isAfter(effectiveDueDate)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.reminderBeforeDueError,
              ), // Use localization
            ),
          );
        }
        return;
      }
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.mustBeLoggedInError),
          ), // Use localization
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    // Ensure user profile is loaded before proceeding to save and schedule notifications
    if (_userProfile == null) {
      await _loadUserProfile(); // Attempt to load again if null
      if (_userProfile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.profileNotLoadedError, // Use localization
              ),
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
    }

    final taskDataMap = {
      'userId': user.uid,
      'taskName': _taskNameController.text.trim(),
      'description':
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      'dueDate':
          _selectedDueDate != null
              ? Timestamp.fromDate(_selectedDueDate!)
              : null,
      // IMPORTANT: Store the ENGLISH category name or a non-localized key in Firestore
      // Mapping back from localized category name to a key might be complex.
      // Let's store the selected value which *might* be localized if _selectedCategory was set from dropdown.
      // A better approach is to use keys/enums for categories internally.
      // For now, we store whatever is in _selectedCategory.
      'category':
          _selectedCategory ??
          localizations
              .taskCategoryOther, // Use localized 'Other' as default if needed
      'isCompleted': widget.task?.isCompleted ?? false,
      'reminderTime':
          finalReminderDateTime != null
              ? Timestamp.fromDate(finalReminderDateTime)
              : null, // Add reminderTime
    };

    try {
      String taskId;
      if (widget.task == null) {
        // Adding a new task
        final docRef = await FirebaseFirestore.instance
            .collection('tasks')
            .add(taskDataMap); // Use the map directly
        taskId = docRef.id;
      } else {
        // Editing an existing task
        taskId = widget.task!.taskId;
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(taskId)
            .update(taskDataMap); // Use the map directly
      }

      // Create a Task object to pass to notification service
      // This requires all fields that Task.fromFirestore would populate, or a constructor that matches taskDataMap
      // For simplicity, let's construct it manually here.
      final Task currentTask = Task(
        taskId: taskId,
        userId: user.uid,
        taskName: taskDataMap['taskName'] as String,
        dueDate: _selectedDueDate!, // Already validated not null
        category: taskDataMap['category'] as String,
        description: taskDataMap['description'] as String?,
        reminderTime: finalReminderDateTime, // This is DateTime?
        isCompleted: taskDataMap['isCompleted'] as bool,
      );

      if (currentTask.reminderTime != null) {
        // Only schedule if reminder time is set on the task
        await _notificationService.scheduleTaskReminder(
          task: currentTask,
          remindersEnabled: _userProfile!.notificationsTaskRemindersEnabled,
        );
      } else {
        // If reminder time was removed or not set, cancel any existing notification
        await _notificationService.cancelNotification(
          "task_${currentTask.taskId}".hashCode,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.task == null
                  ? localizations
                      .taskAddedSuccess // Use localization
                  : localizations.taskUpdatedSuccess, // Use localization
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.taskSaveFailed(e.toString()))),
        ); // Use localization with placeholder
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTask() async {
    final localizations =
        AppLocalizations.of(context)!; // Get localizations instance
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.confirmDeleteTitle), // Use localization
          content: Text(localizations.confirmDeleteContent), // Use localization
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
              child: Text(localizations.deleteAction), // Use localization
            ),
          ],
        );
      },
    );

    if (confirmDelete == true && widget.task != null) {
      setState(() => _isLoading = true);
      try {
        // Attempt to cancel notification before deleting
        await _notificationService.cancelTaskReminder(widget.task!);

        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(widget.task!.taskId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.taskDeletedSuccess),
            ), // Use localization
          );
          Navigator.of(
            context,
          ).pop(); // Pop twice if you want to go back to task list after delete
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.taskDeleteFailed(e.toString())),
            ),
          ); // Use localization with placeholder
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Move this list outside build method if it doesn't depend on context directly
  // But it uses localizations, so let's keep it here or pass localizations
  late List<String> _taskCategories;

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.task != null;
    final theme = Theme.of(context); // Get theme data
    final localizations =
        AppLocalizations.of(context)!; // Get localizations instance

    // Initialize categories if not already done (e.g., if didChangeDependencies wasn't called first)
    // This check might be redundant if didChangeDependencies always runs before build
    if (_taskCategories == null || _taskCategories.isEmpty) {
      _taskCategories = _getLocalizedTaskCategories(localizations);
      // Apply existing task category logic again if necessary
      if (widget.task != null &&
          _selectedCategory != null &&
          !_taskCategories.contains(_selectedCategory!)) {
        _taskCategories.add(_selectedCategory!);
      } else if (widget.task != null &&
          _selectedCategory == null &&
          widget.task!.category.isNotEmpty) {
        _selectedCategory = widget.task!.category;
        if (!_taskCategories.contains(_selectedCategory!)) {
          _taskCategories.add(_selectedCategory!);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? localizations.editTaskTitle : localizations.addTaskTitle,
        ), // Use localization
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed:
                  _isLoading ? null : _deleteTask, // Call _deleteTask method
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode:
                      AutovalidateMode.onUserInteraction, // Added for better UX
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _taskNameController,
                        maxLength: 100,
                        decoration: InputDecoration(
                          labelText:
                              localizations.taskNameLabel, // Use localization
                          hintText:
                              localizations
                                  .taskNameHint, // Use localization (Optional)
                          border: const OutlineInputBorder(),
                          counterText: "",
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return localizations
                                .taskNameValidationEmpty; // Use localization
                          }
                          if (value.trim().length > 100) {
                            return localizations
                                .taskNameValidationLength; // Use localization
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText:
                              localizations
                                  .taskDescriptionLabel, // Use localization
                          hintText:
                              localizations
                                  .taskDescriptionHint, // Use localization (Optional)
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20.0),
                      Card(
                        // Wrap ListTile with Card for better visual separation and theming
                        margin:
                            EdgeInsets
                                .zero, // Remove card margin if ListTile provides enough
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withAlpha(
                              (0.5 * 255).round(),
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            _selectedDueDate == null
                                ? localizations
                                    .selectDueDateLabel // Use localization
                                : '${localizations.dueDatePrefix}${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_selectedDueDate!)}', // Use localization prefix & explicit locale
                          ),
                          trailing: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                          onTap: () => _pickDueDate(context),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText:
                              localizations
                                  .taskCategoryLabel, // Use localization
                          border: const OutlineInputBorder(),
                        ),
                        items:
                            _taskCategories.map((String category) {
                              // Assume _taskCategories now holds localized strings
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? localizations
                                        .taskCategoryValidationEmpty // Use localization
                                    : null,
                      ),
                      const SizedBox(height: 16.0),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                        ),
                        title: Text(
                          // Use localization prefix and 'Not Set'
                          '${localizations.reminderTimePrefix}${_selectedReminderTime != null ? _selectedReminderTime!.format(context) : localizations.reminderTimeNotSet}',
                        ),
                        trailing:
                            _selectedReminderTime != null
                                ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedReminderTime = null;
                                    });
                                  },
                                  tooltip:
                                      localizations
                                          .clearReminderTooltip, // Use localization
                                )
                                : const Icon(
                                  Icons.notifications_active_outlined,
                                ),
                        onTap:
                            () => _showModernReminderTimePicker(
                              localizations,
                            ), // Pass localizations
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveTask,
                        style: ElevatedButton.styleFrom(
                          // Using theme for button styling for consistency
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: Text(
                          isEditMode
                              ? localizations.updateTaskButton
                              : localizations.addTaskButton,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
