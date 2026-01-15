import 'dart:async';

class SessionTimerService {
  int _seconds = 0;

  Stream<int> get timerStream =>
      Stream.periodic(const Duration(seconds: 1), (_) => ++_seconds);
}
