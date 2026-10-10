import 'package:flutter/material.dart';

void main() {
  runApp(const SMCJournalApp());
}

class SMCJournalApp extends StatelessWidget {
  const SMCJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jurnal Trading SMC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          secondary: Colors.tealAccent,
        ),
      ),
      home: const TradeListScreen(),
    );
  }
}

class TradeModel {
  final String pair;
  final String type; // BUY / SELL
  final String smcSetup; // BOS, ChoCH, Order Block, Liquidity Sweep
  final String lot;
  final String pips;
  final String note;

  TradeModel({
    required this.pair,
    required this.type,
    required this.smcSetup,
    required this.lot,
    required this.pips,
    required this.note,
  });
}

class TradeListScreen extends StatefulWidget {
  const TradeListScreen({super.key});

  @override
  State<TradeListScreen> createState() => _TradeListScreenState();
}

class _TradeListScreenState extends State<TradeListScreen> {
  final List<TradeModel> _trades = [];

  void _addTrade(TradeModel trade) {
    setState(() {
      _trades.add(trade);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal Trading SMC'),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),
      body: _trades.isEmpty
          data: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.analytics, size: 70, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada jurnal trading.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tekan tombol + di bawah untuk mencatat trade.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _trades.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final trade = _trades[index];
                final isBuy = trade.type == 'BUY';
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isBuy ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      child: Icon(
                        isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isBuy ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                    title: Text(
                      '${trade.pair} - ${trade.type}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Setup: ${trade.smcSetup}', style: const TextStyle(color: Colors.greenAccent)),
                        Text('Lot: ${trade.lot} | Pips/Target: ${trade.pips}', style: const TextStyle(color: Colors.white70)),
                        if (trade.note.isNotEmpty)
                          Text('Catatan: ${trade.note}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newTrade = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTradeScreen()),
          );
          if (newTrade != null && newTrade is TradeModel) {
            _addTrade(newTrade);
          }
        },
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Trade'),
      ),
    );
  }
}

class AddTradeScreen extends StatefulWidget {
  const AddTradeScreen({super.key});

  @override
  State<AddTradeScreen> createState() => _AddTradeScreenState();
}

class _AddTradeScreenState extends State<AddTradeScreen> {
  final _pairController = TextEditingController();
  final _lotController = TextEditingController();
  final _pipsController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedType = 'BUY';
  String _selectedSetup = 'Order Block (OB)';

  final List<String> _smcSetups = [
    'Order Block (OB)',
    'Break of Structure (BOS)',
    'Change of Character (ChoCH)',
    'Liquidity Sweep',
    'Mitigation Block',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Trade SMC Baru'),
        backgroundColor: Colors.black54,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _pairController,
              decoration: const InputDecoration(
                labelText: 'Pair Mata Uang (Contoh: XAUUSD / EURUSD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Tipe Posisi: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('BUY'),
                  selected: _selectedType == 'BUY',
                  selectedColor: Colors.green,
                  onSelected: (selected) {
                    setState(() => _selectedType = 'BUY');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('SELL'),
                  selected: _selectedType == 'SELL',
                  selectedColor: Colors.red,
                  onSelected: (selected) {
                    setState(() => _selectedType = 'SELL');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSetup,
              decoration: const InputDecoration(
                labelText: 'Strategi / Konfirmasi SMC',
                border: OutlineInputBorder(),
              ),
              items: _smcSetups.map((setup) {
                return DropdownMenuItem(value: setup, child: Text(setup));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSetup = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lotController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ukuran Lot (Contoh: 0.10)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pipsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target / Risk Reward (Contoh: 1:3 / 50 Pips)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan / Alasan Entry',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                if (_pairController.text.isEmpty) return;
                final trade = TradeModel(
                  pair: _pairController.text.toUpperCase(),
                  type: _selectedType,
                  smcSetup: _selectedSetup,
                  lot: _lotController.text.isEmpty ? '0.01' : _lotController.text,
                  pips: _pipsController.text.isEmpty ? '-' : _pipsController.text,
                  note: _noteController.text,
                );
                Navigator.pop(context, trade);
              },
              child: const Text('Simpan Jurnal Trade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
