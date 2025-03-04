enum Gender { male, female }

enum Goal {
  weightGain,
  maintainWeight,
  weightLoss,
  bulk,
  leanBulk,
  buildEndurance,
}

enum Exercise { none, light, moderate, active }

class User {
  Gender gender;
  int age;
  int weight; // weight in grams
  int height; // height in cm
  Goal goal;
  Exercise exercise;

  User({
    this.gender = Gender.male,
    this.age = 25,
    this.weight = 67000,
    this.height = 174,
    this.goal = Goal.maintainWeight,
    this.exercise = Exercise.light,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      gender: Gender.values.byName(json['gender']),
      age: json['age'],
      weight: json['weight'],
      height: json['height'],
      goal: Goal.values.byName(json['goal']),
      exercise: Exercise.values.byName(json['exercise']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender.name,
      'age': age,
      'weight': weight,
      'height': height,
      'goal': goal.name,
      'exercise': exercise.name,
    };
  }

  // Getters for height
  String get heightInMeters => "${(height / 1000.0).toStringAsFixed(2)}m";
  String get heightInFeetInches {
    int totalInches = (height / 2.54).round();
    int feet = totalInches ~/ 12;
    int inches = totalInches % 12;
    return "$feet'$inches\"";
  }

  // Getters for weight
  String get weightInKilograms => "${(weight / 1000.0).toStringAsFixed(2)}kg";
  String get weightInPounds => "${(weight / 453.59237).toStringAsFixed(2)}lbs";
}
