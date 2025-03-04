(String, String) getWeightAsMetricClosesUnits(double grams) {
  final result = () {
    if (grams == 0) {
      return (grams, 'g');
    } else if (grams >= 1000) {
      return (grams / 1000, 'kg');
    } else if (grams >= 0.1) {
      return (grams, 'g');
    } else if (grams >= 0.001) {
      return (grams * 1000, 'mg');
    } else {
      return (grams * 1000000, 'µg');
    }
  }();

  return (result.$1.toStringAsFixed(2), result.$2);
}
