import '../../service/tips_service.dart';

class AppTipsService extends TipsService {
  @override
  Future<void> testFn() async {
    await Future.delayed(Duration(seconds: 1));

    return;
  }
}
