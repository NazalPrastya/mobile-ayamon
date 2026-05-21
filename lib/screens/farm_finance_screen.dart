import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'farm_list_screen.dart';
import '../models/farm_model.dart';
import '../services/farm_service.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class _Expense {
  final String id;
  final String date;
  final String category;
  final double amount;
  final String note;
  const _Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.note,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class FarmFinanceScreen extends StatefulWidget {
  final Farm farm;
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;
  final bool embedded;

  const FarmFinanceScreen({
    super.key,
    required this.farm,
    required this.selectedNavIndex,
    required this.onNavTap,
    this.embedded = false,
  });

  @override
  State<FarmFinanceScreen> createState() => _FarmFinanceScreenState();
}

class _FarmFinanceScreenState extends State<FarmFinanceScreen> {
  int _tab = 0; // 0=Pengaturan 1=Pengeluaran 2=Ringkasan

  // ── Pengaturan state ──
  bool _settingLoading = true;
  bool _settingSaving = false;
  String? _settingError;
  FarmModel? _farmModel;

  final _jumlahAyamCtrl = TextEditingController();
  final _modalCtrl = TextEditingController();
  final _hargaJualCtrl = TextEditingController();
  final _biayaPakanCtrl = TextEditingController();
  final _biayaOpsCtrl = TextEditingController();
  final _targetHenDayCtrl = TextEditingController();

  // ── Pengeluaran state ──
  DateTime _expDate = DateTime.now();
  String _expCategory = 'Pakan';
  final _expAmountCtrl = TextEditingController(text: '0');
  final _expNoteCtrl = TextEditingController();

  final List<_Expense> _expenses = [
    _Expense(
      id: '1',
      date: '05-01',
      category: 'Tenaga Kerja',
      amount: 3500000.0,
      note: 'Gaji bul',
    ),
    _Expense(
      id: '2',
      date: '05-03',
      category: 'Obat/Vitamin',
      amount: 450000.0,
      note: 'Suplem minggu',
    ),
    _Expense(
      id: '3',
      date: '05-05',
      category: 'Utilitas',
      amount: 200000.0,
      note: 'Listrik',
    ),
  ];

  final List<String> _categories = [
    'Pakan',
    'Tenaga Kerja',
    'Obat/Vitamin',
    'Utilitas',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadFarmDetail();
  }

