import 'package:flutter/material.dart';
import 'package:projectv1/src/features/weather/domain/models/weather_forecast_model.dart';
import 'package:projectv1/src/features/weather/domain/services/weather_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // For loading state
import 'package:collection/collection.dart'; // Import for groupBy
import 'package:projectv1/generated/l10n/app_localizations.dart'; // Import localizations

class FiveDayForecastScreen extends StatefulWidget {
  final String city;

  const FiveDayForecastScreen({super.key, required this.city});

  @override
  State<FiveDayForecastScreen> createState() => _FiveDayForecastScreenState();
}

class _FiveDayForecastScreenState extends State<FiveDayForecastScreen> {
  final WeatherService _weatherService = WeatherService();
  // Store forecasts grouped by day
  Map<DateTime, List<WeatherForecast>> _groupedForecasts = {};
  List<DateTime> _sortedDays = []; // To maintain order
  bool _isLoading = true;
  String? _error;

  final List<int> _targetHours = [9, 12, 15, 18, 21];

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final allForecasts = await _weatherService.getFiveDayForecast(
        widget.city,
      );

      final filteredForecasts =
          allForecasts.where((forecast) {
            final localHour = forecast.date.toLocal().hour;
            return _targetHours.contains(localHour);
          }).toList();

      // Group filtered forecasts by date (day only)
      final grouped = groupBy(filteredForecasts, (WeatherForecast forecast) {
        final localDate = forecast.date.toLocal();
        return DateTime(localDate.year, localDate.month, localDate.day);
      });

      // Sort the days
      final sortedDays = grouped.keys.toList()..sort();

      if (mounted) {
        setState(() {
          _groupedForecasts = grouped; // Store the grouped map
          _sortedDays = sortedDays; // Store sorted keys
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final localizations =
            AppLocalizations.of(context)!; // Initialize here instead
        setState(() {
          _error = localizations.fiveDayForecastLoadError(
            e.toString(),
          ); // Use localization
          _isLoading = false;
        });
      }
      debugPrint("Error fetching 5-day forecast for ${widget.city}: $e");
    }
  }

  Widget _buildShimmerLoading({double height = 80.0, int itemCount = 5}) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.588),
            highlightColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.862),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!; // Get localizations
    final locale =
        Localizations.localeOf(context).toString(); // Get current locale

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.fiveDayForecastTitle(widget.city),
        ), // Use localization
      ),
      body:
          _isLoading
              ? _buildShimmerLoading()
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
              : _groupedForecasts
                  .isEmpty // Check if the grouped map is empty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 60,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.fiveDayForecastNoData(
                          _targetHours.join(', '),
                        ), // Use localization
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.disabledColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
              // Change body to CustomScrollView
              : CustomScrollView(
                slivers: [
                  // Iterate through sorted days to build sections
                  for (
                    int dayIndex = 0;
                    dayIndex < _sortedDays.length;
                    dayIndex++
                  ) ...[
                    // Add divider *before* the day's grid (except for the first day)
                    if (dayIndex > 0)
                      SliverToBoxAdapter(
                        child: _buildDayDivider(theme, _sortedDays[dayIndex]),
                      ),
                    // Add padding around the grid for this day
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical:
                            8.0, // Add some vertical padding between divider and grid
                      ),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Three columns
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio:
                                  0.9, // Adjust aspect ratio as needed
                            ),
                        // Build grid items for the current day
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Get the forecast item for this specific day and index
                            final forecast =
                                _groupedForecasts[_sortedDays[dayIndex]]![index];
                            // Return the forecast card (same card widget as before)
                            return _buildForecastCard(theme, forecast);
                          },
                          // Set the number of items for the current day's grid
                          childCount:
                              _groupedForecasts[_sortedDays[dayIndex]]!.length,
                        ),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ), // Add padding at the end
                ],
              ),
    );
  }

  // Extracted method to build the forecast card (reused from previous GridView builder)
  Widget _buildForecastCard(ThemeData theme, WeatherForecast forecast) {
    final locale =
        Localizations.localeOf(context).toString(); // Get current locale

    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat.E(locale).format(
                forecast.date.toLocal(),
              ), // Use locale for short day name
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat.jm(
                locale,
              ).format(forecast.date.toLocal()), // Use locale for time
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            if (forecast.iconUrl.isNotEmpty)
              Image.network(
                forecast.iconUrl,
                width: 32,
                height: 32,
                errorBuilder:
                    (c, e, s) => Icon(
                      Icons.error_outline,
                      size: 32,
                      color: theme.colorScheme.error,
                    ),
              )
            else
              Icon(
                Icons.help_outline, // Placeholder if no icon
                size: 32,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            const SizedBox(height: 4),
            Text(
              '${forecast.temperature.toStringAsFixed(0)}°C',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              forecast.condition,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the divider with day name
  Widget _buildDayDivider(ThemeData theme, DateTime date) {
    final localizations = AppLocalizations.of(context)!; // Get localizations
    final locale =
        Localizations.localeOf(context).toString(); // Get current locale

    String dayText = DateFormat.EEEE().format(date.toLocal()); // e.g., "Monday"
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 1,
              height: 1,
              color: theme.dividerColor.withOpacity(0.6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              DateFormat(
                localizations.fiveDayForecastDayDividerFormat,
                locale,
              ).format(date.toLocal()), // Use localized format and locale
              style: theme.textTheme.titleMedium?.copyWith(
                // Use labelMedium or similar style
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 1,
              height: 1,
              color: theme.dividerColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
