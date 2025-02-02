import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nepanikar/app/app_constants.dart';
import 'package:nepanikar/app/generated/assets.gen.dart';
import 'package:nepanikar/app/l10n/ext.dart';
import 'package:nepanikar/app/router/routes.dart';
import 'package:nepanikar/app/theme/colors.dart';
import 'package:nepanikar/app/theme/fonts.dart';
import 'package:nepanikar/helpers/contact_action_helpers.dart';
import 'package:nepanikar/screens/settings/about_app_screen.dart';
import 'package:nepanikar/screens/settings/export_screen.dart';
import 'package:nepanikar/screens/settings/languages_screen.dart';
import 'package:nepanikar/screens/settings/sponsors_screen.dart';
import 'package:nepanikar/services/db/database_service.dart';
import 'package:nepanikar/services/notifications/notifications_service.dart';
import 'package:nepanikar/utils/app_config.dart';
import 'package:nepanikar/utils/extensions.dart';
import 'package:nepanikar/utils/registry.dart';
import 'package:nepanikar/widgets/nepanikar_screen_wrapper.dart';
import 'package:nepanikar/widgets/semantics/semantics_widget_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  //final ThemeManager themeManager;

  const SettingsScreen({super.key, /*required this.themeManager*/});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {



  AppConfig get _appConfig => registry.get<AppConfig>();

  DatabaseService get _databaseService => registry.get<DatabaseService>();


  NotificationsService get _notificationsService => registry.get<NotificationsService>();

  @override
  Widget build(BuildContext context) {

    ThemeMode currentThemeMode = Theme.of(context).brightness == Brightness.dark ?
    ThemeMode.dark : ThemeMode.light;
    bool isDarkMode = currentThemeMode == ThemeMode.dark ? true : false;

    return NepanikarScreenWrapper(
      appBarTitle: context.l10n.settings,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: NepanikarColors.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: isDarkMode ? NepanikarColors.containerD : Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  _SettingsMenuItem(
                    hideTopSeparator: true,
                    leading: isDarkMode ? Assets.icons.notificationBell.svg(color: Colors.white) : Assets.icons.notificationBell.svg(),
                    onTap: _notificationsService.checkPermission,
                    text: context.l10n.notifications,
                  ),
                  _SettingsMenuItem(
                    leading: isDarkMode ? Assets.icons.deleteData.svg(color: Colors.white) : Assets.icons.deleteData.svg(),
                    text: context.l10n.reset_inputs,
                    onTap: () {
                      context.showOkCancelNepanikarDialog(
                        title: context.l10n.delete_data_title,
                        text: context.l10n.delete_data_description,
                        secondaryBtnLabel: context.l10n.cancel,
                        primaryBtnLabel: context.l10n.clear_button,
                        onPrimaryBtnTap: (dialogContext) async {
                          final l10n = context.l10n;
                          await _databaseService.clearAll();
                          await _databaseService.preloadDefaultData(l10n);
                          await _notificationsService.cancelAllScheduledNotifications();
                          if (mounted) {
                            context.hideCurrentSnackBar();
                            context.showSuccessSnackbar(
                              text: context.l10n.delete_success,
                              leading: Assets.icons.checkmarks.checkCircular.svg(),
                            );
                          }
                        },
                      );
                    },
                  ),
                  _SettingsMenuItem(
                    leading: isDarkMode ? Assets.icons.heart.svg(color: Colors.white) : Assets.icons.heart.svg(),
                    text: context.l10n.rate,
                    onTap: () async {
                      final uri = Uri.parse(
                        Platform.isAndroid
                            ? 'market://details?id=${_appConfig.googlePlayAppId}'
                            : 'https://apps.apple.com/app/id${_appConfig.appStoreAppId}',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                  _SettingsMenuItem(
                    leading: isDarkMode ? Assets.icons.donate.svg(color: Colors.white) : Assets.icons.donate.svg(),
                    text: context.l10n.support_us,
                    onTap: () async {
                      final url = Uri.parse(
                        'https://www.darujme.cz/projekt/1203622',
                      );
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                  ),
                  _SettingsMenuItem(
                    leading: isDarkMode ? Assets.icons.exportData.svg(color: Colors.white) : Assets.icons.exportData.svg(),
                    onTap: () {
                      context.push(const ExportRoute().location);
                    },
                    text: context.l10n.import_export,
                  ),
                  _SettingsMenuItem(
                    leading: isDarkMode ? Assets.icons.aboutApp.svg(color: Colors.white) : Assets.icons.aboutApp.svg(),
                    text: context.l10n.about_app,
                    onTap: () => context.push(const AboutAppRoute().location),
                  ),
                  _SettingsMenuItem(
                    leading: isDarkMode ? Assets.icons.language.svg(color: Colors.white) : Assets.icons.language.svg(),
                    text: context.l10n.language,
                    onTap: () => context.push(const LanguagesRoute().location),
                  ),
                  _SettingsMenuItem(
                    leading: Icon(
                      Icons.shield_outlined,
                      color: isDarkMode ? Colors.white : NepanikarColors.primary,
                    ),
                    text: context.l10n.support,
                    onTap: () => context.push(const SponsorsRoute().location),
                  ),
                 /* Consumer<>(
                      builder: (context, themeProvider, child){
                        return _SettingsMenuItem(
                          text: "Dark mode",
                          leading: Switch(
                            value:
                            onChanged: (value){
                              themeProvider.changeTheme();
                            },
                          ),
                        );
                      }
                  ),*/
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: isDarkMode ? BorderSide(color: NepanikarColors.primarySwatch.shade700) : BorderSide(color: Color(0xffF2F2F5)),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                      child: Row(
                        children: [
                          ExcludeSemantics(
                            child: Text(
                              context.l10n.follow_us,
                              style: isDarkMode ? NepanikarFonts.bodySmallMedium.copyWith(fontSize: 15, color: Colors.white) :
                                                    NepanikarFonts.bodySmallMedium.copyWith(fontSize: 15),

                            ),
                          ),
                          const Spacer(),
                          SemanticsWidgetButton(
                            label: '${context.l10n.follow_us}: Web',
                            onTap: () => launchUrLink(AppConstants.nepanikarWeb),
                            child: isDarkMode ? Assets.icons.globe.svg(color: Colors.white) : Assets.icons.globe.svg(),
                          ),
                          const SizedBox(width: 27),
                          SemanticsWidgetButton(
                            label: '${context.l10n.follow_us}: Instagram',
                            onTap: () => launchUrLink(
                              AppConstants.nepanikarInstagram,
                              launchMode: LaunchMode.externalApplication,
                            ),
                            child: isDarkMode ? Assets.icons.instagram.svg(color: Colors.white) : Assets.icons.instagram.svg(),
                          ),
                          const SizedBox(width: 27),
                          SemanticsWidgetButton(
                            label: '${context.l10n.follow_us}: Facebook',
                            onTap: () => launchUrLink(
                              AppConstants.nepanikarFacebook,
                              launchMode: LaunchMode.externalApplication,
                            ),
                            child: isDarkMode ? Assets.icons.facebook.svg(color: Colors.white) : Assets.icons.facebook.svg(),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 45),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 245),
            child: Column(
              children: [
                isDarkMode ?  Assets.sponsors.sponsorPpf.image(color: NepanikarColors.primarySwatch.shade700) : Assets.sponsors.sponsorPpf.image(),
                isDarkMode ? Assets.sponsors.sponsorCeskoDigitalSvg.svg(color: NepanikarColors.primarySwatch.shade700) : Assets.sponsors.sponsorCeskoDigitalSvg.svg(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  const _SettingsMenuItem({
    this.hideTopSeparator = false,
    this.leading,
    required this.text,
    this.onTap,
  });

  final bool hideTopSeparator;
  final Widget? leading;

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {

    ThemeMode currentThemeMode = Theme.of(context).brightness == Brightness.dark ?
    ThemeMode.dark : ThemeMode.light;
    bool isDarkMode = currentThemeMode == ThemeMode.dark ? true : false;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: isDarkMode ? (hideTopSeparator ? BorderSide.none :  BorderSide(color: NepanikarColors.primarySwatch.shade700))
                          : (hideTopSeparator ? BorderSide.none : const BorderSide(color: Color(0xffF2F2F5))),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(
                        width: 16,
                      ),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        style: isDarkMode ? NepanikarFonts.bodySmallMedium.copyWith(fontSize: 15, color: Colors.white)
                                            : NepanikarFonts.bodySmallMedium.copyWith(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              Opacity(
                opacity: onTap != null ? 1 : 0.5,
                child: Icon(
                  Icons.chevron_right,
                  color: isDarkMode ? Colors.white : const Color(0xffCDD1D5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
