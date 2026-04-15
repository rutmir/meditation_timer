// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get app_name => 'Таймер Медитации';

  @override
  String get action_start => 'СТАРТ';

  @override
  String get action_stop => 'СТОП';

  @override
  String get action_pause => 'ПАУЗА';

  @override
  String get action_continue => 'ПРОДОЛЖИТЬ';

  @override
  String get action_stop_tooltip => 'стоп таймер';

  @override
  String get action_back => 'Назад';

  @override
  String get lb_minute_short => 'мин';

  @override
  String get lb_meditation => 'Медитация';

  @override
  String get lb_pranayama => 'Пранаяма';

  @override
  String get lb_med_settings => 'Медитация';

  @override
  String get lb_med_session_duration => 'Продолжительность медитации';

  @override
  String get lb_med_use_session_gong =>
      'Использовать гонг в начале и конце сессии';

  @override
  String get lb_med_session_gong_volume => 'Громкость начального гонга';

  @override
  String get lb_med_use_round_gong => 'Использовать гонг раунда';

  @override
  String get lb_med_round_duration => 'Продолжительность раунда';

  @override
  String get lb_med_round_gong_volume => 'Громкость гонга раунда';

  @override
  String get lb_med_use_minor_gong => 'Использовать малый гонг';

  @override
  String get lb_med_minor_duration => 'Продолжительность малого цикла';

  @override
  String get lb_med_minor_gong_volume => 'Громкость малого гонга';

  @override
  String get lb_pra_settings => 'Пранаяма';

  @override
  String get lb_pra_start_round => 'Выполнить подготовку дыхания';

  @override
  String get lb_pra_set_duration => 'Продолжительность раунда';

  @override
  String get lb_pra_use_metronome => 'Использовать метроном (1 секунда)';

  @override
  String get lb_pra_metronome_volume => 'Громкость метронома';

  @override
  String get lb_app_settings => 'Настройки';

  @override
  String get lb_app_use_silent_mode => 'Использовать режим тишины при старте';

  @override
  String get lb_app_color_scheme => 'Цветовая схема';

  @override
  String get lb_app_language => 'Язык';

  @override
  String get lb_language_system_default => 'По умолчанию';

  @override
  String get permission_msg_title => 'Не беспокоить';

  @override
  String get permission_msg_1 =>
      'Приложение может автоматически отключать звук телефона во время медитации.';

  @override
  String get permission_msg_2 =>
      'Это предотвратит отвлекающие звонки и уведомления, чтобы вы могли сосредоточиться на практике.';

  @override
  String get permission_msg_3 =>
      'Вы можете изменить это в любое время в настройках приложения.';

  @override
  String get permission_msg_reject => 'Не сейчас';

  @override
  String get permission_msg_accept => 'Разрешить';

  @override
  String get permission_msg_dont_ask => 'Больше не спрашивать';

  @override
  String get permission_denied_msg =>
      'Разрешение на тихий режим не предоставлено. Вы можете включить его позже в настройках.';

  @override
  String get permission_permanently_denied_msg =>
      'Разрешение на тихий режим отклонено. Пожалуйста, включите его в настройках устройства.';

  @override
  String get permission_open_settings => 'Настройки';

  @override
  String get error_no_internet =>
      'Отсутствует подключение к интернету. Проверьте настройки и попробуйте снова.';

  @override
  String get error_app_version =>
      'Сервис вернул ошибку. Убедитесь, что вы используете актуальную версию приложения и попробуйте снова.';

  @override
  String get error_unknown => 'Неизвестная ошибка.';

  @override
  String get lb_miditation_from_ai => 'Медитация от ИИ';

  @override
  String get lb_created_by_ai => 'Создано ИИ';

  @override
  String get created_by_ai_msg =>
      'Все представленные здесь управляемые медитации было созданы и озвучены искусственным интеллектом. ИИ сам определяет тему и содержание медитации, каждый день ИИ предлагает разные варианты.\nПрежде чем загрузить медитацию вы можете просмотреть её, загрузив сначала только текст медитации.\nКак ИИ понимает суть и цели медитации? Мне было интересно взглянуть в это зеркало.';

  @override
  String get lb_introduction => 'Вступление';

  @override
  String get lb_conclusion => 'Завершение';

  @override
  String get msg_session_active_locked =>
      'Сессия запущена: некоторые настройки заблокированы.';

  @override
  String get help_pra_title => 'О пранаяме';

  @override
  String get help_pra_content =>
      'Пранаяма — это йогическая практика контроля дыхания. В этом приложении она используется как подготовительный этап перед основной медитацией, чтобы успокоить ум и сосредоточиться.';

  @override
  String get help_silence_title => 'О режиме тишины';

  @override
  String get help_silence_content =>
      'Если эта функция включена, приложение будет автоматически включать режим «Не беспокоить» на вашем устройстве во время сеанса, чтобы предотвратить прерывания. Режим будет восстановлен после завершения сеанса.';

  @override
  String get lb_pranayama_desc =>
      'Дыхательные упражнения для подготовки к медитации';

  @override
  String get lb_session_gong_desc => 'Звучит в начале и конце медитации';

  @override
  String get lb_round_gong_desc =>
      'Звучит через регулярные интервалы во время медитации';

  @override
  String get lb_minor_gong_desc => 'Тихие напоминания между интервалами раунда';

  @override
  String get lb_metronome_desc => 'Ритмичный звук для контроля дыхания';

  @override
  String get lb_silent_mode_desc =>
      'Отключить звуки устройства во время медитации';

  @override
  String get lb_reset_defaults => 'Сбросить настройки';

  @override
  String get lb_reset_confirm_title => 'Сбросить настройки?';

  @override
  String get lb_reset_confirm_message =>
      'Все настройки будут восстановлены до исходных значений.';

  @override
  String lb_interval_example(int duration, String intervals) {
    return 'Для $duration мин сессии: на $intervals';
  }

  @override
  String get lb_no_meditations_available => 'Пока нет доступных медитаций';

  @override
  String get lb_no_meditations_subtitle =>
      'Новые медитации от ИИ генерируются ежедневно';

  @override
  String get lb_pull_to_refresh => 'Потяните для обновления';

  @override
  String get lb_scheduling_mode => 'Режим расписания звуков';

  @override
  String get lb_mode_interval => 'Интервал';

  @override
  String get lb_mode_advanced => 'Расширенный';

  @override
  String get lb_advanced_schedule => 'Пользовательское расписание';

  @override
  String get lb_advanced_schedule_desc =>
      'Установите звуки в определённое время';

  @override
  String get lb_add_sound_event => 'Добавить звук';

  @override
  String get lb_edit_event => 'Редактировать';

  @override
  String get lb_delete_event => 'Удалить';

  @override
  String get lb_event_time => 'Время';

  @override
  String get lb_event_sound_type => 'Тип звука';

  @override
  String get lb_event_volume => 'Громкость';

  @override
  String get lb_save_schedule => 'Сохранить расписание';

  @override
  String get lb_load_schedule => 'Загрузить расписание';

  @override
  String get lb_schedule_name => 'Название расписания';

  @override
  String get lb_no_events_scheduled => 'Нет запланированных звуков';

  @override
  String get lb_no_events_scheduled_desc => 'Нажмите + чтобы добавить звуки';

  @override
  String get lb_saved_schedules => 'Сохранённые расписания';

  @override
  String get lb_no_saved_schedules => 'Нет сохранённых расписаний';

  @override
  String get lb_schedule_preview => 'Предпросмотр расписания';

  @override
  String get lb_sound_session => 'Сессия';

  @override
  String get lb_sound_round => 'Раунд';

  @override
  String get lb_sound_minor => 'Малый';

  @override
  String get msg_time_exceeds_duration =>
      'Время не может превышать продолжительность сессии';

  @override
  String get msg_schedule_saved => 'Расписание сохранено';

  @override
  String get msg_schedule_loaded => 'Расписание загружено';

  @override
  String msg_events_filtered(int count) {
    return '$count событий удалено (превышена продолжительность)';
  }

  @override
  String get lb_delete_schedule => 'Удалить расписание';

  @override
  String get msg_confirm_delete_schedule =>
      'Вы уверены, что хотите удалить это расписание?';

  @override
  String get lb_event_repeat_count => 'Повторить';

  @override
  String get msg_minute_already_used => 'На эту минуту уже назначен звук';

  @override
  String get wallet_title => 'Подключить кошелёк';

  @override
  String get wallet_required_title => 'Требуется токен ROEX';

  @override
  String wallet_required_amount(String amount) {
    return 'Держите не менее $amount ROEX для доступа к AI-медитациям';
  }

  @override
  String wallet_current_price(String price) {
    return 'Текущая цена: $price / ROEX';
  }

  @override
  String get wallet_pubkey_label => 'Адрес Solana кошелька';

  @override
  String get wallet_pubkey_hint => 'Введите публичный ключ (base58)';

  @override
  String get wallet_invalid_pubkey =>
      'Неверный адрес Solana. Проверьте и повторите.';

  @override
  String get wallet_save => 'Подключить';

  @override
  String get wallet_disconnect => 'Отключить кошелёк';

  @override
  String get wallet_buy_roex => 'Купить ROEX на Jupiter';

  @override
  String get wallet_copy_tooltip => 'Скопировать адрес';
}
