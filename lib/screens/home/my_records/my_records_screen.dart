import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nepanikar/app/generated/assets.gen.dart';
import 'package:nepanikar/app/l10n/ext.dart';
import 'package:nepanikar/app/router/routes.dart';
import 'package:nepanikar/screens/home/my_records/diary/my_records_diary_records_screen.dart';
import 'package:nepanikar/screens/home/my_records/food_records/my_records_food_records_list_screen.dart';
import 'package:nepanikar/screens/home/my_records/journal/my_records_journal_records_screen.dart';
import 'package:nepanikar/screens/home/my_records/mood_track_screen.dart';
import 'package:nepanikar/screens/home/my_records/my_records_sleep_track_screen.dart';
import 'package:nepanikar/widgets/long_tile.dart';
import 'package:nepanikar/widgets/nepanikar_screen_wrapper.dart';

class MyRecordsRoute extends GoRouteData {
  const MyRecordsRoute();

  @override
  Widget build(BuildContext context, _) => const MyRecordsScreen();
}

class MyRecordsScreen extends StatelessWidget {
  const MyRecordsScreen({super.key, this.showBottomNavbar = true});

  final bool showBottomNavbar;


  @override
  Widget build(BuildContext context) {
    ThemeMode currentThemeMode = Theme.of(context).brightness == Brightness.dark ?
    ThemeMode.dark : ThemeMode.light;
    bool isDarkMode = currentThemeMode == ThemeMode.dark ? true : false;

    final modules = <Widget>[
      LongTile(
        text: context.l10n.depression_mood,
        image: Assets.illustrations.modules.moodTracker.svg(),
        onTap: () => context.push(const MoodTrackRoute().location),
        isDarkMode: isDarkMode,
      ),
      LongTile(
        text: context.l10n.sleep_title,
        image: Assets.illustrations.modules.sleepTracker.svg(),
        onTap: () => context.push(const MyRecordsSleepTrackRoute().location),
        isDarkMode: isDarkMode,
      ),
      LongTile(
        text: context.l10n.diary,
        image: Assets.illustrations.modules.diary.svg(),
        onTap: () => context.push(const MyRecordsDiaryRecordsRoute().location),
        isDarkMode: isDarkMode,
      ),
      LongTile(
        text: context.l10n.journal,
        image: Assets.illustrations.modules.journal.svg(),
        onTap: () => context.push(const MyRecordsJournalRecordsRoute().location),
        isDarkMode: isDarkMode,
      ),
      LongTile(
        text: context.l10n.food_records,
        image: Assets.illustrations.modules.foodTracker.svg(),
        onTap: () => context.push(const MyRecordsFoodRecordsListRoute().location),
        isDarkMode: isDarkMode,
      ),
    ];

    return NepanikarScreenWrapper(
      appBarTitle: context.l10n.my_records,
      showBottomNavbar: showBottomNavbar,
      children: modules,
    );
  }
}
