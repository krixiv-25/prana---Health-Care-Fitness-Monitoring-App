import 'package:flutter/material.dart';
import 'package:kenko/logadd.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:kenko/mentalcalendar.dart';

class Quote {
  final String content;

  Quote({required this.content});
}

class MentalPage extends StatefulWidget {
  const MentalPage({super.key});

  @override
  State<MentalPage> createState() => _MentalPageState();
}

class _MentalPageState extends State<MentalPage> {
  final int _selectedIndex = 4; 

  final List<Quote> _quotes = [
    Quote(
      content:
          "You won't always be motivated. That's why you need to be disciplined.",
    ),
    Quote(content: "It's not about having time. It's about making time."),
    Quote(content: "Results happen over time, not overnight. Stay consistent."),
    Quote(
      content:
          "One workout won't change your body. But one workout closer gets you there.",
    ),
    Quote(
      content:
          "If it's important to you, you'll find a way. If not, you'll find an excuse.",
    ),
    Quote(content: "Strong isn't just physical—it's mental, too."),
    Quote(content: "Push your limits. That's where growth lives."),
    Quote(content: "You don't find willpower, you create it."),
    Quote(content: "Every drop of sweat is a step toward your strongest self."),
    Quote(content: "Pain is temporary. Strength is forever."),
    Quote(content: "Small steps every day lead to big changes."),
    Quote(content: "Progress is progress, no matter how slow."),
    Quote(content: "Don't compare your Day 1 to someone else's Day 100."),
    Quote(content: "The only bad workout is the one you didn't do."),
    Quote(content: "Be stronger than your excuses."),
    Quote(
      content:
          "Fitness is 100% mental—your body won't go where your mind doesn't push it.",
    ),
    Quote(content: "Your mind gives up before your body does. Keep going."),
    Quote(content: "Doubt kills more dreams than failure ever will."),
    Quote(content: "Champions train, losers complain."),
    Quote(content: "Discomfort is where transformation begins."),
    Quote(content: "Train like your future depends on it—because it does."),
    Quote(content: "You started for a reason. Don't stop now."),
    Quote(content: "Your goal is on the other side of effort."),
    Quote(content: "Visualize the win. Then go earn it."),
    Quote(content: "Every rep is a vote for the person you want to become."),
    Quote(
      content: "Don't wait for inspiration. Be the reason someone else starts.",
    ),
    Quote(content: "You don't have to be extreme. Just consistent."),
    Quote(content: "Train hard. Rest hard. Repeat."),
    Quote(content: "Grind in silence. Let your results make the noise."),
    Quote(
      content:
          "Your body can stand almost anything. It's your mind you have to convince.",
    ),
    Quote(
      content: "Success isn't always about greatness. It's about consistency.",
    ),
    Quote(content: "The only bad workout is the one that didn't happen"),
    Quote(content: "Train insane or remain the same."),
    Quote(content: "Don't limit your challenges. Challenge your limits."),
    Quote(
      content: "Push yourself because no one else is going to do it for you.",
    ),
    Quote(
      content:
          "Your body can stand almost anything. It's your mind you have to convince.",
    ),
    Quote(content: "Hard work beats talent when talent doesn't work hard."),
    Quote(content: "Your only competition is who you were yesterday."),
    Quote(content: "Sweat is just fat crying."),
    Quote(
      content:
          "Fitness isn't about being better than someone else. It's about being better than you used to be.",
    ),
  ];

  late Quote _currentQuote;
  int _likeCount = 0;
  final int _maxLikes = 10;
  final Random _random = Random();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _displayRandomQuote();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 2:
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          builder: (context) => LogAdd(),
        );
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 4:
        
        break;
    }
  }

  void _displayRandomQuote() {
    setState(() {
      _currentQuote = _quotes[_random.nextInt(_quotes.length)];
    });
  }

  void _handleLike() {
    setState(() {
      _likeCount++;
    });

    if (_likeCount >= _maxLikes) {
      _confettiController.play();

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _likeCount = 0;
        });
      });
    }

    _displayRandomQuote();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _likeCount / _maxLikes;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        centerTitle: true,
        title: const Text(
          "MENTAL WELLBEING",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/profile',
              ); 
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      color: Color.fromRGBO(24, 2, 12, 1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$_likeCount/$_maxLikes",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color.fromRGBO(
                            187,
                            203,
                            203,
                            1,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color.fromRGBO(99, 75, 102, 1),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _currentQuote.content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _handleLike,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(149, 144, 168, 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LogMoodPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(24, 2, 12, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'LOG DAILY MOOD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 10,
            maxBlastForce: 15,
            minBlastForce: 10,
            gravity: 0.3,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(24, 2, 12, 1),
        unselectedItemColor: const Color.fromRGBO(149, 144, 168, 1),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
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
