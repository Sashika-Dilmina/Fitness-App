import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'improve_shape_goal.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  String? _gender;
  DateTime? _dob;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void dispose() {
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

              // Gender
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

              // DOB
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextField(
                    decoration: _inputDecoration(Icons.calendar_today).copyWith(
                      hintText: _dob == null
                          ? "Date of Birth"
                          : "${_dob!.day}/${_dob!.month}/${_dob!.year}",
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _numberField(
                controller: _weightController,
                hint: "Your Weight",
                unit: "KG",
              ),

              const SizedBox(height: 16),

              _numberField(
                controller: _heightController,
                hint: "Your Height",
                unit: "CM",
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9EC9FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Next", style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Date Picker
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

  // Number Field
  Widget _numberField({
    required TextEditingController controller,
    required String hint,
    required String unit,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  // Input Decoration
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

  // Submit Profile
  Future<void> _submitProfile() async {
    if (_gender == null || _dob == null) {
      _showMessage("Please complete all fields");
      return;
    }

    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || height == null) {
      _showMessage("Enter valid height and weight");
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showMessage("User not logged in");
      return;
    }

    try {
      await Supabase.instance.client.from('profiles').insert({
        'user_id': user.id,
        'gender': _gender,
        'dob': _dob!.toIso8601String(),
        'weight': weight,
        'height': height,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ImproveShapeGoal()),
      );
    } catch (e) {
      _showMessage("Failed to save profile");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
