import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journalee/features/entries/providers/entries_providers.dart';

class CreateEntryScreen extends ConsumerStatefulWidget {
  final String journalId;

  const CreateEntryScreen({
    super.key,
    required this.journalId,
  });

  @override
  ConsumerState<CreateEntryScreen> createState() => _CreateEntryScreenState();
}

class _CreateEntryScreenState extends ConsumerState<CreateEntryScreen> {
  late QuillController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final plainText = _controller.document.toPlainText().trim();

    if (plainText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before saving')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Save as JSON to preserve rich text formatting
      final deltaJson = _controller.document.toDelta().toJson();
      final richContent = jsonEncode(deltaJson);

      await ref
          .read(entriesProvider(widget.journalId).notifier)
          .createEntry(richContent);

      if (mounted) {
        context.go('/entries/${widget.journalId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.go('/entries/${widget.journalId}?goback=true'),
        ),
        title: const Text('New Entry'),
        // Removed save button from AppBar
      ),
      body: Column(
        children: [
          // Ultra minimal toolbar - just bold, italic, and undo/redo, aligned left
          QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(
              // Align toolbar to the left
              toolbarIconAlignment: WrapAlignment.start,

              // Only show essential formatting
              showBoldButton: true,
              showItalicButton: true,
              showUndo: true,
              showRedo: true,

              // Hide everything else including code and special formatting
              showUnderLineButton: false,
              showStrikeThrough: false,
              showInlineCode: false,
              showCodeBlock: false,
              showSuperscript: false,
              showSubscript: false,
              showListCheck: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showClearFormat: false,
              showAlignmentButtons: false,
              showHeaderStyle: false,
              showListNumbers: false,
              showListBullets: false,
              showQuote: false,
              showIndent: false,
              showLink: false,
              showSearchButton: false,
              showFontFamily: false,
              showFontSize: false,
              showDirection: false,
              showClipboardCut: false,
              showClipboardCopy: false,
              showClipboardPaste: false,
            ),
          ),
          // Editor with padding for better aesthetics
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0), // More generous padding
              child: QuillEditor.basic(
                controller: _controller,
                config: const QuillEditorConfig(
                  placeholder: 'Write your journal entry here...',
                  autoFocus: true,
                  padding:
                      EdgeInsets.all(16.0), // Internal padding for the text
                ),
              ),
            ),
          ),
        ],
      ),
      // Floating save button in bottom right
      floatingActionButton: FloatingActionButton(
        onPressed: _isSaving ? null : _saveEntry,
        backgroundColor: _isSaving ? Colors.grey : null,
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save),
      ),
    );
  }
}
