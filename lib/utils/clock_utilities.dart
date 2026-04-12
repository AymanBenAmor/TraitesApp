import 'dart:async';

/// Clock helper class to manage current time updates
class ClockHelper {
  Timer? _timer;
  final void Function(String) onTick; // callback to update UI

  ClockHelper({required this.onTick});

  /// Start the clock
  void startClock() {
    updateTime(); // immediate update
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateTime();
    });
  }

  /// Stop the clock
  void stopClock() {
    _timer?.cancel();
  }

  /// Get current time and call the callback
  void updateTime() {
    final now = DateTime.now();
    final formattedTime =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ";
    onTick(formattedTime);
  }
}