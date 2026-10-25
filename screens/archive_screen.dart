import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/card_view.dart';
import 'note_editor_screen.dart';
import 'settings_screen.dart';

class ArchiveScreen extends StatefulWidget {
  final String currentTheme;
  final String currentColor;
  final OnThemeColorChanged onThemeChanged;

  const ArchiveScreen({
    super.key,
    required this.currentTheme,
    required this.currentColor,
    required this.onThemeChanged,
  });

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() => _isLoading = true);
    try {
      final data = await NoteService.getArchiveNotes();
      setState(() {
        _notes = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Lỗi tải danh sách lưu trữ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: KeepDrawer(
        selectedIndex: 1,
        currentTheme: widget.currentTheme,
        currentColor: widget.currentColor,
        onThemeChanged: widget.onThemeChanged,
      ),
      appBar: AppBar(
        title: Text(
          'Lưu trữ',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: colorScheme.onSurfaceVariant),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notes.isEmpty
                ? _buildEmptyState(colorScheme)
                : RefreshIndicator(
                    onRefresh: _fetchNotes,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _notes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return CardView(
                          note: note,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteEditorScreen(
                                  note: note,
                                  isArchive: true,
                                ),
                              ),
                            );
                            _fetchNotes();
                          },
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive_outlined,
            size: 80,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có ghi chú nào trong lưu trữ',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
