import 'package:ams/models/session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class DateTest extends StatefulWidget {
  const DateTest({super.key});

  @override
  State<DateTest> createState() => _DateTestState();
}

class _DateTestState extends State<DateTest> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<Session> sessions = [];
  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    DateTime session1StartDate = DateTime(2024, 4, 18, 1);
    var session1 = Session(name: "Math", scheduledStartDate: session1StartDate, weekly: true, onMonday: true, onTuesday: true);

    DateTime checkDate = session1StartDate;
    for (int i = 0; i < 14; i++) {
      String dateString = DateFormat('dd MMMM EEEE').format(checkDate);
      bool isSessionDay = occursOn(checkDate, session1);
      print('session1 occurs on $dateString: ${isSessionDay ? "Yes" : "No"}');
      checkDate = checkDate.add(const Duration(days: 1));
    }

    print("\n\n");
    DateTime session2StartDate = DateTime(2024, 4, 18, 1);
    var session2 = Session(name: "Math", scheduledStartDate: session1StartDate, daily: true, dayIndex: 3);

    checkDate = session2StartDate;
    for (int i = 0; i < 14; i++) {
      String dateString = DateFormat('dd MMMM EEEE').format(checkDate);
      bool isSessionDay = occursOn(checkDate, session2);
      print('session2 occurs on $dateString: ${isSessionDay ? "Yes" : "No"}');
      checkDate = checkDate.add(const Duration(days: 1));
    }
  }

  bool occursOn(DateTime date, Session session) {
    if (session.weekly) {
      if (date.weekday == DateTime.monday && session.onMonday) return true;
      if (date.weekday == DateTime.tuesday && session.onTuesday) return true;
      if (date.weekday == DateTime.wednesday && session.onWednesday) return true;
      if (date.weekday == DateTime.thursday && session.onThursday) return true;
      if (date.weekday == DateTime.friday && session.onFriday) return true;
      if (date.weekday == DateTime.saturday && session.onSaturday) return true;
      if (date.weekday == DateTime.sunday && session.onSunday) return true;
    }
    else if (session.dayIndex > 0) {
      int daysSinceStart = date.difference(session.scheduledStartDate).inDays;
      return daysSinceStart % session.dayIndex == 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Calendar'),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay; // This ensures the calendar updates displayed month.
          });
        },
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay; // No need to call `setState()` here
        },
      ),
    );
  }
}
