import 'package:flutter/material.dart';
import 'package:storeFlutter/util/app-theme.dart';

class AppPanel extends StatelessWidget {
  final Widget child;
  final List<Widget> children;

  AppPanel({this.child, this.children});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = getItems();
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.paddingStandard),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.colorGray3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: getItems(),
        ),
      ),
    );
  }

  List<Widget> getItems() {
    Widget border = getBorder();
    List<Widget> items = [];

    if (child != null) items.add(child);
    if (children != null) items.addAll(children);

    if (items.isEmpty) return [];

    items = items
        .expand(
          (e) => [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: e,
            ),
            border
          ],
        )
        .toList();

    items.removeLast();
    return items;
  }

  Widget getBorder() {
    return Divider(
      color: AppTheme.colorGray3,
      height: 1,
      thickness: 1,
    );
  }
}
