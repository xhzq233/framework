/// EcsMerchantApp - list_section
/// Created by xhz on 8/19/24

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../cupertino.dart';

class ListTileChevron extends StatelessWidget {
  const ListTileChevron({super.key, this.longSideSize, this.color});

  final double? longSideSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.arrow_forward_ios,
      size: longSideSize ?? 20,
      color: color ?? CupertinoColors.systemGrey3.resolveFrom(context),
    );
  }
}

class ListItemModel extends StatelessWidget {
  final String title;
  final Widget? trailingIcon;
  final VoidCallback? onTap;
  final Widget? moreInfo;

  const ListItemModel({
    super.key,
    required this.title,
    this.trailingIcon,
    this.onTap,
    this.moreInfo,
  });

  const ListItemModel.trailingChevron({
    super.key,
    required this.title,
    this.onTap,
    this.moreInfo,
  }) : trailingIcon = const ListTileChevron();

  ListItemModel.trailingSwitch({
    super.key,
    required this.title,
    this.moreInfo,
    required bool value,
    required ValueChanged<bool> onChanged,
  })  : trailingIcon = CupertinoSwitch(
          value: value,
          onChanged: onChanged,
        ),
        onTap = null;

  const ListItemModel.center({super.key, required this.title, this.onTap})
      : trailingIcon = null,
        moreInfo = null;

  @override
  Widget build(BuildContext context) {
    Widget child = DefaultTextStyle(
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: CupertinoColors.label.resolveFrom(context))),
          if (moreInfo != null || trailingIcon != null) const Spacer(flex: 3),
          if (moreInfo != null)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Align(alignment: Alignment.centerRight, child: moreInfo!),
              ),
            ),
          if (trailingIcon != null) trailingIcon!,
        ],
      ),
    );
    child = Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12 + 1, bottom: 12 + 1),
      child: child,
    );
    if (onTap != null) {
      child = CustomCupertinoFillButton(
        onTap: onTap,
        child: child,
      );
    }
    return child;
  }
}

class ListSectionButton extends StatelessWidget {
  const ListSectionButton({super.key, required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      ),
      child: CustomCupertinoFillButton(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16.5, bottom: 16.5),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: CupertinoColors.label.resolveFrom(context),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class ListSection extends StatelessWidget {
  const ListSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    } else {
      final Widget content;
      if (children.length == 1) {
        content = Padding(padding: const EdgeInsets.all(8), child: children.first);
      } else {
        final widgets = List.generate(children.length, (index) {
          if (index == 0) {
            return Padding(padding: const EdgeInsets.only(top: 8, left: 8, right: 8), child: children[index]);
          } else if (index == children.length - 1) {
            return Padding(padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8), child: children[index]);
          } else {
            return Padding(padding: const EdgeInsets.only(left: 8, right: 8), child: children[index]);
          }
        }, growable: false);
        content = Column(children: widgets);
      }
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
        ),
        child: content,
      );
    }
  }
}

class EMListTile extends StatelessWidget {
  const EMListTile({super.key, required this.title, this.subtitle, this.trailing, this.icon, this.onTap});

  const EMListTile.trailingChevron({super.key, required this.title, this.subtitle, this.icon, this.onTap})
      : trailing = const ListTileChevron();

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomCupertinoFillButton(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
          child: Row(
            children: [
              if (icon != null) ClipOval(child: SizedBox(width: 40, height: 40, child: icon!)),
              if (icon != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15), maxLines: 1),
                    if (subtitle != null) const SizedBox(height: 4),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                        maxLines: 2,
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
