// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get app_name => 'Temporizador de Meditación';

  @override
  String get action_start => 'COMENZAR';

  @override
  String get action_stop => 'DETENER';

  @override
  String get action_pause => 'PAUSA';

  @override
  String get action_continue => 'CONTINUAR';

  @override
  String get action_stop_tooltip => 'detener el temporizador';

  @override
  String get action_back => 'Atrás';

  @override
  String get lb_minute_short => 'min';

  @override
  String get lb_meditation => 'Meditación';

  @override
  String get lb_pranayama => 'Prāṇāyāma';

  @override
  String get lb_med_settings => 'Meditación';

  @override
  String get lb_med_session_duration => 'Duración de la meditación';

  @override
  String get lb_med_use_session_gong => 'Usa un gong al principio y al final';

  @override
  String get lb_med_session_gong_volume => 'Volumen del gong inicial';

  @override
  String get lb_med_use_round_gong => 'Usa el gong de la ronda';

  @override
  String get lb_med_round_duration => 'Duración de la ronda';

  @override
  String get lb_med_round_gong_volume => 'Volumen el gong de la ronda';

  @override
  String get lb_med_use_minor_gong => 'Usa gong menor';

  @override
  String get lb_med_minor_duration => 'Duración del ciclo menor';

  @override
  String get lb_med_minor_gong_volume => 'Volumen de gong menor';

  @override
  String get lb_pra_settings => 'Pranayama';

  @override
  String get lb_pra_start_round => 'Realizar la preparación respiración';

  @override
  String get lb_pra_set_duration => 'Duración de la ronda';

  @override
  String get lb_pra_use_metronome => 'Usa metrónomo de un segundo';

  @override
  String get lb_pra_metronome_volume => 'Volumen del metrónomo';

  @override
  String get lb_app_settings => 'Configuración';

  @override
  String get lb_app_use_silent_mode => 'Usar el modo de silencio al Inicio';

  @override
  String get lb_app_color_scheme => 'Esquema de color';

  @override
  String get lb_app_language => 'Idioma';

  @override
  String get lb_language_system_default => 'Predeterminado del sistema';

  @override
  String get permission_msg_title => 'No molestar';

  @override
  String get permission_msg_1 =>
      'La aplicación puede silenciar automáticamente tu teléfono durante la meditación.';

  @override
  String get permission_msg_2 =>
      'Esto evitará llamadas y notificaciones que distraigan para que puedas concentrarte en tu práctica.';

  @override
  String get permission_msg_3 =>
      'Puedes cambiar esto en cualquier momento en los ajustes de la aplicación.';

  @override
  String get permission_msg_reject => 'Ahora no';

  @override
  String get permission_msg_accept => 'Permitir';

  @override
  String get permission_msg_dont_ask => 'No volver a preguntar';

  @override
  String get permission_denied_msg =>
      'No se concedió el permiso de modo silencioso. Puedes habilitarlo más tarde en Ajustes.';

  @override
  String get permission_permanently_denied_msg =>
      'El permiso de modo silencioso fue denegado. Por favor, habilítalo en los ajustes del dispositivo.';

  @override
  String get permission_open_settings => 'Abrir Ajustes';

  @override
  String get error_no_internet =>
      'Conexión a Internet no detectada. Compruebe su configuración e inténtelo de nuevo.';

  @override
  String get error_app_version =>
      'El servicio devolvió un error. Asegúrese de que está utilizando la versión actual de la aplicación y vuelva a intentarlo.';

  @override
  String get error_unknown => 'Error desconocido.';

  @override
  String get lb_miditation_from_ai => 'Meditación de la IA';

  @override
  String get lb_created_by_ai => 'Creado por IA';

  @override
  String get created_by_ai_msg =>
      'Todas las meditaciones guiadas presentadas aquí fueron creadas y expresadas por inteligencia artificial. La IA determina el tema y el contenido de la meditación, cada día la IA ofrece diferentes opciones.\nAntes de descargar la meditación, puede verla descargando primero solo el texto de la meditación.\n¿Cómo entiende la IA la esencia y los objetivos de la meditación? Me interesaba mirarme en ese espejo.';

  @override
  String get lb_introduction => 'Entrada';

  @override
  String get lb_conclusion => 'Finalización';

  @override
  String get msg_session_active_locked =>
      'Sesión en curso: algunos ajustes están bloqueados.';

  @override
  String get help_pra_title => 'Sobre el Pranayama';

  @override
  String get help_pra_content =>
      'El Pranayama es una práctica yóguica de control de la respiración. En esta aplicación, se utiliza como una etapa preparatoria antes de la meditación principal para calmar la mente y concentrarse.';

  @override
  String get help_silence_title => 'Sobre el Modo Silencio';

  @override
  String get help_silence_content =>
      'Cuando está activado, la aplicación activará automáticamente el modo \'No molestar\' en su dispositivo durante la sesión para evitar interrupciones. Se restaurará después de que finalice la sesión.';

  @override
  String get lb_pranayama_desc =>
      'Ejercicios de respiración para prepararse para la meditación';

  @override
  String get lb_session_gong_desc =>
      'Suena al inicio y al final de tu meditación';

  @override
  String get lb_round_gong_desc =>
      'Suena a intervalos regulares durante la meditación';

  @override
  String get lb_minor_gong_desc =>
      'Sonidos suaves de recordatorio entre intervalos de ronda';

  @override
  String get lb_metronome_desc => 'Sonido rítmico para marcar tu respiración';

  @override
  String get lb_silent_mode_desc =>
      'Silenciar los sonidos del dispositivo durante la meditación';

  @override
  String get lb_reset_defaults => 'Restablecer valores predeterminados';

  @override
  String get lb_reset_confirm_title => '¿Restablecer configuración?';

  @override
  String get lb_reset_confirm_message =>
      'Todos los ajustes se restaurarán a sus valores originales.';

  @override
  String lb_interval_example(int duration, String intervals) {
    return 'Para sesión de $duration min: a las $intervals';
  }

  @override
  String get lb_no_meditations_available =>
      'No hay meditaciones disponibles aún';

  @override
  String get lb_no_meditations_subtitle =>
      'Nuevas meditaciones de IA se generan diariamente';

  @override
  String get lb_pull_to_refresh => 'Desliza para actualizar';

  @override
  String get lb_scheduling_mode => 'Modo de programación de sonidos';

  @override
  String get lb_mode_interval => 'Intervalo';

  @override
  String get lb_mode_advanced => 'Avanzado';

  @override
  String get lb_advanced_schedule => 'Programación personalizada';

  @override
  String get lb_advanced_schedule_desc =>
      'Configura sonidos en momentos específicos';

  @override
  String get lb_add_sound_event => 'Añadir sonido';

  @override
  String get lb_edit_event => 'Editar';

  @override
  String get lb_delete_event => 'Eliminar';

  @override
  String get lb_event_time => 'Hora';

  @override
  String get lb_event_sound_type => 'Tipo de sonido';

  @override
  String get lb_event_volume => 'Volumen';

  @override
  String get lb_save_schedule => 'Guardar programación';

  @override
  String get lb_load_schedule => 'Cargar programación';

  @override
  String get lb_schedule_name => 'Nombre de la programación';

  @override
  String get lb_no_events_scheduled => 'No hay sonidos programados';

  @override
  String get lb_no_events_scheduled_desc => 'Toca + para añadir sonidos';

  @override
  String get lb_saved_schedules => 'Programaciones guardadas';

  @override
  String get lb_no_saved_schedules => 'No hay programaciones guardadas';

  @override
  String get lb_schedule_preview => 'Vista previa de programación';

  @override
  String get lb_sound_session => 'Sesión';

  @override
  String get lb_sound_round => 'Ronda';

  @override
  String get lb_sound_minor => 'Menor';

  @override
  String get msg_time_exceeds_duration =>
      'El tiempo no puede superar la duración de la sesión';

  @override
  String get msg_schedule_saved => 'Programación guardada';

  @override
  String get msg_schedule_loaded => 'Programación cargada';

  @override
  String msg_events_filtered(int count) {
    return '$count eventos eliminados (superaban la duración)';
  }

  @override
  String get lb_delete_schedule => 'Eliminar programación';

  @override
  String get msg_confirm_delete_schedule =>
      '¿Estás seguro de que quieres eliminar esta programación?';

  @override
  String get lb_event_repeat_count => 'Repetir';

  @override
  String get msg_minute_already_used => 'Este minuto ya tiene un sonido';
}
