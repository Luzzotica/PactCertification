import 'package:flutter/material.dart';
import 'package:pact_certification_site/models/document_list_state.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentListState>(
      builder: (context, state, child) {
        return ListView.builder(
          itemCount: state.documents.length,
          itemBuilder: (context, index) {
            final document = state.documents[index];
            return ListTile(
              title: Text(document.title),
              onTap: () {
                state.selectDocument(index);
                Scaffold.of(context).openEndDrawer(); // Close drawer on mobile
              },
            );
          },
        );
      },
    );
  }
}
