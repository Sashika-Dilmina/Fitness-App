import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'improve_shape_goal.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final supabase = Supabase.instance.client;

  String? _gender;
  DateTime? _dob;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Image.asset(
                'assets/images/complete_profile.png',
                height: 220,
              ),

              const SizedBox(height: 24),

              const Text(
                "Let’s complete your profile",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "It will help us to know more about you!",
                style: TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              /* ================= NAME ================= */

              TextField(
                controller: _nameController,
                decoration: _inputDecoration(Icons.person).copyWith(
                  hintText: "Your Name",
                ),
              ),

              const SizedBox(height: 16),

              /* ================= GENDER ================= */

              DropdownButtonFormField<String>(
                value: _gender,
                hint: const Text("Choose Gender"),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: (value) => setState(() => _gender = value),
                decoration: _inputDecoration(Icons.person_outline),
              ),

              const SizedBox(height: 16),

              /* ================= DOB ================= */

              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextField(
                    decoration:
                        _inputDecoration(Icons.calendar_today).copyWith(
                      hintText: _dob == null
                          ? "Date of Birth"
                          : "${_dob!.day}/${_dob!.month}/${_dob!.year}",
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /* ================= WEIGHT ================= */

              _numberField(
                controller: _weightController,
                hint: "Your Weight",
                unit: "KG",
              ),

              const SizedBox(height: 16),

              /* ================= HEIGHT ================= */

              _numberField(
                controller: _heightController,
                hint: "Your Height",
                unit: "CM",
              ),

              const SizedBox(height: 32),

              /* ================= SUBMIT ================= */

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9EC9FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Next",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= DATE PICKER ================= */

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  /* ================= INPUT DECORATION ================= */

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF7F8F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  /* ================= NUMBER FIELD ================= */

  Widget _numberField({
    required TextEditingController controller,
    required String hint,
    required String unit,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(Icons.monitor_weight).copyWith(
        hintText: hint,
        suffixText: unit,
        suffixStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  /* ================= SUBMIT LOGIC ================= */

  Future<void> _submitProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage("User not logged in");
      return;
    }

    final displayName = _nameController.text.trim();
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (displayName.isEmpty ||
        _gender == null ||
        _dob == null ||
        weight == null ||
        height == null) {
      _showMessage("Please complete all fields");
      return;
    }

    setState(() => _loading = true);

    try {
      /* 🔥 UPDATE existing profile (NO INSERT) */
      await supabase.from('profiles').update({
        'display_name': displayName,
        'gender': _gender,
        'dob': _dob!.toIso8601String(),
        'weight': weight,
        'height': height,
      }).eq('user_id', user.id);

      /* Optional: save name in auth metadata */
      await supabase.auth.updateUser(
        UserAttributes(data: {'display_name': displayName}),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ImproveShapeGoal()),
      );
    } catch (e) {
      _showMessage("Failed to save profile");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
