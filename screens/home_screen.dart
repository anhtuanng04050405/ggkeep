import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/card_view.dart';
import '../widgets/home_search_bar.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  List<Note> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotes() async {
    setState(() => _isLoading = true);
    try {
      final data = await NoteService.getHomeNotes();
      setState(() {
        _notes = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Lỗi tải danh sách ghi chú: $e');
    }
  }

  List<Note> get _filteredNotes {
    if (_searchQuery.trim().isEmpty) {
      return _notes;
    }
    final query = _searchQuery.trim().toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const KeepDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh tìm kiếm
            KeepSearchBar(
              controller: _searchController,
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredNotes.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _fetchNotes,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            itemCount: _filteredNotes.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final note = _filteredNotes[index];
                              return CardView(
                                note: note,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NoteEditorScreen(
                                        note: note,
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
          ],
        ),
      ),

      // Nút thêm ghi chú
      floatingActionButton: SizedBox(
        width: 50,
        height: 50,
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NoteEditorScreen(),
              ),
            );
            _fetchNotes();
          },
          backgroundColor: const Color(0xFF5C6BC0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.trim().isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_outlined : Icons.lightbulb_outline,
            size: 80,
            color: const Color(0xFF80868B),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'Không tìm thấy ghi chú phù hợp'
                : 'Không có ghi chú nào',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF80868B),
            ),
          ),
        ],
      ),
    );
  }
}
