import '../../../entities/language_enum.dart';
import '../../../entities/meditation_info.dart';
import '../../common/transport_error.dart';
import '../../../service/common/json_response.dart';

class MeditationInfoListResponse extends JsonResponse<List<MeditationInfo>> {
  MeditationInfo deserilizeItem(Map<String, dynamic> json) {
    final lang = LanguageEnum.fromString(json['language'] as String);

    if (lang == null) {
      throw BadDataFormatError('MeditationInfo {language} field wrong data');
    }

    return MeditationInfo(
      timestamp: json['timestamp'] as int,
      title: json['title'] as String,
      duration: json['duration'] as int,
      language: lang,
    );
  }

  @override
  List<MeditationInfo> fromJson(dynamic json) {
    return [for (dynamic item in json) deserilizeItem(item)];
  }
}
