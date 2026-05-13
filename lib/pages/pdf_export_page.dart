import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_code_app/components/active_event_banner.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

/// Multi-select collection page for PDF export.
/// Tapping "Select" enters selection mode; a count badge and export button
/// appear at the bottom. Supports 1-per-page detailed (story 6-2) and
/// 2×2 synthetic (story 6-3) layouts.
class PdfExportPage extends StatefulWidget {
  /// Creates the export page.
  const PdfExportPage({super.key});

  @override
  State<PdfExportPage> createState() => _PdfExportPageState();
}

class _PdfExportPageState extends State<PdfExportPage> {
  bool _selectMode = false;
  bool _generating = false;
  bool _layout2x2 = false;

  final Set<int> _selected = {};
  late Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = QRDatabase().watchAllItems();
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _generate(List<Map<String, dynamic>> allItems) async {
    if (_selected.isEmpty) {
      final lang = LangProvider.getMap('pdf_export');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang['no_selection'] as String)),
      );
      return;
    }

    setState(() => _generating = true);
    try {
      final items = allItems
          .where((item) {
            final data = item['data'] as Map<String, dynamic>;
            final id = data['id'];
            return id != null && _selected.contains(id as int);
          })
          .toList();

      final pdfBytes =
          _layout2x2 ? await _build2x2Pdf(items) : await _build1ppPdf(items);

      if (!mounted) return;
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'ezqr_export.pdf',
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  static String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } on Exception catch (_) {
      return '';
    }
  }

  // ---------------------------------------------------------------------------
  // 1-per-page detailed PDF (story 6-2)
  // ---------------------------------------------------------------------------
  static Future<Uint8List> _build1ppPdf(
    List<Map<String, dynamic>> items,
  ) async {
    final doc = pw.Document();
    final lang = LangProvider.getMap('pdf_export');
    for (final item in items) {
      final data = item['data'] as Map<String, dynamic>;
      String s(String k) => (data[k] as String?) ?? '';

      pw.Widget? photoWidget;
      final photoStr = s('photo');
      if (photoStr.startsWith('data:image')) {
        try {
          final bytes = base64Decode(photoStr.split(',').last);
          photoWidget = pw.Image(
            pw.MemoryImage(bytes),
            width: 150,
            height: 150,
            fit: pw.BoxFit.cover,
          );
        } on Exception catch (_) {}
      }

      final captureLabel = () {
        final d = _formatDate(s('captured_at'));
        if (d.isEmpty) return '';
        final tpl = lang['captured_on'] as String;
        return tpl.replaceFirst('%s', d);
      }();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (photoWidget != null) ...[
                    photoWidget,
                    pw.SizedBox(width: 20),
                  ],
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${s("prenom")} ${s("nom")}'.trim(),
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (s('job').isNotEmpty)
                          pw.Text(
                            s('job'),
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                        if (s('org').isNotEmpty)
                          pw.Text(
                            s('org'),
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(),
              for (final entry in [
                ['Tél. (pro)', s('tel_work')],
                ['Tél. (perso)', s('tel_home')],
                ['Email', s('email')],
                ['Adresse pro', s('adr_work')],
                ['Adresse perso', s('adr_home')],
              ])
                if (entry[1].isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            entry[0],
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Expanded(child: pw.Text(entry[1])),
                      ],
                    ),
                  ),
              pw.Spacer(),
              if (captureLabel.isNotEmpty)
                pw.Text(
                  captureLabel,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return doc.save();
  }

  // ---------------------------------------------------------------------------
  // 2×2 per page synthetic PDF (story 6-3)
  // ---------------------------------------------------------------------------
  static Future<Uint8List> _build2x2Pdf(
    List<Map<String, dynamic>> items,
  ) async {
    final doc = pw.Document();
    const perPage = 4;

    for (var i = 0; i < items.length; i += perPage) {
      final chunk = items.skip(i).take(perPage).toList();
      while (chunk.length < perPage) {
        chunk.add(<String, dynamic>{
          'type': 'empty',
          'data': <String, dynamic>{},
        });
      }

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (ctx) => pw.Column(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Expanded(child: _buildCell(chunk[0])),
                    pw.SizedBox(width: 12),
                    pw.Expanded(child: _buildCell(chunk[1])),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Expanded(child: _buildCell(chunk[2])),
                    pw.SizedBox(width: 12),
                    pw.Expanded(child: _buildCell(chunk[3])),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Text(
                'EZQRContact export',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return doc.save();
  }

  static pw.Widget _buildCell(Map<String, dynamic> item) {
    final data = item['data'] as Map<String, dynamic>;
    String s(String k) => (data[k] as String?) ?? '';

    if (s('nom').isEmpty && s('prenom').isEmpty) {
      return pw.Container();
    }

    pw.Widget? photoWidget;
    final photoStr = s('photo');
    if (photoStr.startsWith('data:image')) {
      try {
        final bytes = base64Decode(photoStr.split(',').last);
        photoWidget = pw.Image(
          pw.MemoryImage(bytes),
          width: 60,
          height: 60,
          fit: pw.BoxFit.cover,
        );
      } on Exception catch (_) {}
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              if (photoWidget != null) ...[
                photoWidget,
                pw.SizedBox(width: 8),
              ],
              pw.Expanded(
                child: pw.Text(
                  '${s("prenom")} ${s("nom")}'.trim(),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          if (s('org').isNotEmpty)
            pw.Text(s('org'), style: const pw.TextStyle(fontSize: 10)),
          if (s('job').isNotEmpty)
            pw.Text(s('job'), style: const pw.TextStyle(fontSize: 10)),
          pw.Spacer(),
          if (s('tel_work').isNotEmpty)
            pw.Text(
              s('tel_work'),
              style: const pw.TextStyle(fontSize: 10),
            ),
          if (s('email').isNotEmpty)
            pw.Text(
              s('email'),
              style: const pw.TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.getMap('pdf_export');

    return Scaffold(
      backgroundColor: currentColors['bg'],
      appBar: AppBarCustom(lang['title'] as String),
      body: Column(
        children: [
          const ActiveEventBanner(),
          // toolbar
          Container(
            color: currentColors['surface'],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (!_selectMode) ...[
                  ElevatedButton.icon(
                    onPressed: () => setState(() {
                      _selectMode = true;
                      _selected.clear();
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentColors['button-color'],
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.checklist),
                    label: Text(lang['select_mode'] as String),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: () => setState(() {
                      _selectMode = false;
                      _selected.clear();
                    }),
                    child: Text(lang['cancel_select'] as String),
                  ),
                  const Spacer(),
                  Text(
                    (lang['selected_count'] as String)
                        .replaceFirst('%s', '${_selected.length}'),
                    style: TextStyle(color: currentColors['text']),
                  ),
                ],
              ],
            ),
          ),
          // list
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _stream,
              builder: (context, snapshot) {
                final items = (snapshot.data ?? [])
                    .where((it) => it['type'] == 'vcard')
                    .toList();

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      lang['no_contacts'] as String,
                      style: TextStyle(color: currentColors['text']),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final data =
                        items[i]['data'] as Map<String, dynamic>;
                    final id = data['id'] as int?;
                    final isSelected =
                        id != null && _selected.contains(id);
                    final prenom = (data['prenom'] as String?) ?? '';
                    final nom = (data['nom'] as String?) ?? '';

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: _selectMode && id != null
                          ? (_) => _toggleSelect(id)
                          : null,
                      title: Text(
                        '$prenom $nom'.trim(),
                        style: TextStyle(color: currentColors['text']),
                      ),
                      subtitle: (data['org'] as String?)?.isNotEmpty == true
                          ? Text(
                              data['org'] as String,
                              style: TextStyle(
                                color: currentColors['text-muted'],
                              ),
                            )
                          : null,
                      activeColor: currentColors['button-color'],
                      checkColor: Colors.white,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectMode && _selected.isNotEmpty
          ? _buildExportBar(lang)
          : const Navbar(currentRoute: '/collection'),
    );
  }

  Widget _buildExportBar(Map<String, dynamic> lang) {
    return Container(
      color: currentColors['surface'],
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _LayoutChip(
                  label: lang['layout_1pp'] as String,
                  selected: !_layout2x2,
                  onTap: () => setState(() => _layout2x2 = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LayoutChip(
                  label: lang['layout_2x2'] as String,
                  selected: _layout2x2,
                  onTap: () => setState(() => _layout2x2 = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _stream,
            builder: (ctx, snap) {
              final allItems = snap.data ?? [];
              return ElevatedButton.icon(
                onPressed: _generating
                    ? null
                    : () => unawaited(_generate(allItems)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentColors['button-color'],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: _generating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(
                  _generating
                      ? lang['generating'] as String
                      : (lang['export_button'] as String)
                          .replaceFirst('%s', '${_selected.length}'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LayoutChip extends StatelessWidget {
  const _LayoutChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? currentColors['button-color']
              : currentColors['surface'],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: currentColors['button-color']!,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : currentColors['text'],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
