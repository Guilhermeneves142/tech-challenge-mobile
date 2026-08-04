import 'package:finance_app_mobile/features/transactions/data/category_api.dart';
import 'package:finance_app_mobile/features/transactions/models/category.dart';
import 'package:finance_app_mobile/features/transactions/models/transaction.dart';
import 'package:finance_app_mobile/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TransactionModal extends StatefulWidget {
  final Transaction? transaction;
  const TransactionModal({super.key, this.transaction});

  @override
  State<TransactionModal> createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  final _formKey = GlobalKey<ShadFormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final CategoryApi _categoryApi = CategoryApi();
  final ShadPopoverController _dateController = ShadPopoverController();

  List<Category> _categories = [];

  bool _loadingCategories = true;

  String? _categoryError;

  String _type = 'credit';
  String _category = '';

  DateTime _date = DateTime.now();

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (isEditing) {
      final transaction = widget.transaction!;

      _descriptionController.text = transaction.description;
      _amountController.text = transaction.amount.toString();

      _category = transaction.category;
      _type = transaction.type;
      _date = DateTime.parse(transaction.date);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryApi.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _categoryError = 'Não foi possível carregar categorias.';
        _loadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<TransactionProvider>();

    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    final transaction = Transaction(
      id: widget.transaction?.id,
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      category: _category,
      type: _type,
      date: _date.toIso8601String(),
    );

    final success = isEditing
        ? await provider.update(transaction)
        : await provider.create(transaction);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, transaction);
    }
  }

  String get formattedDate =>
      '${_date.day.toString().padLeft(2, '0')}/'
      '${_date.month.toString().padLeft(2, '0')}/'
      '${_date.year}';

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF588157),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _typeOption('credit', 'Receita')),
          Expanded(child: _typeOption('debit', 'Despesa')),
        ],
      ),
    );
  }

  Widget _typeOption(String value, String label) {
    final isSelected = _type == value;

    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 188, 204, 161) : null,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF588157) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(24, 16, 16, 0),

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isEditing ? 'Editar Transação' : 'Nova Transação',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),

      content: SizedBox(
        width: 360,

        child: ShadForm(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              _buildTypeSelector(),

              ShadInputFormField(
                id: 'description',
                controller: _descriptionController,
                label: const Text('Descrição'),
                placeholder: const Text('Descrição da transação'),
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Informe a descrição';
                  }
                  return null;
                },
              ),

              ShadInputFormField(
                id: 'amount',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                label: const Text('Valor'),
                placeholder: const Text('Valor da transação'),
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Informe o valor';
                  }

                  return null;
                },
              ),

              /// CATEGORIA
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Categoria'),
                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ShadSelect<String>(
                      initialValue: _category.isEmpty ? null : _category,
                      placeholder: const Text('Selecione a categoria'),
                      options: _categories.map((category) {
                        return ShadOption<String>(
                          value: category.id,
                          child: Text(category.label),
                        );
                      }).toList(),

                      selectedOptionBuilder: (context, value) {
                        final category = _categories.firstWhere(
                          (item) => item.id == value,
                          orElse: () => Category(id: '', label: ''),
                        );

                        return Text(category.label);
                      },

                      onChanged: (value) {
                        setState(() {
                          _category = value ?? '';
                        });
                      },
                    ),
                  ),

                  if (_loadingCategories)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Carregando categorias...'),
                    ),

                  if (_categoryError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _categoryError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),

              /// DATA
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Data'),
                  const SizedBox(height: 8),

                  ShadPopover(
                    controller: _dateController,
                    child: GestureDetector(
                      onTap: () {
                        _dateController.show();
                      },

                      child: Container(
                        width: double.infinity,
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: ShadTheme.of(context).colorScheme.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: ShadTheme.of(
                                context,
                              ).colorScheme.mutedForeground,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: ShadTheme.of(
                                  context,
                                ).colorScheme.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    popover: (context) {
                      return Material(
                        child: SizedBox(
                          width: 320,
                          child: ShadCalendar(
                            selected: _date,
                            onChanged: (date) {
                              if (date == null) return;

                              setState(() {
                                _date = date;
                              });
                              _dateController.hide();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              if (provider.errorMessage != null)
                Text(
                  provider.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),

      actions: [
        ShadButton.outline(
          onPressed: provider.isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },

          child: const Text('Cancelar'),
        ),

        ShadButton(
          onPressed: provider.isLoading ? null : _submit,
          child: Text(provider.isLoading ? 'Salvando...' : 'Salvar'),
        ),
      ],
    );
  }
}
