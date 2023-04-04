import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pact_certification_site/models/document_list_state.dart';
import 'package:provider/provider.dart';

class MainContent extends StatelessWidget {
  const MainContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentListState>(
      builder: (context, state, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Markdown(
              data: state.selectedDocument.content,
            ),
          ),
        );
      },
    );
  }
}
