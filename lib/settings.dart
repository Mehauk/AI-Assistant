import 'package:ai_nutritionist/models/user.dart';
import 'package:ai_nutritionist/obervers/observers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user =
          prefs.getString('user') != null
              ? User.fromJson(prefs.getString('user')!)
              : User();
    });
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', user!.toJson());
    userObserver.notify(user!);
  }

  @override
  Widget build(BuildContext context) {
    return user == null
        ? SizedBox.shrink()
        : Scaffold(
          appBar: AppBar(title: const Text('Settings Page')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Gender'),
                Wrap(
                  children:
                      Gender.values.map((gender) {
                        return OptionChip<Gender>(
                          gender,
                          active: gender == user!.gender,
                          onChanged: (Gender? value) {
                            setState(() {
                              user!.gender = value!;
                            });
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),

                const Text('Age'),
                Slider(
                  value: user!.age.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 90,
                  label: user!.age.toString(),
                  onChanged: (double value) {
                    setState(() {
                      user!.age = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 24),

                const Text('Weight (grams)'),
                Slider(
                  value: user!.weight.toDouble(),
                  min: 30000,
                  max: 200000,
                  divisions: 170,
                  label: user!.weight.toString(),
                  onChanged: (double value) {
                    setState(() {
                      user!.weight = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 24),

                const Text('Height (cm)'),
                Slider(
                  value: user!.height.toDouble(),
                  min: 100,
                  max: 250,
                  divisions: 150,
                  label: user!.height.toString(),
                  onChanged: (double value) {
                    setState(() {
                      user!.height = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 24),

                const Text('Goal'),
                Wrap(
                  children:
                      Goal.values.map((goal) {
                        return OptionChip<Goal>(
                          goal,
                          active: goal == user!.goal,
                          onChanged: (Goal? value) {
                            setState(() {
                              user!.goal = value!;
                            });
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),

                const Text('Exercise'),
                Wrap(
                  children:
                      Exercise.values.map((exercise) {
                        return OptionChip<Exercise>(
                          exercise,
                          active: exercise == user!.exercise,
                          onChanged: (Exercise? value) {
                            setState(() {
                              user!.exercise = value!;
                            });
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    _saveUser();
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}

class OptionChip<T extends Enum> extends StatelessWidget {
  final T value;
  final bool active;
  final void Function(T) onChanged;
  const OptionChip(
    this.value, {
    super.key,
    required this.onChanged,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () => onChanged(value),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            color:
                active
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              value.name,
              style: TextStyle(
                color: active ? Theme.of(context).colorScheme.onPrimary : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
