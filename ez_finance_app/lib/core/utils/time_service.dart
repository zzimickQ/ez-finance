abstract class TimeService {
  DateTime getCurrentTime();
}

class SystemTimeService implements TimeService {
  @override
  DateTime getCurrentTime() {
    return DateTime.now();
  }
}
