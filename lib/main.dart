
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const blue = Color(0xFF2563EB);
const darkBlue = Color(0xFF1E3A8A);
const lightBlue = Color(0xFFDBEAFE);
const background = Color(0xFFF3F7FF);

final db = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ocejnabppxoosdylvvte.supabase.co',
    publishableKey: 'sb_publishable_ZVQykTXhhDvMhczBKehSiQ_0n5r2A-4',
  );

  runApp(const SchoolApp());
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Event Check-In',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: lightBlue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: lightBlue),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
      home: db.auth.currentSession == null
          ? const LoginPage()
          : const DashboardPage(),
    );
  }
}

void message(BuildContext context, String text) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Widget primaryButton(
  String text,
  VoidCallback? action, {
  IconData icon = Icons.arrow_forward,
}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton.icon(
      onPressed: action,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.blue.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget panel(Widget child) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: darkBlue.withValues(alpha: 0.045),
          blurRadius: 18,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
}

Widget heading(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: darkBlue,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        subtitle,
        style: const TextStyle(color: Colors.black54),
      ),
      const SizedBox(height: 22),
    ],
  );
}

Widget emptyState(String text) {
  return Padding(
    padding: const EdgeInsets.all(25),
    child: Center(
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    ),
  );
}

String dateOnly(dynamic value) {
  final text = value?.toString() ?? '';
  return text.length >= 10 ? text.substring(0, 10) : text;
}

String readableTime(dynamic value) {
  if (value == null) return 'Not yet checked in';

  final date = DateTime.tryParse(value.toString());
  if (date == null) return value.toString();

  final local = date.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';

  return '${local.month}/${local.day}/${local.year} '
      '$hour:$minute $period';
}

