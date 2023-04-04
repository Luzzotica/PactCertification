import 'package:flutter/material.dart';
import 'package:pact_certification_site/models/document_list_state.dart';
import 'package:pact_certification_site/widgets/main_content.dart';
import 'package:pact_certification_site/widgets/responsive_layout.dart';
import 'package:pact_certification_site/widgets/sidebar.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DocumentListState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // Customize theme data here
        // Customize theme data here
        primaryColor: const Color(0xFF1E1E1E),
        scaffoldBackgroundColor: const Color(0xFF252526),
        textTheme: const TextTheme(
          bodyText1: TextStyle(fontSize: 18.0, color: Colors.white),
          bodyText2: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pact Certifications'),
          leading: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        body: Row(
          children: const [
            ResponsiveLayout(
              mobile: SizedBox.shrink(),
              desktop: SizedBox(
                width: 250,
                child: Sidebar(),
              ),
            ),
            Expanded(
              child: MainContent(),
            ),
          ],
        ),
        drawer: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return const Drawer(
                child: Sidebar(),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