  Future<void> _loadFarmDetail() async {
    setState(() {
      _settingLoading = true;
      _settingError = null;
    });
    final (model, error) = await FarmService.instance.getFarm(widget.farm.id);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _settingError = error;
        _settingLoading = false;
      });
      return;
    }
    _farmModel = model;
    _jumlahAyamCtrl.text = _formatThousands(model!.chickenCount.toString());
    _modalCtrl.text = _formatThousands(
      double.tryParse(model.capital)?.toStringAsFixed(0) ?? '0',
    );
    _hargaJualCtrl.text = _formatThousands(
      double.tryParse(model.priceSell)?.toStringAsFixed(0) ?? '0',
    );
    _biayaPakanCtrl.text = _formatThousands(
      double.tryParse(model.priceFeed)?.toStringAsFixed(0) ?? '0',
    );
    _biayaOpsCtrl.text = _formatThousands(
      double.tryParse(model.priceOps)?.toStringAsFixed(0) ?? '0',
    );
    _targetHenDayCtrl.text = _formatThousands(model.eggTarget.toString());
    setState(() => _settingLoading = false);
  }

  @override
  void dispose() {
    _jumlahAyamCtrl.dispose();
    _modalCtrl.dispose();
    _hargaJualCtrl.dispose();
    _biayaPakanCtrl.dispose();
    _biayaOpsCtrl.dispose();
    _targetHenDayCtrl.dispose();
    _expAmountCtrl.dispose();
    _expNoteCtrl.dispose();
    super.dispose();
  }

  String _formatThousands(String numStr) {
    final digits = numStr.replaceAll('.', '');
    if (digits.isEmpty) return '';
    final buf = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(digits[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatRp(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final dateStr =
        '${days[now.weekday - 1]}, ${now.day} ${months[now.month]} ${now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: widget.embedded ? null : _buildAppBar(dateStr),
      bottomNavigationBar: widget.embedded ? null : _buildBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Keuangan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Modal, pengeluaran & profitabilitas',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 20),
            if (_tab == 0) _buildPengaturan(),
            if (_tab == 1) _buildPengeluaran(),
            if (_tab == 2) _buildRingkasan(),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(String dateStr) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(62),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/logo-single.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Ayamon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                dateStr,
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tabs ────────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    final labels = ['Pengaturan', 'Pengeluaran', 'Ringkasan'];
    return Row(
      children: List.generate(labels.length, (i) {
        final selected = _tab == i;
        return GestureDetector(
          onTap: () => setState(() => _tab = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFF6B00) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? const Color(0xFFFF6B00)
                    : const Color(0xFFE0E0E0),
              ),
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF888888),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _savePengaturan() async {
    if (_farmModel == null) return;
    setState(() => _settingSaving = true);
    final (_, error) = await FarmService.instance.updateFarm(widget.farm.id, {
      'name': _farmModel!.name,
      'location': _farmModel!.location ?? '',
      'periode': _farmModel!.periode,
      'chicken_count':
          int.tryParse(_jumlahAyamCtrl.text.trim().replaceAll('.', '')) ?? 0,
      'capital':
          double.tryParse(_modalCtrl.text.trim().replaceAll('.', '')) ?? 0,
      'price_sell':
          double.tryParse(_hargaJualCtrl.text.trim().replaceAll('.', '')) ?? 0,
      'price_feed':
          double.tryParse(_biayaPakanCtrl.text.trim().replaceAll('.', '')) ?? 0,
      'price_ops':
          double.tryParse(_biayaOpsCtrl.text.trim().replaceAll('.', '')) ?? 0,
      'egg_target':
          int.tryParse(_targetHenDayCtrl.text.trim().replaceAll('.', '')) ?? 0,
    });
    if (!mounted) return;
    setState(() => _settingSaving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan disimpan!'),
          backgroundColor: Color(0xFFFF6B00),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadFarmDetail();
    }
  }

  // ─── Pengaturan ──────────────────────────────────────────────────────────────
  Widget _buildPengaturan() {
    if (_settingLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
        ),
      );
    }
    if (_settingError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _settingError!,
                style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadFarmDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    return _card([
      _sectionHeader(Icons.radio_button_checked_outlined, 'Pengaturan Usaha'),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _settingField(_jumlahAyamCtrl, 'Jumlah Ayam (ekor)', false),
          ),
          const SizedBox(width: 12),
          Expanded(child: _settingField(_modalCtrl, 'Modal Awal (Rp)', false)),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _settingField(_hargaJualCtrl, 'Harga Jual (Rp/kg)', false),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _settingField(_biayaPakanCtrl, 'Biaya Pakan (Rp/kg)', false),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _settingField(
              _biayaOpsCtrl,
              'Biaya Operasional/bln (Rp)',
              false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _settingField(
              _targetHenDayCtrl,
              'Target Hen-day (%)',
              false,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _settingSaving ? null : _savePengaturan,
          icon: _settingSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save_outlined, color: Colors.white, size: 18),
          label: Text(
            _settingSaving ? 'Menyimpan...' : 'Simpan Pengaturan',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B00),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _settingField(TextEditingController ctrl, String label, bool decimal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [_ThousandSeparatorFormatter()],
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  // ─── Pengeluaran ─────────────────────────────────────────────────────────────
  Widget _buildPengeluaran() {
    final total = _expenses.fold(0.0, (sum, e) => sum + e.amount);

    return Column(
      children: [
        // Form card
        _card([
          _sectionHeader(Icons.attach_money_outlined, 'Tambah Pengeluaran'),
          const SizedBox(height: 16),
          Row(
            children: [
              // Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _expDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          builder: (c, child) => Theme(
                            data: Theme.of(c).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFFFF6B00),
                                onPrimary: Colors.white,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() => _expDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(_expDate),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Color(0xFF888888),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _expCategory,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1A1A1A),
                          ),
                          items: _categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _expCategory = v);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jumlah (Rp)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _expAmountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keterangan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _expNoteCtrl,
                      decoration: InputDecoration(
                        hintText: 'opsional',
                        hintStyle: const TextStyle(
                          color: Color(0xFFBBBBBB),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                final amount = double.tryParse(_expAmountCtrl.text.trim()) ?? 0;
                if (amount <= 0) return;
                setState(() {
                  _expenses.insert(
                    0,
                    _Expense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      date:
                          '${_expDate.month.toString().padLeft(2, '0')}-${_expDate.day.toString().padLeft(2, '0')}',
                      category: _expCategory,
                      amount: amount,
                      note: _expNoteCtrl.text.trim(),
                    ),
                  );
                  _expAmountCtrl.text = '0';
                  _expNoteCtrl.clear();
                });
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text(
                'Tambah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        // History card
        _card([
          _sectionHeader(Icons.description_outlined, 'Riwayat Pengeluaran'),
          const SizedBox(height: 14),
          // Header row
          const Row(
            children: [
              _ColHead('Tgl', flex: 2),
              _ColHead('Kategori', flex: 4),
              _ColHead('Jumlah', flex: 4),
              _ColHead('Ket', flex: 3),
            ],
          ),
          const Divider(height: 12, color: Color(0xFFF0F0F0)),
          ..._expenses.asMap().entries.map((e) {
            final idx = e.key;
            final r = e.value;
            final catColor = _categoryColor(r.category);
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        r.date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          r.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: catColor,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        _formatRp(r.amount),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.note,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _expenses.removeAt(idx));
                            },
                            child: const Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Color(0xFFCCCCCC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (idx < _expenses.length - 1)
                  const Divider(height: 16, color: Color(0xFFF5F5F5)),
              ],
            );
          }),
          const Divider(height: 16, color: Color(0xFFE0E0E0)),
          Row(
            children: [
              const Expanded(flex: 2, child: SizedBox()),
              const Expanded(
                flex: 4,
                child: Text(
                  'Total',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 7,
                child: Text(
                  _formatRp(total),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ],
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Pakan':
        return const Color(0xFFE53935);
      case 'Tenaga Kerja':
        return const Color(0xFFFF6B00);
      case 'Obat/Vitamin':
        return const Color(0xFF1E88E5);
      case 'Utilitas':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF8E24AA);
    }
  }

  // ─── Ringkasan ───────────────────────────────────────────────────────────────
  Widget _buildRingkasan() {
    final modal = double.tryParse(_modalCtrl.text.replaceAll('.', '')) ?? 0;
    final hargaJual =
        double.tryParse(_hargaJualCtrl.text.replaceAll('.', '')) ?? 0;
    final biayaPakan =
        double.tryParse(_biayaPakanCtrl.text.replaceAll('.', '')) ?? 0;
    final jumlahAyam =
        double.tryParse(_jumlahAyamCtrl.text.replaceAll('.', '')) ?? 0;

    // dummy: pendapatan dari 7 hari x 800 telur x harga
    const totalEggs = 5517.0; // 7 hari
    const avgWeightPerEgg = 0.062; // kg
    final totalPendapatan = totalEggs * avgWeightPerEgg * hargaJual;

    // biaya pakan otomatis: jumlah ayam * 0.12 kg/hari * 7 hari * harga
    final totalFeedCost = jumlahAyam * 0.12 * 7 * biayaPakan;

    final pengeluaranTercatat = _expenses.fold(0.0, (s, e) => s + e.amount);

    final net = totalPendapatan - pengeluaranTercatat - totalFeedCost - modal;

    // Kategori chart
    final Map<String, double> catTotals = {};
    for (final e in _expenses) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
    }
    // Add feed as category
    catTotals['Pakan'] = (catTotals['Pakan'] ?? 0) + totalFeedCost;

    final grandTotal = catTotals.values.fold(0.0, (a, b) => a + b);

    final List<PieChartSectionData> sections = [];
    catTotals.forEach((cat, val) {
      sections.add(
        PieChartSectionData(
          value: val,
          color: _categoryColor(cat),
          radius: 70,
          showTitle: false,
        ),
      );
    });

    return Column(
      children: [
        // Summary card
        _card([
          _sectionHeader(Icons.monitor_outlined, 'Ringkasan Keuangan'),
          const SizedBox(height: 16),
          _summaryRow(
            'Total Pendapatan',
            _formatRp(totalPendapatan),
            const Color(0xFF43A047),
          ),
          const Divider(height: 20, color: Color(0xFFF5F5F5)),
          _summaryRow(
            'Pengeluaran Tercatat',
            _formatRp(pengeluaranTercatat),
            null,
          ),
          const Divider(height: 20, color: Color(0xFFF5F5F5)),
          _summaryRow('Biaya Pakan (otomatis)', _formatRp(totalFeedCost), null),
          const Divider(height: 20, color: Color(0xFFF5F5F5)),
          _summaryRow('Modal Awal', _formatRp(modal), null),
          const Divider(height: 20, color: Color(0xFFF5F5F5)),
          _summaryRow(
            'Net (setelah modal)',
            _formatRp(net),
            net >= 0 ? const Color(0xFF43A047) : const Color(0xFFE53935),
            bold: true,
          ),
        ]),
        const SizedBox(height: 16),
        // Pie chart card
        if (sections.isNotEmpty)
          _card([
            _sectionHeader(
              Icons.bar_chart_outlined,
              'Pengeluaran per Kategori',
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 55,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: catTotals.entries.map((e) {
                final pct = grandTotal > 0
                    ? (e.value / grandTotal * 100).round()
                    : 0;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _categoryColor(e.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${e.key} $pct%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ]),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    Color? valueColor, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: bold ? const Color(0xFF1A1A1A) : const Color(0xFF666666),
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6B00), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  // ─── Bottom Nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.grid_view_rounded, 'Dashboard'),
      _NavItem(Icons.edit_outlined, 'Input'),
      _NavItem(Icons.attach_money, 'Keuangan'),
      _NavItem(Icons.calendar_today_outlined, 'Jadwal'),
      _NavItem(Icons.bar_chart_outlined, 'Laporan'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == widget.selectedNavIndex;
          return GestureDetector(
            onTap: () => widget.onNavTap(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[i].icon,
                  size: 24,
                  color: selected
                      ? const Color(0xFFFF6B00)
                      : const Color(0xFFAAAAAA),
                ),
                const SizedBox(height: 4),
                Text(
                  items[i].label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? const Color(0xFFFF6B00)
                        : const Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _ColHead extends StatelessWidget {
  final String text;
  final int flex;
  const _ColHead(this.text, {required this.flex});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF888888),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('.', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    if (int.tryParse(digits) == null) return oldValue;
    final buf = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(digits[i]);
      count++;
    }
    final formatted = buf.toString().split('').reversed.join();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
