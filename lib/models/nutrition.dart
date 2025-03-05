import 'dart:convert';

import 'package:flutter/foundation.dart';

class Nutrition {
  final Map<String, double> basic;
  final Map<String, double> vitamins;
  final Map<String, double> minerals;

  Nutrition({
    required this.basic,
    required this.vitamins,
    required this.minerals,
  });

  factory Nutrition.fromJson(String data) {
    final json = jsonDecode(data);
    final Map<String, double> basic = {};
    final Map<String, double> vitamins = {};
    final Map<String, double> minerals = {};
    json.entries.forEach((e) {
      if (e.value is num) {
        basic[e.key] = (e.value / 1.0) as double;
      }
    });
    json['vitamins'].entries.forEach((e) {
      if (e.value is num) {
        vitamins[e.key] = (e.value / 1.0) as double;
      }
    });
    json['minerals'].entries.forEach((e) {
      if (e.value is num) {
        minerals[e.key] = (e.value / 1.0) as double;
      }
    });

    return Nutrition(basic: basic, vitamins: vitamins, minerals: minerals);
  }

  String toJson() {
    final json = {'basic': basic, 'vitamins': vitamins, 'minerals': minerals};
    return jsonEncode(json);
  }

  Nutrition operator +(Nutrition other) {
    final newBasic = Map<String, double>.from(basic);
    final newVitamins = Map<String, double>.from(vitamins);
    final newMinerals = Map<String, double>.from(minerals);

    other.basic.forEach((key, value) {
      newBasic.update(key, (v) => v + value, ifAbsent: () => value);
    });

    other.vitamins.forEach((key, value) {
      newVitamins.update(key, (v) => v + value, ifAbsent: () => value);
    });

    other.minerals.forEach((key, value) {
      newMinerals.update(key, (v) => v + value, ifAbsent: () => value);
    });

    return Nutrition(
      basic: newBasic,
      vitamins: newVitamins,
      minerals: newMinerals,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Nutrition &&
        mapEquals(other.basic, basic) &&
        mapEquals(other.vitamins, vitamins) &&
        mapEquals(other.minerals, minerals);
  }

  @override
  int get hashCode => basic.hashCode ^ vitamins.hashCode ^ minerals.hashCode;
}
