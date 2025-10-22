import 'package:flutter/material.dart';
import 'package:projectv1/src/features/course_schedule/domain/models/course_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectv1/src/core/services/notification_service.dart';
import 'package:projectv1/src/features/user_profile/domain/models/user_profile_model.dart';
import 'package:projectv1/src/features/user_profile/domain/services/user_profile_service.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:projectv1/src/core/config/api_keys.dart'; // Import API key
import 'package:projectv1/generated/l10n/app_localizations.dart'; // Import localizations

class AddEditCourseScreen extends StatefulWidget {
  final Course? course; // Null if adding a new course, non-null if editing

  const AddEditCourseScreen({super.key, this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController
  _locationController; // For general area/building for weather
  late TextEditingController _classroomController; // For specific room/hall
  late TextEditingController _instructorController; // Added for instructor

  // For simplicity, using String for dayOfWeek, startTime, endTime for now.
  // These could be improved with Dropdowns or TimePickers.
  String? _selectedDayOfWeek;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  bool _isLoading = false;

  // --- Start: Location Suggestion Logic (Adapted from SettingsScreen) ---
  Timer? _debounce;
  List<String> _locationSuggestions = [];
  bool _isFetchingSuggestions = false;
  String? _selectedLocationFromSuggestion;
  final GlobalKey _locationFieldKey =
      GlobalKey(); // Key for Autocomplete context
  // --- End: Location Suggestion Logic ---

  final NotificationService _notificationService = NotificationService();
  final UserProfileService _userProfileService = UserProfileService();
  UserProfile? _userProfile;

  // Map English day name to localized day name
  Map<String, String> _localizedDaysMap = {};
  // List of localized day names for the dropdown
  List<String> _localizedDaysOfWeekForDropdown = [];

  // English days used for internal logic and Firestore saving
  final List<String> _englishDaysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize localized days here where context is available
    final localizations = AppLocalizations.of(context)!;
    _localizedDaysMap = {
      'Monday': localizations.dayMonday,
      'Tuesday': localizations.dayTuesday,
      'Wednesday': localizations.dayWednesday,
      'Thursday': localizations.dayThursday,
      'Friday': localizations.dayFriday,
      'Saturday': localizations.daySaturday,
      'Sunday': localizations.daySunday,
    };
    _localizedDaysOfWeekForDropdown =
        _englishDaysOfWeek
            .map(
              (day) => _localizedDaysMap[day] ?? day,
            ) // Fallback to English if map fails
            .toList();

    // Convert existing selected English day to localized for dropdown initial value
    // Note: _selectedDayOfWeek still holds the English value for saving
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course?.name ?? '');
    _locationController = TextEditingController(
      text: widget.course?.location ?? '',
    );
    _classroomController = TextEditingController(
      text: widget.course?.classroom ?? '', // Initialize classroom controller
    );
    _instructorController = TextEditingController(
      text: widget.course?.instructor ?? '',
    ); // Initialize instructor controller

    // Store the English day name from the course for internal logic/saving
    _selectedDayOfWeek = widget.course?.dayOfWeek;

    if (widget.course != null) {
      if (widget.course!.startTime.isNotEmpty) {
        final parts = widget.course!.startTime.split(':');
        if (parts.length == 2) {
          _selectedStartTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
      if (widget.course!.endTime.isNotEmpty) {
        final parts = widget.course!.endTime.split(':');
        if (parts.length == 2) {
          _selectedEndTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    }
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _classroomController.dispose(); // Dispose classroom controller
    _instructorController.dispose(); // Dispose instructor controller
    super.dispose();
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
          debugPrint("Error loading user profile in AddEditCourseScreen: $e");
        }
      }
    }
  }

  void _showModernTimePicker(bool isStartTime) {
    final localizations = AppLocalizations.of(context)!;
    final initial =
        isStartTime
            ? (_selectedStartTime ?? TimeOfDay.now())
            : (_selectedEndTime ?? TimeOfDay.now());
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
            final picked = TimeOfDay(
              hour: newTime.hour,
              minute: newTime.minute,
            );
            if (isStartTime) {
              _selectedStartTime = picked;
            } else {
              _selectedEndTime = picked;
            }
          });
        },
      ),
    );
  }

  Future<void> _saveCourse() async {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      debugPrint(
        "AddEditCourseScreen: AppLocalizations.of(context) returned null in _saveCourse!",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Error: Localization not available. Cannot save course.",
            ),
          ),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    // --- Hata Ayıklama Başlangıcı ---
    debugPrint(
      "ADD_EDIT_COURSE_SCREEN: _saveCourse -> localizations object is available.",
    );
    try {
      // Basit, parametresiz bir anahtara erişmeyi dene
      debugPrint(
        "ADD_EDIT_COURSE_SCREEN: _saveCourse -> Accessing addCourseTitle: ${localizations.addCourseTitle}",
      );
    } catch (e, s) {
      debugPrint(
        "ADD_EDIT_COURSE_SCREEN: _saveCourse -> ERROR accessing addCourseTitle: $e",
      );
      debugPrint(s.toString());
    }
    try {
      // Sorunlu olabilecek, parametreli anahtara erişmeyi dene
      final String testNotificationTitle = localizations
          .courseNotificationUpcomingTitle("DenemeKursu");
      debugPrint(
        "ADD_EDIT_COURSE_SCREEN: _saveCourse -> Accessing courseNotificationUpcomingTitle: $testNotificationTitle",
      );
    } catch (e, s) {
      debugPrint(
        "ADD_EDIT_COURSE_SCREEN: _saveCourse -> ERROR accessing courseNotificationUpcomingTitle: $e",
      );
      debugPrint(s.toString());
    }
    // --- Hata Ayıklama Sonu ---

    if (_formKey.currentState!.validate()) {
      if (_selectedDayOfWeek == null || // Check English day value
          _selectedStartTime == null ||
          _selectedEndTime == null) {
        if (mounted) {
          // mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.courseErrorTimesMissing,
              ), // Use localization
            ),
          );
        }
        return;
      }
      if (_selectedStartTime!.hour > _selectedEndTime!.hour ||
          (_selectedStartTime!.hour == _selectedEndTime!.hour &&
              _selectedStartTime!.minute >= _selectedEndTime!.minute)) {
        if (mounted) {
          // mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.courseErrorEndTimeBeforeStart),
            ), // Use localization
          );
        }
        return;
      }

      if (mounted) {
        // mounted check
        setState(() {
          _isLoading = true;
        });
      } else {
        // If not mounted, don't proceed with saving, just return.
        // This might happen if the widget is disposed during an async gap before this point.
        return;
      }

      try {
        String userId = FirebaseAuth.instance.currentUser!.uid;
        Course courseToSave = Course(
          id: widget.course?.id,
          userId: userId,
          name: _nameController.text.trim(),
          dayOfWeek: _selectedDayOfWeek!, // SAVE ENGLISH DAY NAME
          startTime:
              "${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}",
          endTime:
              "${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}",
          location: _locationController.text.trim(),
          classroom:
              _classroomController.text.trim().isNotEmpty
                  ? _classroomController.text.trim()
                  : null,
          instructor:
              _instructorController.text.trim().isNotEmpty
                  ? _instructorController.text.trim()
                  : null,
        );

        String successMessage;
        if (widget.course == null) {
          // Adding a new course
          DocumentReference docRef = await FirebaseFirestore.instance
              .collection('courses')
              .add(courseToSave.toFirestore());
          courseToSave = courseToSave.copyWith(id: docRef.id);
          successMessage =
              localizations
                  .courseSaveSuccess; // Assuming generic success message for now
        } else {
          // Editing an existing course
          await FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.course!.id)
              .update(courseToSave.toFirestore());
          successMessage =
              localizations
                  .courseSaveSuccess; // Assuming generic success message for now
        }

        // Schedule notifications
        if (_userProfile?.notificationsCourseRemindersEnabled ?? false) {
          final leadTimeMinutes =
              _userProfile?.notificationsCourseLeadTimeMinutes ?? 10;
          final leadTimeDuration = Duration(minutes: leadTimeMinutes);

          // Ensure localizations is not null. The check at the start of _saveCourse handles this.
          final String notificationTitle = localizations
              .courseNotificationUpcomingTitle(courseToSave.name);

          // Format the time for the notification body.
          // courseToSave.startTime is "HH:mm". We can use it directly.
          // Using courseToSave.location for location. If classroom is preferred, that can be used.
          final String notificationBody = localizations
              .courseNotificationUpcomingBody(
                courseToSave.name,
                courseToSave.startTime, // Already in "HH:mm" format
                courseToSave.location.isNotEmpty
                    ? courseToSave.location
                    : (courseToSave.classroom ??
                        'N/A'), // Use location or classroom
              );

          await _notificationService.scheduleCourseNotification(
            courseToSave,
            leadTimeDuration,
            notificationTitle,
            notificationBody,
          );
        } else {
          // If reminders were off or course is edited,
          // cancel any existing notification for this course to be safe.
          if (courseToSave.id != null) {
            // Check if courseToSave.id is not null
            await _notificationService.cancelCourseNotification(
              courseToSave.id!, // Safe to use ! due to the null check
            );
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(successMessage)));
          Navigator.of(context).pop(true); // Indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.courseSaveFailed(e.toString())),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteCourse() async {
    final localizations = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              localizations.courseDeleteConfirmTitle,
            ), // Use localization
            content: Text(
              localizations.courseDeleteConfirmContent,
            ), // Use localization
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(localizations.cancelAction), // Use localization
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  localizations.courseDeleteConfirmButton,
                ), // Use localization
              ),
            ],
          ),
    );

    if (confirm == true && widget.course != null) {
      setState(() => _isLoading = true);
      try {
        await _notificationService.cancelCourseNotification(widget.course!.id!);
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.course!.id)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.courseDeleteSuccess),
            ), // Use localization
          );
          Navigator.of(context).pop(); // Pop back after delete
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.courseDeleteFailed(e.toString())),
            ), // Use localization
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // --- Start: Location Suggestion Fetching (Adapted from SettingsScreen) ---
  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _locationSuggestions = [];
          _isFetchingSuggestions = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _isFetchingSuggestions = true;
      });
    }

    final Uri uri = Uri.parse(
      'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$openWeatherApiKey',
    );

    debugPrint(
      'ADD_EDIT_COURSE_SCREEN: _fetchLocationSuggestions -> Request URL: $uri',
    );

    try {
      final response = await http.get(uri);
      debugPrint(
        'ADD_EDIT_COURSE_SCREEN: _fetchLocationSuggestions -> Response Status: ${response.statusCode}',
      );
      debugPrint(
        'ADD_EDIT_COURSE_SCREEN: _fetchLocationSuggestions -> Response Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<String> suggestions =
            data.map((item) {
              final String name = item['name'] ?? '';
              final String country = item['country'] ?? '';
              final String? state = item['state'] as String?;
              String suggestion = name;
              if (state != null && state.isNotEmpty && state != name) {
                suggestion += ', $state';
              }
              if (country.isNotEmpty) {
                suggestion += ', $country';
              }
              return suggestion;
            }).toList();

        debugPrint(
          'ADD_EDIT_COURSE_SCREEN: _fetchLocationSuggestions -> Processed Suggestions: $suggestions',
        );

        if (mounted) {
          setState(() {
            _locationSuggestions = suggestions;
          });
        }
      } else {
        if (mounted) {
          // Handle API error, e.g., show a message or log
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error fetching location suggestions: ${response.statusCode}',
              ),
            ),
          );
        }
        _locationSuggestions = []; // Clear suggestions on error
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error fetching location: ${e.toString()}'),
          ),
        );
      }
      _locationSuggestions = []; // Clear suggestions on error
      debugPrint(
        'ADD_EDIT_COURSE_SCREEN: _fetchLocationSuggestions -> Error: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingSuggestions = false;
        });
      }
    }
  }
  // --- End: Location Suggestion Fetching ---

  // --- Start: Location Dialog (Adapted from SettingsScreen) ---
  Future<void> _showSetLocationDialog() async {
    final localizations = AppLocalizations.of(context)!;
    final originalLocation = _locationController.text;
    _selectedLocationFromSuggestion = null; // Reset selection

    return showDialog<void>(
      context: context,
      // ... barrierDismissible ...
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Use StatefulBuilder for internal dialog state
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                localizations.courseLocationDialogTitle,
              ), // Use localization
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      final query = textEditingValue.text;
                      debugPrint(
                        "ADD_EDIT_COURSE_SCREEN: Autocomplete optionsBuilder -> query: '$query'",
                      );
                      if (query.isEmpty) return const Iterable<String>.empty();
                      // Use the fetch function we added earlier
                      await _fetchLocationSuggestions(query);
                      debugPrint(
                        "ADD_EDIT_COURSE_SCREEN: Autocomplete optionsBuilder -> returning _locationSuggestions: ${_locationSuggestions.length} items",
                      );
                      return _locationSuggestions;
                    },
                    fieldViewBuilder: (
                      context,
                      controller, // This is Autocomplete's internal controller
                      focusNode,
                      onFieldSubmitted, // This is Autocomplete's onFieldSubmitted
                    ) {
                      // Initialize with the main controller's text
                      // This controller is local to fieldViewBuilder
                      if (controller.text.isEmpty) {
                        controller.text = _locationController.text;
                      }
                      return TextField(
                        key: _locationFieldKey, // Use the key for context
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: true,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText:
                              localizations
                                  .courseLocationDialogHint, // Use localization
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon:
                              _isFetchingSuggestions
                                  ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                  : null,
                        ),
                        onChanged: (value) {
                          // Trigger fetch on change, debounced
                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                          _debounce = Timer(
                            const Duration(
                              milliseconds:
                                  150, // Süreyi 250ms'den 150ms'ye düşürdük
                            ),
                            () {
                              if (value.isNotEmpty) {
                                // Use the value from the Autocomplete controller
                                _fetchLocationSuggestions(value).then((_) {
                                  if (context.mounted) setDialogState(() {});
                                });
                              } else {
                                setDialogState(() {
                                  _locationSuggestions = [];
                                });
                              }
                            },
                          );
                        },
                        onSubmitted: (String value) {
                          // Kullanıcı Enter'a bastığında
                          debugPrint(
                            "ADD_EDIT_COURSE_SCREEN: TextField onSubmitted -> value: '$value'",
                          );

                          if (_locationSuggestions.isNotEmpty) {
                            // Eğer öneri varsa, ilk öneriyi seçelim
                            final firstSuggestion = _locationSuggestions.first;
                            debugPrint(
                              "ADD_EDIT_COURSE_SCREEN: TextField onSubmitted -> Selecting first suggestion: '$firstSuggestion'",
                            );
                            setDialogState(() {
                              _locationController.text = firstSuggestion;
                              _selectedLocationFromSuggestion = firstSuggestion;
                              _locationSuggestions = [];
                              _isFetchingSuggestions = false;
                            });
                          } else if (value.trim().isNotEmpty) {
                            // Öneri yoksa ama kullanıcı bir şey yazdıysa, onu kabul et
                            debugPrint(
                              "ADD_EDIT_COURSE_SCREEN: TextField onSubmitted -> No suggestions, accepting typed value: '$value'",
                            );
                            setDialogState(() {
                              _locationController.text = value.trim();
                              _selectedLocationFromSuggestion = value.trim();
                            });
                          }
                          // Her durumda klavyeyi kapat ve diyalogdan çıkmak için save butonuna basılmış gibi yapalım
                          // Bu, Autocomplete'in onSelected'ını doğrudan çağırmaz ama diyalogun kapanmasını sağlar.
                          // _showSetLocationDialog içindeki kaydetme butonunun onPress'indeki mantık burada tekrarlanabilir
                          // veya daha basitçe diyalogu kapatabiliriz.
                          // Şimdilik sadece diyalogu kapatalım, ana ekrandaki TextField değeri zaten güncellenmiş olmalı.
                          Navigator.of(context).pop();
                          setState(() {}); // Ana ekranı güncellemek için
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      // Use similar styling as SettingsScreen
                      final theme = Theme.of(context); // Get theme
                      debugPrint(
                        "ADD_EDIT_COURSE_SCREEN: Autocomplete optionsViewBuilder -> building with ${options.length} options.",
                      );
                      double fieldWidth = 320; // Default width
                      final currentContext = _locationFieldKey.currentContext;
                      if (currentContext != null) {
                        final box = currentContext.findRenderObject();
                        if (box is RenderBox) {
                          fieldWidth = box.size.width;
                        }
                      }

                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          // Use Material for elevation and shape
                          color: theme.colorScheme.surface,
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Rounded corners
                          shadowColor: theme.shadowColor.withOpacity(0.2),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 250, // Limit height
                              minWidth: fieldWidth, // Match field width
                              maxWidth: fieldWidth, // Match field width
                            ),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ), // Padding
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder:
                                  (_, __) => Divider(
                                    height: 1,
                                    color: theme.dividerColor.withOpacity(0.1),
                                  ), // Separator
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return InkWell(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ), // InkWell shape
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  hoverColor: theme.colorScheme.primary
                                      .withOpacity(0.08),
                                  splashColor: theme.colorScheme.primary
                                      .withOpacity(0.12),
                                  child: Container(
                                    // Use Container for padding and structure
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      // Row for Icon + Text
                                      children: <Widget>[
                                        Icon(
                                          Icons
                                              .location_on_outlined, // Location Icon
                                          color: theme.colorScheme.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12), // Spacing
                                        Expanded(
                                          // Expanded for Text overflow
                                          child: Text(
                                            option,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onSurface,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    onSelected: (String selection) {
                      // Update the main controller when a suggestion is selected
                      setDialogState(() {
                        debugPrint(
                          "ADD_EDIT_COURSE_SCREEN: Autocomplete onSelected -> selection: '$selection'",
                        );
                        _locationController.text = selection;
                        _selectedLocationFromSuggestion = selection;
                        _locationSuggestions = [];
                        _isFetchingSuggestions = false;
                      });
                      // Optionally close the keyboard
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  // Display the selected chip (optional but good UX)
                  if (_locationController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Chip(
                        label: Text(_locationController.text),
                        onDeleted: () {
                          setDialogState(() {
                            _locationController.clear();
                            _selectedLocationFromSuggestion = null;
                          });
                        },
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(localizations.cancelAction), // Use localization
                  onPressed: () {
                    _locationController.text = originalLocation;
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    localizations.courseLocationDialogSaveButton,
                  ), // Use localization
                  onPressed: () {
                    final locationToSave =
                        _selectedLocationFromSuggestion ??
                        _locationController.text.trim();
                    _locationController.text = locationToSave;
                    Navigator.of(context).pop();
                    setState(() {}); // Trigger main screen rebuild
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  // --- End: Location Dialog ---

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Initialize localized days if not done yet (safety check)
    if (_localizedDaysOfWeekForDropdown.isEmpty) {
      _localizedDaysMap = {
        'Monday': localizations.dayMonday,
        'Tuesday': localizations.dayTuesday,
        'Wednesday': localizations.dayWednesday,
        'Thursday': localizations.dayThursday,
        'Friday': localizations.dayFriday,
        'Saturday': localizations.daySaturday,
        'Sunday': localizations.daySunday,
      };
      _localizedDaysOfWeekForDropdown =
          _englishDaysOfWeek
              .map((day) => _localizedDaysMap[day] ?? day)
              .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course == null
              ? localizations.addCourseTitle
              : localizations.editCourseTitle,
        ), // Use localization
        actions: [
          if (widget.course != null && !_isLoading)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _deleteCourse,
              tooltip: localizations.deleteCourseTooltip, // Use localization
            ),
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveCourse,
              tooltip: localizations.saveCourseTooltip, // Use localization
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText:
                              localizations.courseNameLabel, // Use localization
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations
                                .courseNameValidationEmpty; // Use localization
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // --- Location Field Tile ---
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(
                          localizations.courseLocationLabel,
                        ), // Use localization
                        subtitle: Text(
                          _locationController.text.isEmpty
                              ? localizations
                                  .courseLocationHint // Use localization
                              : _locationController.text,
                        ),
                        trailing: Icon(
                          Icons.edit_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: _showSetLocationDialog,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _classroomController,
                        decoration: InputDecoration(
                          labelText:
                              localizations
                                  .courseClassroomLabel, // Use localization
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _instructorController,
                        decoration: InputDecoration(
                          labelText:
                              localizations
                                  .courseInstructorLabel, // Use localization
                        ),
                      ),
                      const SizedBox(height: 16),
                      // --- Day of Week Dropdown ---
                      DropdownButtonFormField<String>(
                        // IMPORTANT: The VALUE should be the LOCALIZED day name for display
                        value:
                            _selectedDayOfWeek != null
                                ? (_localizedDaysMap[_selectedDayOfWeek!] ??
                                    _selectedDayOfWeek)
                                : null,
                        decoration: InputDecoration(
                          labelText:
                              localizations
                                  .courseDayOfWeekLabel, // Use localization
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        hint: Text(
                          localizations.courseDayOfWeekHint,
                        ), // Use localization
                        isExpanded: true,
                        items:
                            _localizedDaysOfWeekForDropdown.map((
                              String localizedDay,
                            ) {
                              return DropdownMenuItem<String>(
                                value: localizedDay, // Value is localized day
                                child: Text(localizedDay),
                              );
                            }).toList(),
                        onChanged: (String? newValueLocalized) {
                          setState(() {
                            // Find the corresponding English day name to save internally
                            _selectedDayOfWeek =
                                _localizedDaysMap.entries
                                    .firstWhere(
                                      (entry) =>
                                          entry.value == newValueLocalized,
                                      orElse:
                                          () => MapEntry(
                                            newValueLocalized ?? '',
                                            newValueLocalized ?? '',
                                          ),
                                    )
                                    .key;
                          });
                        },
                        validator: (value) {
                          // Validate based on the displayed value (which is localized)
                          if (value == null) {
                            return localizations
                                .courseDayOfWeekValidationEmpty; // Use localization
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () => _showModernTimePicker(true),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText:
                                      localizations
                                          .courseStartTimeLabel, // Use localization
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.access_time),
                                ),
                                child: Text(
                                  _selectedStartTime != null
                                      ? _selectedStartTime!.format(context)
                                      : localizations
                                          .courseSelectTimeHint, // Use localization
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: InkWell(
                              onTap: () => _showModernTimePicker(false),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText:
                                      localizations
                                          .courseEndTimeLabel, // Use localization
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(
                                    Icons.access_time_filled,
                                  ),
                                ),
                                child: Text(
                                  _selectedEndTime != null
                                      ? _selectedEndTime!.format(context)
                                      : localizations
                                          .courseSelectTimeHint, // Use localization
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
    );
  }
}
