import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nepanikar/app/generated/assets.gen.dart';
import 'package:nepanikar/app/l10n/ext.dart';
import 'package:nepanikar/app/router/routes.dart';
import 'package:nepanikar/app/theme/colors.dart';
import 'package:nepanikar/app/theme/fonts.dart';
import 'package:nepanikar/helpers/screen_resolution_helpers.dart';
import 'package:nepanikar/screens/home/anxiety/anxiety_screen.dart';
import 'package:nepanikar/screens/home/depression/depression_screen.dart';
import 'package:nepanikar/screens/home/eating_disorder/eating_disorder_screen.dart';
import 'package:nepanikar/screens/home/my_records/my_records_screen.dart';
import 'package:nepanikar/screens/home/self_harm/self_harm_screen.dart';
import 'package:nepanikar/screens/home/suicidal_thoughts/suicidal_thoughts_screen.dart';
import 'package:nepanikar/services/db/my_records/mood_track_dao.dart';
import 'package:nepanikar/services/db/my_records/mood_track_model.dart';
import 'package:nepanikar/services/notifications/notifications_service.dart';
import 'package:nepanikar/utils/registry.dart';
import 'package:nepanikar/widgets/contacts/quick_help_button.dart';
import 'package:nepanikar/widgets/home_tile.dart';
import 'package:nepanikar/widgets/mood/mood_picker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  MoodTrackDao get _moodTrackDao => registry.get<MoodTrackDao>();

  NotificationsService get _notificationsService => registry.get<NotificationsService>();

  @override
  Widget build(BuildContext context) {
    bool _isDarkMode;
    ThemeMode currentThemeMode = Theme.of(context).brightness == Brightness.dark ?
    ThemeMode.dark : ThemeMode.light;
    _isDarkMode = currentThemeMode == ThemeMode.dark ? true : false;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
    );
    final modules = <HomeTile>[
      HomeTile(
        text: context.l10n.depression,
        image: Assets.illustrations.modules.depression.svg(color: _isDarkMode ? Colors.white : NepanikarColors.primaryD),
        location: const DepressionRoute().location,
      ),
      HomeTile(
        text: context.l10n.anxiety_panic,
        image: Assets.illustrations.modules.anxietyPanic.svg(color: _isDarkMode ? Colors.white : NepanikarColors.primaryD),
        location: const AnxietyAppRoute().location,
      ),
      HomeTile(
        text: context.l10n.self_harm,
        image: Assets.illustrations.modules.selfHarm.svg(color: _isDarkMode ? Colors.white : NepanikarColors.primaryD),
        location: const SelfHarmRoute().location,
      ),
      HomeTile(
        text: context.l10n.suicidal_thoughts,
        image: Assets.illustrations.modules.suicidalThoughts.svg(color: _isDarkMode ? Colors.white : NepanikarColors.primaryD),
        location: const SuicidalThoughtsRoute().location,
      ),
      HomeTile(
        text: context.l10n.food,
        image: Assets.illustrations.modules.eatingDisorder.svg(color: _isDarkMode ? Colors.white : NepanikarColors.primaryD),
        location: const EatingDisorderRoute().location,
      ),
      HomeTile(
        text: context.l10n.my_records,
        image: Assets.illustrations.modules.myRecords.svg(color: _isDarkMode ? Colors.white : NepanikarColors.primaryD),
        location: const MyRecordsRoute().location,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          primary: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ExcludeSemantics(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 6),
                            Assets.icons.logo.svg(color: _isDarkMode ? Colors.white : NepanikarColors.primaryD),
                            const SizedBox(width: 10),
                            Text(
                              context.l10n.app_name,
                              style: NepanikarFonts.title3.copyWith(
                                  fontSize: 18.6,
                                  color: _isDarkMode ? Colors.white : NepanikarColors.primaryD
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(child: QuickHelpButton()),
                  ],
                ),
              ),
              SizedBox(height: context.isSmallScreen ? 16 : 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StreamBuilder<MoodTrack?>(
                  stream: _moodTrackDao.latestMoodTrackStream,
                  builder: (_, snapshot) {
                    final latestMoodTrack = snapshot.data;
                    return MoodPicker(
                      activeMood: latestMoodTrack?.mood,
                      onPickMessage: context.l10n.mood_tracked_success_snackbar,
                      onPick: (mood) async {
                        final l10n = context.l10n;
                        await _moodTrackDao.saveMood(mood);
                        unawaited(_notificationsService.rescheduleNotifications(l10n));
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    bottom: 16.0,
                    top: context.isSmallScreen ? 20 : 30,
                  ),
                  child: AutoSizeText(
                    context.l10n.homepage_subtitle,
                    maxLines: 1,
                    style: NepanikarFonts.title2.copyWith(color: _isDarkMode ? Colors.white : NepanikarColors.primaryD),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  primary: false,
                  crossAxisCount: (MediaQuery.of(context).size.width / context.tabletMaxColumnWidth)
                      .floor()
                      .clamp(2, 6),
                  crossAxisSpacing: context.isSmallScreen ? 12 : 16,
                  mainAxisSpacing: context.isSmallScreen ? 12 : 16,
                  childAspectRatio: context.isSmallScreen ? 1.4 : 1.2,
                  children: modules,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
