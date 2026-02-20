// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get app_name => 'Minuterie de Méditation';

  @override
  String get action_start => 'COMMENCER';

  @override
  String get action_stop => 'ARRÊT';

  @override
  String get action_pause => 'PAUSE';

  @override
  String get action_continue => 'CONTINUER';

  @override
  String get action_stop_tooltip => 'arrêter la minuterie';

  @override
  String get action_back => 'Retour';

  @override
  String get lb_minute_short => 'min';

  @override
  String get lb_meditation => 'Méditation';

  @override
  String get lb_pranayama => 'Prāṇāyāma';

  @override
  String get lb_med_settings => 'Méditation';

  @override
  String get lb_med_session_duration => 'Durée de la méditation';

  @override
  String get lb_med_use_session_gong =>
      'Utilisez un gong au initial et à la fin';

  @override
  String get lb_med_session_gong_volume => 'Volume du gong initial';

  @override
  String get lb_med_use_round_gong => 'Utilisez le gong de la ronde';

  @override
  String get lb_med_round_duration => 'Durée de la ronde';

  @override
  String get lb_med_round_gong_volume => 'Volume du gong de la ronde';

  @override
  String get lb_med_use_minor_gong => 'Utilisez un gong mineur';

  @override
  String get lb_med_minor_duration => 'Durée du cycle mineur';

  @override
  String get lb_med_minor_gong_volume => 'Volume du gong mineur';

  @override
  String get lb_pra_settings => 'Pranayama';

  @override
  String get lb_pra_start_round => 'Effectuer une préparation respiratoire';

  @override
  String get lb_pra_set_duration => 'Définir la durée';

  @override
  String get lb_pra_use_metronome => 'Utilisez un métronome d\'une seconde';

  @override
  String get lb_pra_metronome_volume => 'Volume du métronome';

  @override
  String get lb_app_settings => 'Paramètres';

  @override
  String get lb_app_use_silent_mode =>
      'Utiliser le mode silencieux au démarrage';

  @override
  String get lb_app_color_scheme => 'Schéma de couleurs';

  @override
  String get lb_app_language => 'Langue';

  @override
  String get lb_language_system_default => 'Par défaut du système';

  @override
  String get permission_msg_title => 'Ne pas déranger';

  @override
  String get permission_msg_1 =>
      'L\'application peut automatiquement mettre votre téléphone en silencieux pendant la méditation.';

  @override
  String get permission_msg_2 =>
      'Cela évitera les appels et notifications distrayants pour que vous puissiez vous concentrer sur votre pratique.';

  @override
  String get permission_msg_3 =>
      'Vous pouvez modifier cela à tout moment dans les paramètres de l\'application.';

  @override
  String get permission_msg_reject => 'Pas maintenant';

  @override
  String get permission_msg_accept => 'Autoriser';

  @override
  String get permission_msg_dont_ask => 'Ne plus demander';

  @override
  String get permission_denied_msg =>
      'L\'autorisation du mode silencieux n\'a pas été accordée. Vous pouvez l\'activer plus tard dans les paramètres.';

  @override
  String get permission_permanently_denied_msg =>
      'L\'autorisation du mode silencieux a été refusée. Veuillez l\'activer dans les paramètres de l\'appareil.';

  @override
  String get permission_open_settings => 'Ouvrir Paramètres';

  @override
  String get error_no_internet =>
      'Connexion Internet non détectée. Veuillez vérifier vos paramètres et réessayer.';

  @override
  String get error_app_version =>
      'Le service a renvoyé une erreur. Assurez-vous d\'utiliser la version actuelle de l\'application et réessayez.';

  @override
  String get error_unknown => 'Erreur inconnue.';

  @override
  String get lb_miditation_from_ai => 'Méditation de l\'IA';

  @override
  String get lb_created_by_ai => 'Créé par l\'IA';

  @override
  String get created_by_ai_msg =>
      'Toutes les méditations guidées présentées ici ont été créées et exprimées par l\'intelligence artificielle. L\'IA elle-même détermine le thème et le contenu de la méditation, chaque jour l\'IA offre différentes options.\nAvant de télécharger la méditation, vous pouvez la visualiser en téléchargeant d\'abord uniquement le texte de la méditation.\nComment l\'IA comprend-elle l\'essence et le but de la méditation? J\'étais curieux de regarder dans ce miroir.';

  @override
  String get lb_introduction => 'Entrée';

  @override
  String get lb_conclusion => 'Achèvement';

  @override
  String get msg_session_active_locked =>
      'Session en cours : certains réglages sont verrouillés.';

  @override
  String get help_pra_title => 'À propos du Pranayama';

  @override
  String get help_pra_content =>
      'Le Pranayama est une pratique yogique de contrôle de la respiration. Dans cette application, il est utilisé comme une étape préparatoire avant la méditation principale pour calmer l\'esprit et se concentrer.';

  @override
  String get help_silence_title => 'À propos du Mode Silence';

  @override
  String get help_silence_content =>
      'Lorsqu\'il est activé, l\'application active automatiquement le mode \'Ne pas déranger\' sur votre appareil pendant la session pour éviter les interruptions. Il sera restauré après la fin de la session.';

  @override
  String get lb_pranayama_desc =>
      'Exercices de respiration pour préparer la méditation';

  @override
  String get lb_session_gong_desc =>
      'Joue au début et à la fin de votre méditation';

  @override
  String get lb_round_gong_desc =>
      'Joue à intervalles réguliers pendant la méditation';

  @override
  String get lb_minor_gong_desc =>
      'Sons de rappel doux entre les intervalles de ronde';

  @override
  String get lb_metronome_desc =>
      'Son rythmique pour cadencer votre respiration';

  @override
  String get lb_silent_mode_desc =>
      'Couper les sons de l\'appareil pendant la méditation';

  @override
  String get lb_reset_defaults => 'Réinitialiser les paramètres';

  @override
  String get lb_reset_confirm_title => 'Réinitialiser les paramètres ?';

  @override
  String get lb_reset_confirm_message =>
      'Tous les paramètres seront restaurés à leurs valeurs d\'origine.';

  @override
  String lb_interval_example(int duration, String intervals) {
    return 'Pour une session de $duration min : à $intervals';
  }

  @override
  String get lb_no_meditations_available =>
      'Aucune méditation disponible pour le moment';

  @override
  String get lb_no_meditations_subtitle =>
      'De nouvelles méditations IA sont générées quotidiennement';

  @override
  String get lb_pull_to_refresh => 'Tirez pour actualiser';

  @override
  String get lb_scheduling_mode => 'Mode de planification des sons';

  @override
  String get lb_mode_interval => 'Intervalle';

  @override
  String get lb_mode_advanced => 'Avancé';

  @override
  String get lb_advanced_schedule => 'Planification personnalisée';

  @override
  String get lb_advanced_schedule_desc =>
      'Définir des sons à des moments précis';

  @override
  String get lb_add_sound_event => 'Ajouter un son';

  @override
  String get lb_edit_event => 'Modifier';

  @override
  String get lb_delete_event => 'Supprimer';

  @override
  String get lb_event_time => 'Heure';

  @override
  String get lb_event_sound_type => 'Type de son';

  @override
  String get lb_event_volume => 'Volume';

  @override
  String get lb_save_schedule => 'Enregistrer la planification';

  @override
  String get lb_load_schedule => 'Charger une planification';

  @override
  String get lb_schedule_name => 'Nom de la planification';

  @override
  String get lb_no_events_scheduled => 'Aucun son planifié';

  @override
  String get lb_no_events_scheduled_desc =>
      'Appuyez sur + pour ajouter des sons';

  @override
  String get lb_saved_schedules => 'Planifications enregistrées';

  @override
  String get lb_no_saved_schedules => 'Aucune planification enregistrée';

  @override
  String get lb_schedule_preview => 'Aperçu de la planification';

  @override
  String get lb_sound_session => 'Session';

  @override
  String get lb_sound_round => 'Ronde';

  @override
  String get lb_sound_minor => 'Mineur';

  @override
  String get msg_time_exceeds_duration =>
      'L\'heure ne peut pas dépasser la durée de la session';

  @override
  String get msg_schedule_saved => 'Planification enregistrée';

  @override
  String get msg_schedule_loaded => 'Planification chargée';

  @override
  String msg_events_filtered(int count) {
    return '$count événements supprimés (dépassaient la durée)';
  }

  @override
  String get lb_delete_schedule => 'Supprimer la planification';

  @override
  String get msg_confirm_delete_schedule =>
      'Êtes-vous sûr de vouloir supprimer cette planification ?';

  @override
  String get lb_event_repeat_count => 'Répéter';

  @override
  String get msg_minute_already_used => 'Cette minute a déjà un son';
}
