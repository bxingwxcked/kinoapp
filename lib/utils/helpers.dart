import 'dart:math';

List<String> generateRandomTimes(int seed) {
  final random = Random(seed);
  final hours = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22];
  final minutes = [0, 10, 15, 20, 30, 40, 45, 50];
  
  List<String> times = [];
  for (int i = 0; i < 4; i++) {
    final h = hours[random.nextInt(hours.length)];
    final m = minutes[random.nextInt(minutes.length)];
    times.add('$h:${m.toString().padLeft(2, '0')}');
  }
  times.sort();
  return times;
}
