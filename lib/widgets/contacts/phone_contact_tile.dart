import 'package:flutter/material.dart';
import 'package:nepanikar/app/generated/assets.gen.dart';
import 'package:nepanikar/app/theme/colors.dart';
import 'package:nepanikar/app/theme/fonts.dart';
import 'package:nepanikar/helpers/contact_action_helpers.dart';
import 'package:nepanikar/helpers/semantics_helpers.dart';
import 'package:nepanikar/widgets/long_tile.dart';
import 'package:nepanikar_contacts_gen/nepanikar_contacts_gen.dart';

class PhoneContactTile extends StatelessWidget {
  const PhoneContactTile({
    super.key,
    required this.phoneContact,
  });

  final PhoneContact phoneContact;

  TextStyle get _textTextStyle => NepanikarFonts.bodyBlack;

  TextStyle get _descriptionNumTextStyle => NepanikarFonts.bodyRoman;

  TextStyle get _phoneNumTextStyle => NepanikarFonts.bodyBlack.copyWith(
        color: NepanikarColors.primary,
      );

  @override
  Widget build(BuildContext context) {
    return phoneContact.map(
      (c) => _buildSingleContact(context, c),
      subList: (c) => _buildSubListContact(context, c),
    );
  }

  Widget _buildSingleContact(BuildContext context, PhoneContactSingle contact) {

    ThemeMode currentThemeMode = Theme.of(context).brightness == Brightness.dark ?
                                  ThemeMode.dark : ThemeMode.light;
    bool isDarkMode = currentThemeMode == ThemeMode.dark ? true : false;

    final isPinned = contact.pinned;
    final textColor = isPinned ? Colors.white : null;
    final isUrl = contact.tel.contains('http');
    return LongTile(
      isDarkMode: isDarkMode,
      text: contact.title,
      textTextStyle: _textTextStyle.copyWith(color: textColor),
      description: contact.subtitle,
      descriptionTextStyle: _descriptionNumTextStyle.copyWith(color: textColor),
      image: ExcludeSemantics(child: Assets.illustrations.contacts.phones.svg(color: textColor)),
      trailing: Text(
        contact.tel,
        semanticsLabel: isUrl ? null : contact.tel.spellOutNumFormat,
        style: _phoneNumTextStyle.copyWith(color: textColor),
      ),
      backgroundColor: isPinned ? NepanikarColors.secondary : null,
      onTap: () async => isUrl ? launchUrLink(contact.tel) : launchPhoneNum(contact.unformattedTel),
      onLongPress: () async => copyContact(context, contact.unformattedTel),
    );
  }

  Widget _buildSubListContact(BuildContext context, PhoneContactSubList contact) {

    ThemeMode currentThemeMode = Theme.of(context).brightness == Brightness.dark ?
                                  ThemeMode.dark : ThemeMode.light;
    bool isDarkMode = currentThemeMode == ThemeMode.dark ? true : false;

    final subContactsLength = contact.subPhoneContacts.length;
    final isSingleSubList = subContactsLength == 1;
    return GestureDetector(
      onTap: isSingleSubList
          ? () async => launchPhoneNum(contact.subPhoneContacts.first.unformattedTel)
          : null,
      onLongPress: isSingleSubList
          ? () async => copyContact(context, contact.subPhoneContacts.first.unformattedTel)
          : null,
      child: LongTile(
        isDarkMode: isDarkMode,
        text: contact.title,
        textTextStyle: _textTextStyle,
        description: contact.subtitle,
        descriptionTextStyle: _descriptionNumTextStyle,
        image: ExcludeSemantics(child: Assets.illustrations.contacts.phones.svg()),
        trailing: const SizedBox.shrink(),
        onTap: null,
        subContent: Column(
          children: contact.subPhoneContacts.map(
            (subContact) {
              final isUrl = subContact.tel.contains('http');
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: isSingleSubList
                            ? const EdgeInsets.symmetric(vertical: 12)
                            : EdgeInsets.zero,
                        child: Text(
                          subContact.title,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        subContact.tel,
                        semanticsLabel: isUrl ? null : subContact.tel.spellOutNumFormat,
                        style: _phoneNumTextStyle,
                      ),
                    ),
                  ],
                ),
                onTap: () async => isUrl
                    ? launchUrLink(subContact.tel)
                    : launchPhoneNum(subContact.unformattedTel),
                onLongPress: () async => copyContact(context, subContact.unformattedTel),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
