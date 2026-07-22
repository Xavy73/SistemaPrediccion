import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget appBarTitle;
  final Widget body;
  final Widget? drawer;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({super.key, required this.appBarTitle, required this.body, this.drawer, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: appBarTitle),
      drawer: width < 900 ? drawer : null,
      body: SafeArea(
        child: Row(
          children: [
            if (width >= 900 && drawer != null)
              Container(
                width: 280,
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
                ),
                child: drawer,
              ),
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
