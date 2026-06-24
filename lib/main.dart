import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MoodlyApp());
}

const _primary = Color(0xFF8B7CF6);
const _dark = Color(0xFF241B3D);
const _bg = Color(0xFFF8F5FF);
const _storageKey = 'moodly_entries';
const _darkModeKey = 'moodly_dark_mode';

const _privacyPolicyText = '''
Last updated: June 24, 2026

Moodly is a simple, local-only mood tracking app.

What Moodly stores
Moodly stores the mood entries you create, including the selected mood, emoji, optional note, entry date, and app settings such as dark mode.

Where your data stays
Your data is saved only on your device using local app storage. Moodly does not require an account, does not use a backend server, does not use Firebase, does not show ads, does not use analytics, does not send notifications, and does not send your mood entries or notes to anyone.

Deleting your data
You can delete individual mood entries in the app. You can also remove all stored Moodly data by clearing the app data in your device settings or uninstalling the app.

Third parties
Moodly does not sell, rent, share, or transfer your personal data to third parties.

Children's privacy
Moodly is intended for personal journaling and mood tracking. If you are a parent or guardian and want data removed, delete the entries, clear the app data, or uninstall the app from the device.

Contact
If you have questions about this policy, contact the app developer through the store listing or project page where you downloaded Moodly.
''';

const _termsText = '''
Last updated: June 24, 2026

By using Moodly, you agree to these terms.

Local personal tool
Moodly is provided as a simple personal mood tracking tool. The app keeps entries local to your device and does not provide accounts, cloud sync, backup, analytics, ads, notifications, or backend services.

Not medical advice
Moodly is not medical advice, mental health treatment, diagnosis, crisis support, or therapy. If you need medical or mental health support, contact a qualified professional. If you are in immediate danger or crisis, contact local emergency services.

Your responsibility
You are responsible for how you use the app and for the information you choose to enter. Keep your device secure if your entries are private or sensitive.

Data loss
Because Moodly is local-only, entries may be lost if you delete entries, clear app data, uninstall the app, reset your device, or lose access to your device.

Availability and changes
Moodly is provided as-is. The app may be changed, improved, or discontinued without notice.

Limitation of liability
To the fullest extent allowed by law, the developer is not responsible for losses or damages arising from your use of Moodly.
''';

class MoodlyApp extends StatefulWidget {
  const MoodlyApp({super.key});

  @override
  State<MoodlyApp> createState() => _MoodlyAppState();
}

class _MoodlyAppState extends State<MoodlyApp> {
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => darkMode = prefs.getBool(_darkModeKey) ?? false);
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    setState(() => darkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moodly',
      debugShowCheckedModeBanner: false,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _primary,
        scaffoldBackgroundColor: _bg,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: _primary,
      ),
      home: SplashScreen(onDarkModeChanged: setDarkMode, darkMode: darkMode),
    );
  }
}

class MoodEntry {
  final String mood;
  final String emoji;
  final String note;
  final DateTime date;

