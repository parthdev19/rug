/// Debouncer utility for rate-limiting callbacks.
library;

import 'dart:async';

class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 300)});
  final Duration duration;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() => _timer?.cancel();
  void dispose() { _timer?.cancel(); _timer = null; }
}
