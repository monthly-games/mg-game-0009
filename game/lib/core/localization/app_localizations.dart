// ignore_for_file: non_constant_identifier_names

import 'package:mg_common_game/l10n/app_localizations.dart';

export 'package:mg_common_game/l10n/localization.dart';

extension MG0009Localizations on AppLocalizations {
  String notificationRewardsClaimed(int reward) => '$reward gold claimed';
  String get menuNavigationResume => 'Resume';
  String get menuNavigationRestart => 'Restart';
  String get menuNavigationMainMenu => 'Main Menu';
  String get shopPurchasedSuccessfully => 'Purchase completed';
  String get uiGeneralNotEnoughGold => 'Not enough gold';
  String get uiGeneralDiwaliTokenCollection => 'Token collection';
  String get uiGeneral1xPull => '1x Pull';
  String get uiGeneral10xPull => '10x Pull';
}