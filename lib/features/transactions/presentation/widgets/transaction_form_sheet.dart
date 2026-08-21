import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/formatters.dart';
import '../../models/transaction.dart';
import 'transaction_tile.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import './transaction_toggle.dart';

class TransactionFormResult {
  const TransactionFormResult({
    required this.transaction,
    this.receiptFile,
  });

  final TransactionModel transaction;
  final File? receiptFile;
}

/// Abre o formulário de nova transação (ou edição, se [transaction] vier).
///
/// Devolve a transação preenchida — quem salva é a tela, que tem acesso ao
/// provider. Assim o formulário não depende do estado global e fica testável.
Future<TransactionFormResult?> showTransactionFormSheet(
  BuildContext context, {
  required String userId,
  TransactionModel? transaction,
}) {
  return showShadDialog<TransactionFormResult?>(
    context: context,
    builder: (context) =>
        _TransactionFormSheet(
          userId: userId,
          transaction: transaction,
        ),
  );
}

class _TransactionFormSheet extends StatefulWidget {
  const _TransactionFormSheet({required this.userId, this.transaction});

  final String userId;
  final TransactionModel? transaction;

  @override
  State<_TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<_TransactionFormSheet> {
  final _formKey = GlobalKey<ShadFormState>();
  File? _receiptFile;

  late TransactionType _type;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? TransactionType.despesa; 
  }

  /// Hora original da transação: o date picker só escolhe o dia, então
  /// preservamos o horário (que aparece na listagem).
  late final DateTime _baseDate = widget.transaction?.date ?? DateTime.now();

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _receiptFile = File(image.path);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final values = _formKey.currentState!.value;
    final pickedDate = values['date'] as DateTime;

    Navigator.of(context).pop(
      TransactionFormResult(
        transaction: TransactionModel(
          id: widget.transaction?.id ?? '',
          userId: widget.userId,
          description: (values['description'] as String).trim(),
          category: values['category'] as TransactionCategory,
          type: _type,
          amount: parseAmount(values['amount'] as String)!,
          date: DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _baseDate.hour,
            _baseDate.minute,
          ),
          receiptUrl: widget.transaction?.receiptUrl,
        ),
        receiptFile: _receiptFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.transaction;
    final isEditing = existing != null;

    return ShadDialog(
      radius: BorderRadius.circular(20),
      removeBorderRadiusWhenTiny: false,
      constraints: const BoxConstraints(maxWidth: 380),
      scrollable: true,
      gap: 1,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      useSafeArea: false,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(isEditing ? 'Editar transação' : 'Nova transação'),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ShadButton.outline(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 8), // gap
            Expanded(
              child: ShadButton(
                onPressed: _submit,
                child: Text(isEditing ? 'Salvar' : 'Adicionar'),
              ),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child:        
        ShadForm(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  TransactionToggle(
                    value: _type,
                    onChanged: (type) => setState(() => _type = type),
                  ),
                ],
              ),
              ShadInputFormField(
                id: 'description',
                label: const Text('Descrição'),
                placeholder: const Text('Ex.: Supermercado'),
                initialValue: existing?.description,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value.trim().length < 3) {
                    return 'Descreva com pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
              ShadInputFormField(
                id: 'amount',
                label: const Text('Valor'),
                placeholder: const Text('0,00'),
                initialValue: existing?.amount
                    .toStringAsFixed(2)
                    .replaceAll('.', ','),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => parseAmount(value) == null
                    ? 'Informe um valor válido'
                    : null,
              ),
             LayoutBuilder(
              builder: (context, constraints) {
                return ShadSelectFormField<TransactionCategory>(
                  id: 'category',
                  label: const Text('Categoria'),
                  initialValue: existing?.category ?? TransactionCategory.outros,
                  placeholder: const Text('Selecione'),
                  minWidth: constraints.maxWidth, 
                  selectedOptionBuilder: (context, value) => Text(value.label),
                  options: [
                    for (final category in TransactionCategory.values)
                      ShadOption(
                        value: category,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(category.icon, size: 15),
                            const SizedBox(width: 8),
                            Text(category.label),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12), 
                  child: ShadDatePickerFormField(
                    id: 'date',
                    label: const Text('Data'),
                    initialValue: _baseDate,
                    formatDate: formatShortDate,
                    width: constraints.maxWidth,
                    validator: (value) => value == null ? 'Escolha a data' : null,
                  ),
                );
              },
            ),
              ShadButton.outline(
                onPressed: _pickReceipt,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.file_upload_outlined),
                    const SizedBox(width: 8),
                    Text(
                      _receiptFile != null
                          ? 'Recibo selecionado'
                          : 'Adicionar recibo',
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