  MoodEntry({
    required this.mood,
    required this.emoji,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'mood': mood,
    'emoji': emoji,
    'note': note,
    'date': date.toIso8601String(),
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      mood: json['mood'] ?? 'Okay',
      emoji: json['emoji'] ?? '😐',
      note: json['note'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}

class MoodOption {
  final String mood;
  final String emoji;
  final Color color;

  const MoodOption(this.mood, this.emoji, this.color);
}

const moodOptions = [
  MoodOption('Great', '😄', Color(0xFF22C55E)),
  MoodOption('Good', '🙂', Color(0xFF84CC16)),
  MoodOption('Okay', '😐', Color(0xFFF59E0B)),
  MoodOption('Bad', '😔', Color(0xFFF97316)),
  MoodOption('Terrible', '😢', Color(0xFFEF4444)),
];

class _MoodlyLogo extends StatelessWidget {
  final double size;
  final bool framed;

  const _MoodlyLogo({
    required this.size,
    this.framed = false,
  });

  @override
  Widget build(BuildContext context) {
    final logo = ClipRRect(
      borderRadius: BorderRadius.circular(size * .22),
      child: Image.asset(
        'assets/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _LogoFallback(size: size),
      ),
    );

    if (!framed) {
      return SizedBox.square(dimension: size, child: logo);
    }

    return Container(
      padding: EdgeInsets.all(size * .16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * .28),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(.18),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: logo,
    );
  }
}

class _LogoFallback extends StatelessWidget {
  final double size;

  const _LogoFallback({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _primary.withOpacity(.14),
        borderRadius: BorderRadius.circular(size * .22),
      ),
      child: Icon(
        Icons.mood_rounded,
        color: _primary,
        size: size * .56,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const SplashScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 620;
            final padding = compact ? 20.0 : 28.0;
            final minHeight = constraints.maxHeight > padding * 2
                ? constraints.maxHeight - (padding * 2)
                : 0.0;

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: compact ? 4 : 20),
                    Column(
                      children: [
                        _MoodlyLogo(
                          size: compact ? 108 : 145,
                          framed: true,
                        ),
                        SizedBox(height: compact ? 22 : 30),
                        const Text(
                          'Moodly',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: _dark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Track your mood, one day at a time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B5A7A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: compact ? 24 : 36),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomeScreen(
                                  darkMode: darkMode,
                                  onDarkModeChanged: onDarkModeChanged,
                                ),
                              ),
                            );
                          },
                          child: const Text('Start Tracking'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const HomeScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MoodEntry> entries = [];

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return;

    final decoded = jsonDecode(data) as List;
    setState(() {
      entries = decoded.map((e) => MoodEntry.fromJson(e)).toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  bool get hasTodayEntry {
    final now = DateTime.now();
    return entries.any(
          (e) =>
      e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day,
    );
  }

  int get currentStreak {
    if (entries.isEmpty) return 0;

    final days = entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime check = DateTime.now();
    check = DateTime(check.year, check.month, check.day);

    for (final day in days) {
      if (day == check) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else if (day == check.subtract(const Duration(days: 1))) {
        check = check.subtract(const Duration(days: 1));
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<void> openAddMood() async {
    final result = await Navigator.push<MoodEntry>(
      context,
      MaterialPageRoute(builder: (_) => const AddMoodScreen()),
    );

    if (result != null) {
      setState(() {
        entries.removeWhere(
              (e) =>
          e.date.year == result.date.year &&
              e.date.month == result.date.month &&
              e.date.day == result.date.day,
        );
        entries.insert(0, result);
        entries.sort((a, b) => b.date.compareTo(a.date));
      });
      saveEntries();
    }
  }

  Future<bool> confirmDelete(MoodEntry mood) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete this mood?'),
          content: Text(
            'This will remove your ${mood.mood.toLowerCase()} entry from '
            '${_formatDate(mood.date)}. You can undo right after deleting.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> deleteEntry(int index) async {
    final removed = entries[index];
    setState(() => entries.removeAt(index));
    await saveEntries();

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: const Text('Mood entry deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              entries.insert(index.clamp(0, entries.length).toInt(), removed);
              entries.sort((a, b) => b.date.compareTo(a.date));
            });
            saveEntries();
          },
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final latest = entries.isEmpty ? null : entries.first;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddMood,
        icon: const Icon(Icons.add_rounded),
        label: Text(hasTodayEntry ? 'Update Today' : 'Add Mood'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const _MoodlyLogo(size: 48),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Moodly',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(
                          darkMode: widget.darkMode,
                          onDarkModeChanged: widget.onDarkModeChanged,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _dark,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today’s Mood',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    latest == null ? 'How are you feeling?' : latest.emoji,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: latest == null ? 30 : 64,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (latest != null)
                    Text(
                      latest.mood,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _StatBox(title: 'Entries', value: entries.length.toString()),
                      const SizedBox(width: 12),
                      _StatBox(title: 'Streak', value: '$currentStreak days'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Mood History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const _MoodlyLogo(size: 72),
                    const SizedBox(height: 14),
                    const Text(
                      'No moods yet',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add your first entry to start seeing your mood history here.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: openAddMood,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add first mood'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Private and stored only on this device.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...entries.asMap().entries.map((entry) {
                final index = entry.key;
                final mood = entry.value;

                return Dismissible(
                  key: ValueKey(
                    '${mood.date.toIso8601String()}-${mood.mood}-${mood.note}',
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => confirmDelete(mood),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 22),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) => deleteEntry(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mood.mood,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(_formatDate(mood.date)),
                              if (mood.note.isNotEmpty)
                                Text(
                                  mood.note,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;

  const _StatBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddMoodScreen extends StatefulWidget {
  const AddMoodScreen({super.key});

  @override
  State<AddMoodScreen> createState() => _AddMoodScreenState();
}

class _AddMoodScreenState extends State<AddMoodScreen> {
  MoodOption selected = moodOptions[1];
  final noteController = TextEditingController();

  void save() {
    Navigator.pop(
      context,
      MoodEntry(
        mood: selected.mood,
        emoji: selected.emoji,
        note: noteController.text.trim(),
        date: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Mood'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'How do you feel today?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: moodOptions.map((option) {
              final isSelected = option.mood == selected.mood;

              return GestureDetector(
                onTap: () => setState(() => selected = option),
                child: Container(
                  width: 102,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? option.color.withOpacity(.18)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? option.color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(option.emoji, style: const TextStyle(fontSize: 34)),
                      const SizedBox(height: 8),
                      Text(
                        option.mood,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Note optional',
              hintText: 'Write a small note about your day...',
              filled: true,
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: save,
              child: const Text('Save Mood'),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                const _MoodlyLogo(size: 64),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Moodly\nTrack your mood daily.',
                    style: TextStyle(
                      color: _dark,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SwitchListTile(
            value: darkMode,
            onChanged: onDarkModeChanged,
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_rounded),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_rounded),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.article_rounded),
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsScreen()),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextPage(
      title: 'Privacy Policy',
      text: _privacyPolicyText,
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextPage(
      title: 'Terms & Conditions',
      text: _termsText,
    );
  }
}

class TextPage extends StatelessWidget {
  final String title;
  final String text;

  const TextPage({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}