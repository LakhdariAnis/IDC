import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/clipboard_history.dart';
import '../core/storage/clipboard_store.dart';

class _FileItem {
  final IconData icon;
  final String name;
  final String meta;
  final bool incoming;
  const _FileItem({required this.icon, required this.name, required this.meta, required this.incoming});
}

enum InboxTab { files, clipboard, agents }

class InboxPillContent extends StatelessWidget {
  final InboxTab tab;
  final ValueChanged<InboxTab>? onTabChanged;

  const InboxPillContent({
    super.key,
    required this.tab,
    this.onTabChanged,
  });

  static const List<_TabEntry> _tabs = [
    _TabEntry(InboxTab.files, 'Files'),
    _TabEntry(InboxTab.clipboard, 'Clipboard'),
    _TabEntry(InboxTab.agents, 'Agents'),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = _tabs.indexWhere((t) => t.tab == tab);

    return Padding(
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / 3;

          return SizedBox(
            height: 44,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  left: segmentWidth * activeIndex,
                  width: segmentWidth,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.crimson,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: _tabs.map((entry) {
                    final isActive = entry.tab == tab;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTabChanged?.call(entry.tab),
                        child: Container(
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
                            ),
                            child: Text(entry.label),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TabEntry {
  final InboxTab tab;
  final String label;
  const _TabEntry(this.tab, this.label);
}

class _FileCard extends StatelessWidget {
  final _FileItem item;
  const _FileCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0x0FFFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: AppTheme.textMuted, size: 18),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.meta,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                item.incoming ? Icons.south_west : Icons.north_east,
                size: 20,
                color: item.incoming ? AppTheme.green : AppTheme.crimson,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilesBody extends StatelessWidget {
  const _FilesBody();

  static const List<_FileItem> _items = [
    _FileItem(icon: Icons.description, name: 'Project_Design_Brief.pdf', meta: '2.4 MB \u00B7 5 min ago', incoming: true),
    _FileItem(icon: Icons.image, name: 'Screenshot 2026-06-20.png', meta: '840 KB \u00B7 12 min ago', incoming: false),
    _FileItem(icon: Icons.audio_file, name: 'voice_memo_01.mp3', meta: '850 KB \u00B7 1 hr ago', incoming: true),
    _FileItem(icon: Icons.article, name: 'project_brief.docx', meta: '45 KB \u00B7 3 hrs ago', incoming: true),
    _FileItem(icon: Icons.video_file, name: 'demo_video.mp4', meta: '42 MB \u00B7 5 hrs ago', incoming: false),
    _FileItem(icon: Icons.folder_zip, name: 'assets_archive_final.zip', meta: '120 MB \u00B7 1 day ago', incoming: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      itemCount: _items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _FileCard(item: _items[index]),
    );
  }
}

const _dayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

String _formatCardDate(DateTime dt) {
  final twoDigits = (int n) => n.toString().padLeft(2, '0');
  final dayName = _dayNames[dt.weekday - 1];
  final time = '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}';
  return '$dayName ${twoDigits(dt.day)}/${twoDigits(dt.month)} - $time';
}

class _ClipboardCard extends StatelessWidget {
  final ClipboardEntry entry;
  const _ClipboardCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isPhoneToPc = entry.direction == ClipDirection.phoneToPC;
    return GestureDetector(
      onLongPress: () {
        final id = entry.id;
        if (id != null) ClipboardHistory.instance.remove(id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isPhoneToPc ? Icons.phone_android : Icons.computer,
                size: 18,
                color: isPhoneToPc ? AppTheme.crimson : AppTheme.green,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatCardDate(entry.timestamp),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClipboardBody extends StatelessWidget {
  const _ClipboardBody();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ClipboardHistory.instance,
      builder: (context, _) {
        final entries = ClipboardHistory.instance.entries;
        if (entries.isEmpty) {
          return const Center(
            child: Text(
              'No clipboard history yet',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ClipboardCard(entry: entry),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GestureDetector(
                onTap: () => ClipboardHistory.instance.clear(),
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.crimson.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.crimson.withAlpha(80)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.crimson,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AgentItem {
  final IconData icon;
  final String name;
  final String time;
  final String action;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;
  const _AgentItem({required this.icon, required this.name, required this.time, required this.action, this.onApprove, this.onDeny});
}

class _AgentCard extends StatelessWidget {
  final _AgentItem item;
  const _AgentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0x0FFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, color: AppTheme.textPrimary, size: 16),
                    ),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textDim,
                    letterSpacing: 0.8,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.action,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: item.onApprove,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.green, Color(0xFF1F8A0C)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Approve',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.background,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: item.onDeny,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.cardActiveGlow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Deny',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentsBody extends StatelessWidget {
  const _AgentsBody();

  static const List<_AgentItem> _items = [
    _AgentItem(icon: Icons.terminal, name: 'Zed', time: 'just now', action: 'wants to run a terminal command: rm -rf build/'),
    _AgentItem(icon: Icons.code, name: 'OpenCode', time: '5m ago', action: 'requests read access to your /Documents folder'),
    _AgentItem(icon: Icons.language, name: 'BrowserBot', time: '12m ago', action: 'wants to open https://github.com in a new tab'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      itemCount: _items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _AgentCard(item: _items[index]),
    );
  }
}

class InboxBody extends StatelessWidget {
  final InboxTab tab;

  const InboxBody({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case InboxTab.files:
        return const _FilesBody();
      case InboxTab.clipboard:
        return const _ClipboardBody();
      case InboxTab.agents:
        return const _AgentsBody();
    }
  }
}
