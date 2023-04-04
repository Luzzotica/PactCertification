import 'package:flutter/material.dart';
import 'package:pact_certification_site/models/document.dart';

class DocumentListState with ChangeNotifier {
  final List<Document> _documents = [
    Document(title: 'Document 1', content: '# Document 1 Content'),
    // Add more documents
  ];

  int _selectedDocumentIndex = 0;

  List<Document> get documents => _documents;
  int get selectedDocumentIndex => _selectedDocumentIndex;
  Document get selectedDocument => _documents[_selectedDocumentIndex];

  void selectDocument(int index) {
    _selectedDocumentIndex = index;
    notifyListeners();
  }
}
