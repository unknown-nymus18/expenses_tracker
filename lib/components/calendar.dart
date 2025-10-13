import 'package:expenses_app/models/transaction.dart';
import 'package:expenses_app/pages/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenses_app/providers/theme_provider.dart';

class Calendar extends StatefulWidget {
  final List<Transaction> highlightedDays;
  const Calendar({super.key, this.highlightedDays = const []});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
  DateTime now = DateTime.now();
  DateTime currentDateTime = DateTime.now();
  DateTime? firstDay;
  List<DateTime>? days;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<String> weekDays = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize animations
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    getDays();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void getDays() {
    days = getDaysInMonth(currentDateTime.year, currentDateTime.month);

    firstDay = days![0];
    int dayOfWeek = firstDay!.weekday % 7; // Sunday = 0, Monday = 1, etc.
    for (int i = 0; i < dayOfWeek; i++) {
      days!.insert(
        0,
        DateTime(
          currentDateTime.year,
          currentDateTime.month,
          0,
        ).subtract(Duration(days: i)),
      );
    }
  }

  List<DateTime> getDaysInMonth(int year, int month) {
    var firstDayOfMonth = DateTime(year, month, 1);
    var firstDayoFNextMonth = DateTime(year, month + 1, 1);
    var numberOfDays = firstDayoFNextMonth.difference(firstDayOfMonth).inDays;

    return List.generate(numberOfDays, (i) => DateTime(year, month, i + 1));
  }

  // Animation method for month changes
  Future<void> _animateToMonth(DateTime newDateTime, bool isForward) async {
    // Set slide direction
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: Offset(isForward ? -1.0 : 1.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start fade out animation
    await _fadeController.forward();

    // Update the calendar data
    setState(() {
      currentDateTime = newDateTime;
      selectedYear = currentDateTime.year;
      selectedMonth = currentDateTime.month;
      getDays();
    });

    // Reset animations for fade in
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: Offset(isForward ? 1.0 : -1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOutCubic,
          ),
        );

    // Reset controllers and animate in
    _fadeController.reset();
    _slideController.reset();

    await Future.wait([_fadeController.forward(), _slideController.forward()]);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeProvider.isDarkMode();

    const double spacing = 4.0;
    const double padding = 16.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with month/year and navigation
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () async {
                    DateTime newDateTime;
                    if (currentDateTime.month == 1) {
                      newDateTime = DateTime(currentDateTime.year - 1, 12);
                    } else {
                      newDateTime = DateTime(
                        currentDateTime.year,
                        currentDateTime.month - 1,
                        1,
                      );
                    }
                    await _animateToMonth(newDateTime, false);
                  },
                  icon: Icon(
                    Icons.chevron_left,
                    color: colorScheme.onSurface,
                    size: 28,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      months[currentDateTime.month - 1],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      currentDateTime.year.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () async {
                    DateTime newDateTime;
                    if (currentDateTime.month == 12) {
                      newDateTime = DateTime(currentDateTime.year + 1, 1);
                    } else {
                      newDateTime = DateTime(
                        currentDateTime.year,
                        currentDateTime.month + 1,
                        1,
                      );
                    }
                    await _animateToMonth(newDateTime, true);
                  },
                  icon: Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Weekday headers
          Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Row(
              children: weekDays.map((day) {
                return Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      day.substring(0, 3),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Calendar grid - flexible sizing based on available space
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([_slideController, _fadeController]),
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: GridView.builder(
                      itemCount: days!.length,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                      ),
                      itemBuilder: (context, index) {
                        bool isPreviousMonth =
                            firstDay!.difference(days![index]).inHours > 0;
                        bool isToday =
                            days![index].day == now.day &&
                            currentDateTime.year == now.year &&
                            currentDateTime.month == now.month;

                        bool isHighlighted = widget.highlightedDays.any(
                          (element) =>
                              element.createdAt.day == days![index].day &&
                              element.createdAt.month == days![index].month &&
                              element.createdAt.year == days![index].year,
                        );

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionDetails(
                                  transactions: widget.highlightedDays
                                      .where(
                                        (element) =>
                                            element.createdAt.day ==
                                                days![index].day &&
                                            element.createdAt.month ==
                                                days![index].month &&
                                            element.createdAt.year ==
                                                days![index].year,
                                      )
                                      .toList(),
                                ),
                              ),
                            );
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              color: isPreviousMonth
                                  ? colorScheme.surface.withOpacity(0.3)
                                  : isHighlighted
                                  ? Colors.green
                                  : isToday
                                  ? colorScheme.primary.withOpacity(0.2)
                                  : colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isPreviousMonth
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    // : isHighlighted
                                    // ? Colors.green
                                    : isToday
                                    ? colorScheme.primary
                                    : colorScheme.outline.withOpacity(0.2),
                                width: isHighlighted || isToday ? 2 : 1,
                              ),
                              boxShadow: isHighlighted
                                  ? [
                                      BoxShadow(
                                        color: colorScheme.primary.withOpacity(
                                          0.3,
                                        ),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                "${days![index].day}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isHighlighted || isToday
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isPreviousMonth
                                      ? colorScheme.onSurface.withOpacity(0.3)
                                      : isHighlighted
                                      ? colorScheme.onPrimary
                                      : isToday
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
