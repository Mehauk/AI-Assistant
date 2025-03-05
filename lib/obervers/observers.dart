import 'package:ai_nutritionist/models/user.dart';

class Oberserver<T> {
  final List<void Function(T)> callbacks = [];

  void addCallback(void Function(T) callback) => callbacks.add(callback);
  void removeCallback(void Function(T) callback) => callbacks.remove(callback);

  void notify(T next) {
    for (var cb in callbacks) {
      cb(next);
    }
  }
}

final userObserver = Oberserver<User>();
