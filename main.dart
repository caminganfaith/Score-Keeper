import 'package:flutter/material.dart';

void main() => runApp(const ScorecourtApp());


class ScorecourtApp extends StatelessWidget {
  const ScorecourtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scorecourt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101522),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7A1A),
          brightness: Brightness.dark,
          primary: const Color(0xFFFF7A1A),
          secondary: const Color(0xFF162B4A),
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101522),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
      ),
      home: const ScoreboardPage(),
    );
  }
}

class MatchRecord {
  MatchRecord({required this.teamA, required this.scoreA, required this.teamB,
    required this.scoreB, required this.finishedAt});
  final String teamA;
  final int scoreA;
  final String teamB;
  final int scoreB;
  final DateTime finishedAt;
}


class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});
  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}


class _ScoreboardPageState extends State<ScoreboardPage> {
  int scoreA = 0;
  int scoreB = 0;
  String teamA = 'TEAM A';
  String teamB = 'TEAM B';
  final List<MatchRecord> history = [];

  void _adjustA(int delta) => setState(() => scoreA = (scoreA + delta).clamp(0, 999));
  void _adjustB(int delta) => setState(() => scoreB = (scoreB + delta).clamp(0, 999));
  void _reset() => setState(() { scoreA = 0; scoreB = 0; });

  void _finishGame() {
    if (scoreA == 0 && scoreB == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add scores before finishing the game.')));
      return;
    }
    setState(() {
      history.insert(0, MatchRecord(teamA: teamA, scoreA: scoreA, teamB: teamB,
        scoreB: scoreB, finishedAt: DateTime.now()));
    });
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Game completed'),
      content: Text('$teamA $scoreA  —  $scoreB $teamB'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
    ));
  }

  Future<void> _renameTeam(bool isA) async {
    final controller = TextEditingController(text: isA ? teamA : teamB);
    final name = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Rename ${isA ? 'Team A' : 'Team B'}'),
      content: TextField(controller: controller, autofocus: true, maxLength: 18,
        decoration: const InputDecoration(labelText: 'Team name'),),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save'))],
    ));
    if (name != null && name.isNotEmpty) setState(() { if (isA) { teamA = name; } else { teamB = name; } });
    controller.dispose();
  }

  String _date(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SCORECOURT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        actions: [IconButton(tooltip: 'Match history', icon: const Icon(Icons.history), onPressed: _showHistory)],),
      body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxHeight < 600;
        return Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          const Text('PICKUP BASKETBALL', style: TextStyle(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(child: Row(children: [
            Expanded(child: _teamCard(teamA, scoreA, true, compact)),
            const SizedBox(width: 12),
            Expanded(child: _teamCard(teamB, scoreB, false, compact)),
          ])),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _reset, icon: const Icon(Icons.restart_alt), label: const Text('RESET'), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton.icon(onPressed: _finishGame, icon: const Icon(Icons.flag), label: const Text('FINISH GAME'), style: FilledButton.styleFrom(minimumSize: const Size(0, 48)))),
          ]),
          const SizedBox(height: 10),
          Text('${history.length} completed ${history.length == 1 ? 'game' : 'games'} saved in this session', style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ]));
      })),
    );
  }


  Widget _teamCard(String name, int score, bool isA, bool compact) {
    final accent = isA ? const Color(0xFFFF7A1A) : const Color(0xFF4D83D4);
    return Container(decoration: BoxDecoration(color: const Color(0xFF1B2232), borderRadius: BorderRadius.circular(22), border: Border.all(color: accent.withOpacity(.35))),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 8 : 16),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        InkWell(onTap: () => _renameTeam(isA), borderRadius: BorderRadius.circular(10), child: Padding(padding: const EdgeInsets.all(6), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: accent, fontSize: compact ? 14 : 16, fontWeight: FontWeight.bold, letterSpacing: 1))), const SizedBox(width: 4), const Icon(Icons.edit, size: 14, color: Colors.white38)
        ]))),
        FittedBox(fit: BoxFit.scaleDown, child: Text('$score', style: TextStyle(fontSize: compact ? 84 : 112, fontWeight: FontWeight.w900, height: .95, color: Colors.white))),
        Text('POINTS', style: TextStyle(color: Colors.white38, fontSize: compact ? 10 : 12, letterSpacing: 2)),
        Row(children: [
          Expanded(child: _scoreButton('-1', () => isA ? _adjustA(-1) : _adjustB(-1), outlined: true, compact: compact)),
          const SizedBox(width: 6), Expanded(child: _scoreButton('+1', () => isA ? _adjustA(1) : _adjustB(1), compact: compact)),
        ]),
        Row(children: [
          Expanded(child: _scoreButton('+2', () => isA ? _adjustA(2) : _adjustB(2), compact: compact)),
          const SizedBox(width: 6), Expanded(child: _scoreButton('+3', () => isA ? _adjustA(3) : _adjustB(3), compact: compact)),
        ]),
      ]));
  }

  Widget _scoreButton(String label, VoidCallback onPressed, {bool outlined = false, bool compact = false}) => outlined
    ? OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, compact ? 40 : 48)), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)))
    : FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, compact ? 40 : 48)), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));


  void _showHistory() {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (ctx) => SafeArea(child: Padding(
      padding: const EdgeInsets.all(18), child: SizedBox(height: MediaQuery.of(ctx).size.height * .7, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Expanded(child: Text('MATCH HISTORY', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1))), IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close))]),
        const Divider(),
        Expanded(child: history.isEmpty ? const Center(child: Text('No completed games yet.'))) : ListView.builder(itemCount: history.length, itemBuilder: (_, i) {
          final game = history[i]; return Card(color: const Color(0xFF1B2232), child: ListTile(
            title: Text('${game.teamA}  ${game.scoreA}  —  ${game.scoreB}  ${game.teamB}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_date(game.finishedAt)), leading: const Icon(Icons.sports_basketball, color: Color(0xFFFF7A1A)),
          ));
        }),
      ]))),);
  }
}
