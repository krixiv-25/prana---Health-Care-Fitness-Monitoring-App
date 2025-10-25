import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kenko/logadd.dart';

class LogMoodPage extends StatefulWidget {
  const LogMoodPage({super.key});

  @override
  State<LogMoodPage> createState() => _LogMoodPageState();
}

class _LogMoodPageState extends State<LogMoodPage> {
  Map<DateTime, String> moodLog = {};
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  int _selectedIndex = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadMoodsFromFirestore();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color? getMoodColor(DateTime day) {
    final mood = moodLog[DateTime(day.year, day.month, day.day)];
    switch (mood) {
      case 'happy':
        return Colors.yellow;
      case 'neutral':
        return Colors.grey;
      case 'sad':
        return Colors.blue;
      default:
        return null;
    }
  }

  void _selectMood(DateTime day) {
    final formattedDay = DateTime(day.year, day.month, day.day);
    final dateKey =
        "${formattedDay.year}-${formattedDay.month}-${formattedDay.day}";

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Select Your Mood"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Colors.blue,
                  ),
                  onPressed: () async {
                    await _saveMoodToFirestore(dateKey, 'sad');
                    setState(() {
                      moodLog[formattedDay] = 'sad';
                    });
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.sentiment_neutral, color: Colors.grey),
                  onPressed: () async {
                    await _saveMoodToFirestore(dateKey, 'neutral');
                    setState(() {
                      moodLog[formattedDay] = 'neutral';
                    });
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.sentiment_very_satisfied,
                    color: Colors.yellow,
                  ),
                  onPressed: () async {
                    await _saveMoodToFirestore(dateKey, 'happy');
                    setState(() {
                      moodLog[formattedDay] = 'happy';
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _saveMoodToFirestore(String dateKey, String mood) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save mood.')),
      );
      return;
    }
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .doc(dateKey)
          .set({'mood': mood, 'timestamp': FieldValue.serverTimestamp()});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving mood: $e')));
    }
  }

  Future<void> _loadMoodsFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view moods.')),
      );
      return;
    }
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('moods')
              .get();

      setState(() {
        moodLog.clear();
        for (var doc in snapshot.docs) {
          final mood = doc.data()['mood'];
          final parts = doc.id.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          moodLog[DateTime(year, month, day)] = mood;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading moods: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        centerTitle: true,
        title: const Text(
          "MOOD TRACKER",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
              _selectMood(selected);
            },
            
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},

            
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                final color = getMoodColor(day);
                return Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text('${day.day}'),
                );
              },
              todayBuilder: (context, day, _) {
                final color = getMoodColor(day) ?? Colors.orange;
                return Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text('${day.day}'),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text("Tap any day to log your mood"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(24, 2, 12, 1),
        unselectedItemColor: const Color.fromRGBO(149, 144, 168, 1),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 2) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              builder: (context) => LogAdd(),
            );
          } else if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/map');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/mental');
          } else {
            _onItemTapped(index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Mental',
          ),
        ],
      ),
    );
  }
}
