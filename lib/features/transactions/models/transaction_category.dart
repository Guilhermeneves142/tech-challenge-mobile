/// Categorias usadas no filtro da listagem (valores persistidos no Firestore).
enum TransactionCategory {
  alimentacao('alimentacao', 'Alimentação'),
  transporte('transporte', 'Transporte'),
  moradia('moradia', 'Moradia'),
  lazer('lazer', 'Lazer'),
  saude('saude', 'Saúde'),
  educacao('educacao', 'Educação'),
  salario('salario', 'Salário'),
  outros('outros', 'Outros');

  const TransactionCategory(this.value, this.label);

  final String value;
  final String label;

  static TransactionCategory? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final normalized = raw.trim().toLowerCase();
    for (final category in TransactionCategory.values) {
      if (category.value == normalized ||
          category.label.toLowerCase() == normalized) {
        return category;
      }
    }
    return null;
  }

  static String labelOf(String value) {
    return tryParse(value)?.label ?? value;
  }
}
