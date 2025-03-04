String getWeightAsMetricClosesUnits(double grams) {
  if (grams == 0) {
    return '${grams.toStringAsFixed(2)} g';
  } else if (grams >= 1000) {
    return '${(grams / 1000).toStringAsFixed(2)} kg';
  } else if (grams >= 0.1) {
    return '${grams.toStringAsFixed(2)} g';
  } else if (grams >= 0.001) {
    return '${(grams * 1000).toStringAsFixed(2)} mg';
  } else {
    return '${(grams * 1000000).toStringAsFixed(2)} µg';
  }
}
