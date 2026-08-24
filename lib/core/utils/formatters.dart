import 'package:intl/intl.dart';

/// Helpers de formatação/parse em pt-BR (moeda e data).
///
/// Aula (JS -> Dart): o `intl` faz o papel do `Intl.NumberFormat` /
/// `Intl.DateTimeFormat` do navegador. Os símbolos de data do locale pt_BR são
/// carregados pelo `GlobalMaterialLocalizations` registrado em `app.dart`.

final NumberFormat _currency = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: r'R$',
);

final DateFormat _dayMonth = DateFormat('dd MMM', 'pt_BR');
final DateFormat _time = DateFormat('HH:mm', 'pt_BR');
final DateFormat _shortDate = DateFormat('dd/MM/yyyy', 'pt_BR');
final DateFormat _monthAbbrev = DateFormat('MMM', 'pt_BR');
final DateFormat _monthYear = DateFormat('MMM/yy', 'pt_BR');

/// Mês abreviado e capitalizado: `Jan`, `Fev`… (rótulo do gráfico de evolução).
String formatMonthAbbrev(DateTime date) {
  final month = _monthAbbrev.format(date).replaceAll('.', '');
  if (month.isEmpty) return month;
  return '${month[0].toUpperCase()}${month.substring(1)}';
}

/// Mês/ano curto e capitalizado: `Mar/25`, `Ago/26`… (eixo X do gráfico).
String formatMonthYear(DateTime date) {
  final value = _monthYear.format(date).replaceAll('.', '');
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}

/// `1234.5` -> `R$ 1.234,50`
String formatCurrency(double value) => _currency.format(value);

/// `-452.1` -> `- R$ 452,10` (sinal separado do valor, como no design).
String formatSignedCurrency(double signedValue) {
  final sign = signedValue < 0 ? '-' : '+';
  return '$sign ${_currency.format(signedValue.abs())}';
}

/// `01/10/2023`
String formatShortDate(DateTime date) => _shortDate.format(date);

/// Data da transação como na listagem: `Hoje, 14:30`, `Ontem, 09:15`,
/// `11 Mai, 18:45`. [now] existe para deixar o formato testável.
String formatTransactionDate(DateTime date, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final day = DateTime(date.year, date.month, date.day);
  final today = DateTime(reference.year, reference.month, reference.day);
  final daysAgo = today.difference(day).inDays;
  final time = _time.format(date);

  if (daysAgo == 0) return 'Hoje, $time';
  if (daysAgo == 1) return 'Ontem, $time';

  // pt_BR devolve "11 mai." — tiramos o ponto e subimos a inicial do mês.
  final parts = _dayMonth.format(date).replaceAll('.', '').split(' ');
  final month = parts.last;
  final capitalized = month.isEmpty
      ? month
      : '${month[0].toUpperCase()}${month.substring(1)}';
  return '${parts.first} $capitalized, $time';
}

/// Converte o que o usuário digitou no campo de valor para `double`.
///
/// Aceita os formatos que um brasileiro digita de verdade: `1050,90`,
/// `1.050,90`, `1050.90` e `1050`. Devolve `null` quando não dá para
/// interpretar ou quando o valor não é positivo.
double? parseAmount(String raw) {
  var value = raw.trim().replaceAll(RegExp(r'[^\d,.]'), '');
  if (value.isEmpty) return null;

  final hasComma = value.contains(',');
  final hasDot = value.contains('.');

  if (hasComma) {
    // Com vírgula, o ponto (se houver) só pode ser separador de milhar.
    value = value.replaceAll('.', '').replaceAll(',', '.');
  } else if (hasDot) {
    // Só ponto é ambíguo: `1.050` é milhar, `1050.90` é decimal. Tratamos
    // como milhar quando todos os grupos depois do 1º ponto têm 3 dígitos.
    final groups = value.split('.');
    final isThousandSeparator = groups
        .skip(1)
        .every((group) => group.length == 3);
    if (isThousandSeparator) value = value.replaceAll('.', '');
  }

  final parsed = double.tryParse(value);
  if (parsed == null || parsed <= 0) return null;
  return parsed;
}

/// Normaliza texto para busca no Firestore: minúsculas e sem acentos.
///
/// É gravado no campo `descriptionLower` de cada transação e aplicado também
/// ao termo digitado, para que "salario" encontre "Salário Mensal".
String normalizeForSearch(String value) {
  const accented = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const plain = 'aaaaaeeeeiiiiooooouuuucn';

  final buffer = StringBuffer();
  for (final rune in value.trim().toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = accented.indexOf(char);
    buffer.write(index == -1 ? char : plain[index]);
  }
  return buffer.toString();
}