// LOGIN PAGE

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  bool hidden = true;

  Future<void> login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      message(context, 'Please enter your email and password.');
      return;
    }

    setState(() => loading = true);

    try {
      await db.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        ),
        (_) => false,
      );
    } catch (e) {
      if (mounted) message(context, 'Login failed: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [blue, darkBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: blue.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.how_to_reg_rounded,
                    color: Colors.white,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'School Event Check-In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Simple, organized, and efficient attendance',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 30),
                panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Sign in to your organizer account',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: password,
                        obscureText: hidden,
                        onSubmitted: (_) {
                          if (!loading) login();
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => hidden = !hidden);
                            },
                            icon: Icon(
                              hidden
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      primaryButton(
                        loading ? 'Signing in...' : 'Login',
                        loading ? null : login,
                        icon: Icons.login,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'School Event Management System',
                  style: TextStyle(color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SHARED PAGE LAYOUT

class AppPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AppPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading(title, subtitle),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// DASHBOARD PAGE

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> events = [];
  int attendees = 0;
  int checkedIn = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (mounted) setState(() => loading = true);

    try {
      final eventData = await db
          .from('events')
          .select()
          .order('created_at', ascending: false);

      final attendeeData = await db
          .from('attendees')
          .select('checked_in');

      if (!mounted) return;

      setState(() {
        events = List<Map<String, dynamic>>.from(eventData);
        attendees = attendeeData.length;
        checkedIn =
            attendeeData.where((a) => a['checked_in'] == true).length;
      });
    } catch (e) {
      if (mounted) message(context, 'Unable to load dashboard: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> logout() async {
    try {
      await db.auth.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) message(context, 'Logout failed: $e');
    }
  }

  Widget stat(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: darkBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget actionCard(
    String title,
    IconData icon,
    Widget page,
  ) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );

        if (mounted) load();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDBEAFE)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: darkBlue, size: 25),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: blue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Event Check-In'),
        actions: [
          IconButton(
            onPressed: load,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [blue, darkBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.event_available,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: 13),
                  Text(
                    'Welcome, Organizer!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Manage school events and track attendance.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 650 ? 3 : 1;
                final itemWidth =
                    (width - (columns - 1) * 12) / columns;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: stat(
                        'Total Events',
                        '${events.length}',
                        Icons.event,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: stat(
                        'Total Attendees',
                        '$attendees',
                        Icons.people,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: stat(
                        'Checked In',
                        '$checkedIn',
                        Icons.check_circle,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 25),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            actionCard(
              'Create New Event',
              Icons.add_circle_outline,
              const CreateEventPage(),
            ),
            const SizedBox(height: 10),
            actionCard(
              'Guest Check-In',
              Icons.how_to_reg,
              const GuestCheckInPage(),
            ),
            const SizedBox(height: 10),
            actionCard(
              'Attendance Records',
              Icons.assignment_outlined,
              const AttendanceRecordsPage(),
            ),
            const SizedBox(height: 25),
            const Text(
              'School Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            if (loading)
              const Center(
                child: CircularProgressIndicator(color: blue),
              )
            else if (events.isEmpty)
              panel(emptyState('No events created yet.'))
            else
              ...events.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: panel(
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month,
                            color: darkBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${event['event_name'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: darkBlue,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Location: ${event['location'] ?? ''}',
                              ),
                              Text(
                                'Date: ${dateOnly(event['event_date'])}',
                              ),
                              if ('${event['description'] ?? ''}'
                                  .isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5),
                                  child: Text(
                                    '${event['description']}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// CREATE EVENT PAGE

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final name = TextEditingController();
  final location = TextEditingController();
  final description = TextEditingController();

  DateTime? date;
  bool saving = false;

  Future<void> save() async {
    if (name.text.trim().isEmpty ||
        location.text.trim().isEmpty ||
        date == null) {
      message(context, 'Please complete all required fields.');
      return;
    }

    setState(() => saving = true);

    try {
      await db.from('events').insert({
        'event_name': name.text.trim(),
        'location': location.text.trim(),
        'description': description.text.trim(),
        'event_date':
            '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
      });

      if (!mounted) return;

      message(context, 'Event created successfully!');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) message(context, 'Unable to create event: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    location.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Create Event',
      subtitle: 'Add a new school event.',
      child: panel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Event Name *',
                prefixIcon: Icon(Icons.event),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: location,
              decoration: const InputDecoration(
                labelText: 'Location *',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: date ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (selected != null && mounted) {
                    setState(() => date = selected);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  date == null
                      ? 'Select Event Date *'
                      : dateOnly(date!.toIso8601String()),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: description,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            primaryButton(
              saving ? 'Saving...' : 'Create Event',
              saving ? null : save,
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }
}

// GUEST CHECK-IN PAGE

class GuestCheckInPage extends StatefulWidget {
  const GuestCheckInPage({super.key});

  @override
  State<GuestCheckInPage> createState() => _GuestCheckInPageState();
}

class _GuestCheckInPageState extends State<GuestCheckInPage> {
  final name = TextEditingController();
  final studentId = TextEditingController();

  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> recent = [];

  String? eventId;
  bool saving = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final result = await db
          .from('events')
          .select()
          .order('event_date', ascending: false);

      if (!mounted) return;

      setState(() {
        events = List<Map<String, dynamic>>.from(result);
        eventId = events.isNotEmpty
            ? events.first['id'].toString()
            : null;
        loading = false;
      });

      await loadRecent();
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      message(context, 'Unable to load events: $e');
    }
  }

  Future<void> loadRecent() async {
    if (eventId == null) {
      if (mounted) setState(() => recent = []);
      return;
    }

    try {
      final selectedEvent = eventId!;

      final result = await db
          .from('attendees')
          .select()
          .eq('event_id', selectedEvent)
          .order('checked_in_at', ascending: false)
          .limit(5);

      if (!mounted) return;

      setState(() {
        recent = List<Map<String, dynamic>>.from(result);
      });
    } catch (e) {
      if (mounted) {
        message(context, 'Unable to load recent check-ins: $e');
      }
    }
  }

  Future<void> checkIn() async {
    if (eventId == null ||
        name.text.trim().isEmpty ||
        studentId.text.trim().isEmpty) {
      message(context, 'Select an event and complete all fields.');
      return;
    }

    setState(() => saving = true);

    try {
      final selectedEvent = eventId!;
      final id = studentId.text.trim();

      final existing = await db
          .from('attendees')
          .select('id')
          .eq('event_id', selectedEvent)
          .eq('student_id', id)
          .limit(1);

      if (!mounted) return;

      if (existing.isNotEmpty) {
        message(
          context,
          'This student is already registered for this event.',
        );
        return;
      }

      await db.from('attendees').insert({
        'event_id': selectedEvent,
        'full_name': name.text.trim(),
        'student_id': id,
        'checked_in': true,
        'checked_in_at': DateTime.now().toUtc().toIso8601String(),
      });

      if (!mounted) return;

      name.clear();
      studentId.clear();

      message(context, 'Guest checked in successfully!');
      await loadRecent();
    } catch (e) {
      if (mounted) message(context, 'Check-in failed: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    studentId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Guest Check-In',
      subtitle: 'Register attendance for a school event.',
      child: Column(
        children: [
          panel(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendee Information',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 20),
                if (loading)
                  const CircularProgressIndicator(color: blue)
                else if (events.isEmpty)
                  emptyState('Create an event first.')
                else
                  DropdownButtonFormField<String>(
                    initialValue: eventId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Event',
                      prefixIcon: Icon(Icons.event),
                    ),
                    items: events.map((event) {
                      return DropdownMenuItem<String>(
                        value: event['id'].toString(),
                        child: Text(
                          '${event['event_name']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => eventId = value);
                      loadRecent();
                    },
                  ),
                const SizedBox(height: 15),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: studentId,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                primaryButton(
                  saving ? 'Checking in...' : 'Check In Guest',
                  saving ? null : checkIn,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          panel(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Check-Ins',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  emptyState('No recent check-ins.')
                else
                  ...recent.map(
                    (person) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: lightBlue,
                        child: Icon(Icons.check, color: darkBlue),
                      ),
                      title: Text('${person['full_name']}'),
                      subtitle: Text(
                        'ID: ${person['student_id'] ?? ''}',
                      ),
                      trailing: const Icon(
                        Icons.check_circle,
                        color: blue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ATTENDANCE RECORDS PAGE

class AttendanceRecordsPage extends StatefulWidget {
  const AttendanceRecordsPage({super.key});

  @override
  State<AttendanceRecordsPage> createState() =>
      _AttendanceRecordsPageState();
}

class _AttendanceRecordsPageState
    extends State<AttendanceRecordsPage> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> records = [];

  String? eventId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final result = await db
          .from('events')
          .select()
          .order('event_date', ascending: false);

      if (!mounted) return;

      setState(() {
        events = List<Map<String, dynamic>>.from(result);
        eventId = events.isEmpty
            ? null
            : events.first['id'].toString();
      });

      await loadRecords();
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      message(context, 'Unable to load events: $e');
    }
  }

  Future<void> loadRecords() async {
    if (mounted) setState(() => loading = true);

    try {
      if (eventId == null) {
        if (mounted) setState(() => records = []);
      } else {
        final selectedEvent = eventId!;

        final result = await db
            .from('attendees')
            .select()
            .eq('event_id', selectedEvent)
            .order('full_name');

        if (!mounted) return;

        setState(() {
          records = List<Map<String, dynamic>>.from(result);
        });
      }
    } catch (e) {
      if (mounted) {
        message(context, 'Unable to load attendance: $e');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = records.length;
    final present =
        records.where((r) => r['checked_in'] == true).length;

    return AppPage(
      title: 'Attendance Records',
      subtitle: 'View and monitor event attendance.',
      child: Column(
        children: [
          panel(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select School Event',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 14),
                if (events.isEmpty)
                  emptyState('No events available.')
                else
                  DropdownButtonFormField<String>(
                    initialValue: eventId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.event),
                    ),
                    items: events.map((event) {
                      return DropdownMenuItem<String>(
                        value: event['id'].toString(),
                        child: Text(
                          '${event['event_name']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => eventId = value);
                      loadRecords();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          panel(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    const Text('Total Attendees'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$present',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: blue,
                      ),
                    ),
                    const Text('Checked In'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          panel(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance List',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 12),
                if (loading)
                  const Center(
                    child: CircularProgressIndicator(color: blue),
                  )
                else if (records.isEmpty)
                  emptyState('No attendance records yet.')
                else
                  ...records.map((person) {
                    final present = person['checked_in'] == true;

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: present
                                ? lightBlue
                                : const Color(0xFFFFF1E7),
                            child: Icon(
                              present
                                  ? Icons.check_circle
                                  : Icons.schedule,
                              color: present
                                  ? blue
                                  : Colors.orange,
                            ),
                          ),
                          title: Text(
                            '${person['full_name'] ?? ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'ID: ${person['student_id'] ?? ''}\n'
                            '${readableTime(person['checked_in_at'])}',
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            present ? 'Present' : 'Pending',
                            style: TextStyle(
                              color: present
                                  ? blue
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(height: 10),
                      ],
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 18),
          primaryButton(
            'Refresh Records',
            loadRecords,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }
}
