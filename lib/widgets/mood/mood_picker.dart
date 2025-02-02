import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:nepanikar/app/generated/assets.gen.dart';
import 'package:nepanikar/app/l10n/ext.dart';
import 'package:nepanikar/app/theme/colors.dart';
import 'package:nepanikar/app/theme/fonts.dart';
import 'package:nepanikar/services/db/my_records/mood_track_model.dart';
import 'package:nepanikar/utils/extensions.dart';
import 'package:nepanikar/utils/lottie_cache_manager.dart';
import 'package:nepanikar/utils/registry.dart';

class MoodPicker extends StatefulWidget {
  const MoodPicker({
    super.key,
    required this.onPick,
    required this.onPickMessage,
    this.activeMood,
    this.header,
    this.autoSizeTitle = true,
    this.showLabels = true,
  });

  final Mood? activeMood;
  final ValueChanged<Mood> onPick;
  final String? header;
  final String onPickMessage;
  final bool autoSizeTitle;
  final bool showLabels;

  @override
  State<MoodPicker> createState() => _MoodPickerState();
}

class _MoodPickerState extends State<MoodPicker> with TickerProviderStateMixin {
  Mood? activeMood;

  final analytics = registry.get<FirebaseAnalytics>();

  final _lottieCacheManager = registry.get<LottieCacheManager>();

  final _lottieAnimControllersMap = <Mood, AnimationController>{};

  static const _lottieAnimDuration = Duration(milliseconds: 2590);

  AnimationController? _getLottieAnimController(Mood m) => _lottieAnimControllersMap[m];

  void _playLottieAnim(Mood m) => _getLottieAnimController(m)?.forward(from: 0);

  @override
  void initState() {
    super.initState();
    activeMood = widget.activeMood;
    for (final m in Mood.values) {
      _lottieAnimControllersMap[m] = AnimationController(
        vsync: this,
        duration: _lottieAnimDuration,
      );
    }
  }

  @override
  void didUpdateWidget(MoodPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (activeMood != widget.activeMood) {
      setState(() {
        activeMood = widget.activeMood;
      });
    }
  }

  @override
  void dispose() {
    for (final animController in _lottieAnimControllersMap.values) {
      if (mounted) animController.dispose();
    }
    _lottieAnimControllersMap.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    bool _isDarkMode;
    ThemeMode currentThemeMode = Theme.of(context).brightness == Brightness.dark ?
    ThemeMode.dark : ThemeMode.light;
    _isDarkMode = currentThemeMode == ThemeMode.dark ? true : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.autoSizeTitle)
          Text(
            widget.header ?? context.l10n.mood_welcome_title,
            style: NepanikarFonts.title2.copyWith(color: _isDarkMode ? Colors.white : NepanikarColors.primaryD),
          )
        else
          AutoSizeText(
            context.l10n.mood_welcome_title,
            maxLines: 1,
            style: NepanikarFonts.title2.copyWith(color: _isDarkMode ? Colors.white : NepanikarColors.primaryD),
          ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: Mood.values.reversed.map(
            (mood) {
              final isPicked = activeMood == mood;
              return Semantics(
                button: true,
                selected: isPicked,
                label: widget.showLabels ? null : mood.getSemanticsLabel(context),
                child: InkWell(
                  onTap: () {
                    if (isPicked) {
                      _playLottieAnim(mood);
                      return;
                    }
                    setState(() => activeMood = mood);
                    _playLottieAnim(mood);
                    context.hideCurrentSnackBar();
                    context.showSuccessSnackbar(
                      text: widget.onPickMessage,
                      leading: Assets.icons.checkmarks.checkCircular.svg(),
                    );
                    widget.onPick.call(mood);
                    analytics.logEvent(
                      name: 'mood_picked',
                      parameters: {
                        'mood': mood.name,
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Opacity(
                    opacity: activeMood != null && activeMood != mood ? 0.4 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
                      child: Column(
                        children: [
                          _lottieCacheManager.loadFromCache(
                            mood.animatedIcon,
                            controller: _getLottieAnimController(mood),
                            width: 50,
                            height: 50,
                            repeat: false,
                            animate: false,
                          ),
                          if (widget.showLabels) ...[
                            const SizedBox(height: 4),
                            Text(
                              mood.getLabel(context),
                              style: NepanikarFonts.bodySmallHeavy,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        )
      ],
    );
  }
}
