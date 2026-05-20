import 'package:flutter/material.dart';
import '../models/farm_model.dart';
import '../services/farm_service.dart';

class FarmFormScreen extends StatefulWidget {
  /// If [farm] is provided, the form is in edit mode.
  final FarmModel? farm;

  const FarmFormScreen({super.key, this.farm});

  @override
  State<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends State<FarmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _periodeCtrl;
  late final TextEditingController _chickenCountCtrl;
  late final TextEditingController _capitalCtrl;
  late final TextEditingController _priceSellCtrl;
  late final TextEditingController _priceOpsCtrl;
  late final TextEditingController _eggTargetCtrl;

  bool get _isEdit => widget.farm != null;

  @override
  void initState() {
    super.initState();
    final f = widget.farm;
    _nameCtrl = TextEditingController(text: f?.name ?? '');
    _locationCtrl = TextEditingController(text: f?.location ?? '');
    _periodeCtrl = TextEditingController(text: f?.periode ?? '');
    _chickenCountCtrl = TextEditingController(
      text: f != null ? '${f.chickenCount}' : '',
    );
    _capitalCtrl = TextEditingController(text: f != null ? f.capital : '');
    _priceSellCtrl = TextEditingController(text: f != null ? f.priceSell : '');
    _priceOpsCtrl = TextEditingController(text: f != null ? f.priceOps : '');
    _eggTargetCtrl = TextEditingController(
      text: f != null ? '${f.eggTarget}' : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _periodeCtrl.dispose();
    _chickenCountCtrl.dispose();
    _capitalCtrl.dispose();
    _priceSellCtrl.dispose();
    _priceOpsCtrl.dispose();
    _eggTargetCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildPayload() => {
    'name': _nameCtrl.text.trim(),
    'location': _locationCtrl.text.trim(),
    'periode': _periodeCtrl.text.trim(),
    'chicken_count': int.tryParse(_chickenCountCtrl.text.trim()) ?? 0,
    'capital': double.tryParse(_capitalCtrl.text.trim()) ?? 0.0,
    'price_sell': double.tryParse(_priceSellCtrl.text.trim()) ?? 0.0,
    'price_ops': double.tryParse(_priceOpsCtrl.text.trim()) ?? 0.0,
    'egg_target': int.tryParse(_eggTargetCtrl.text.trim()) ?? 0,
  };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    String? error;
    if (_isEdit) {
      final (_, err) = await FarmService.instance.updateFarm(
        widget.farm!.id,
        _buildPayload(),
      );
      error = err;
    } else {
      final (_, err) = await FarmService.instance.createFarm(_buildPayload());
      error = err;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.pop(context, true); // signal success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1A1A1A),
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Peternakan' : 'Tambah Peternakan',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCard([
                _field(
                  controller: _nameCtrl,
                  label: 'Nama Peternakan',
                  hint: 'Contoh: Kandang A',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                _field(
                  controller: _locationCtrl,
                  label: 'Lokasi',
                  hint: 'Contoh: Desa Sukamaju',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                _field(
                  controller: _periodeCtrl,
                  label: 'Periode',
                  hint: 'Contoh: Periode 1 2025',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
              ]),
              const SizedBox(height: 14),
              _buildCard([
                _field(
                  controller: _chickenCountCtrl,
                  label: 'Jumlah Ayam',
                  hint: 'Contoh: 500',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                _field(
                  controller: _eggTargetCtrl,
                  label: 'Target Telur (butir/hari)',
                  hint: 'Contoh: 450',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
              ]),
              const SizedBox(height: 14),
              _buildCard([
                _field(
                  controller: _capitalCtrl,
                  label: 'Modal (Rp)',
                  hint: 'Contoh: 5000000',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                _field(
                  controller: _priceSellCtrl,
                  label: 'Harga Jual Telur (Rp/butir)',
                  hint: 'Contoh: 2000',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                _field(
                  controller: _priceOpsCtrl,
                  label: 'Biaya Operasional/hari (Rp)',
                  hint: 'Contoh: 50000',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
              ]),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isEdit ? 'Simpan Perubahan' : 'Buat Peternakan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Color(0xFF888888), fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
