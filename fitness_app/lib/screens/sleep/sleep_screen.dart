import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  List<Map<String, dynamic>> sleeps = [];

  @override
  void initState() {
    super.initState();
    fetchSleep();
  }

  Future<void> fetchSleep() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('sleep_logs')
        .select()
        .eq('user_id', user.id)
        .order('sleep_date', ascending: false);

    setState(() {
      sleeps = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  Future<void> addSleep(double hours) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('sleep_logs').insert({
      'user_id': user.id,
      'sleep_hours': hours,
      'sleep_date': DateTime.now().toIso8601String().substring(0, 10),
    });

    fetchSleep();
  }

  void showAddSheet() {
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Sleep",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Hours slept",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final h = double.tryParse(ctrl.text);
                if (h == null) return;
                addSleep(h);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: sleeps.isEmpty
          ? const Center(child: Text("No sleep data yet 😴"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sleeps.length,
              itemBuilder: (_, i) {
                final s = sleeps[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.bedtime),
                    title: Text("${s['sleep_hours']} hours"),
                    subtitle: Text(s['sleep_date']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
