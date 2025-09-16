import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/note_editor.dart';
import '../widgets/summary_card.dart';
import '../models/note_summary.dart';
import '../providers/notes_provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _summarizeText() async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final text = _noteController.text.trim();

    // Validate text
    final validation = notesProvider.validateText(text);
    if (!validation['isValid']) {
      final errors = validation['errors'] as List<String>;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.first),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show warnings if any
    final warnings = validation['warnings'] as List<String>;
    if (warnings.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(warnings.first),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Perform summarization
    final summary = await notesProvider.summarizeText(text);

    if (summary != null) {
      // Clear the text editor and switch to summaries tab
      _noteController.clear();
      _tabController.animateTo(1);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Summary created successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteSummary(NoteSummary summary) {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    notesProvider.deleteSummary(summary.id);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text('Summary deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Note: In a real implementation, you'd need to restore the summary
            // For now, just reload summaries
            notesProvider.reloadSummaries();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Note Summarizer'),
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note), text: 'New Note'),
            Tab(icon: Icon(Icons.history), text: 'Saved Summaries'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // New Note Tab
          _buildNewNoteTab(),

          // Saved Summaries Tab
          _buildSavedSummariesTab(),
        ],
      ),
    );
  }

  Widget _buildNewNoteTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AI Note Summarizer',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Paste or type your text below and get an AI-generated summary with key points',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Error display
              if (notesProvider.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          notesProvider.error!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Note editor
              NoteEditor(
                controller: _noteController,
                hintText:
                    'Paste your text here or start typing...\n\nThis could be meeting notes, article content, research findings, or any long-form text you want to summarize.',
                minLines: 8,
                maxLines: null,
                enabled: !notesProvider.isLoading,
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          !notesProvider.isLoading &&
                              _noteController.text.isNotEmpty
                          ? () => _noteController.clear()
                          : null,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: !notesProvider.isLoading
                          ? _summarizeText
                          : null,
                      icon: notesProvider.isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        notesProvider.isLoading
                            ? 'Summarizing...'
                            : 'Summarize',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tips section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for better summaries',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...[
                      'Longer texts (100+ words) produce better summaries',
                      'Include context and background information',
                      'Structure your text with clear paragraphs',
                      'Remove unnecessary formatting before pasting',
                    ].map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tip,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedSummariesTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        if (notesProvider.summaries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No saved summaries yet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first summary in the New Note tab',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _tabController.animateTo(0),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Summary'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: notesProvider.summaries.length,
          itemBuilder: (context, index) {
            final summary = notesProvider.summaries[index];
            return SummaryCard(
              summary: summary,
              onDelete: () => _deleteSummary(summary),
            );
          },
        );
      },
    );
  }
}
