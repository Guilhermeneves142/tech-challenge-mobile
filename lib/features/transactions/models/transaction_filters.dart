import '../../../core/utils/formatters.dart';
import 'transaction.dart';

class DateRange {
  DateRange(DateTime start, DateTime end)
    : start = DateTime(start.year, start.month, start.day),
      end = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);

  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

class TransactionFilters {
  const TransactionFilters({this.range, this.search = '', this.type});

  final DateRange? range;
  final String search;
  final TransactionType? type;

  String? get searchPrefix {
    final term = normalizeForSearch(search);
    return term.isEmpty ? null : term;
  }

  bool get isEmpty => range == null && type == null && searchPrefix == null;

  TransactionFilters copyWith({
    DateRange? range,
    String? search,
    TransactionType? type,
    bool clearRange = false,
    bool clearType = false,
  }) {
    return TransactionFilters(
      range: clearRange ? null : (range ?? this.range),
      search: search ?? this.search,
      type: clearType ? null : (type ?? this.type),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TransactionFilters &&
      other.range == range &&
      other.type == type &&
      other.searchPrefix == searchPrefix;

  @override
  int get hashCode => Object.hash(range, type, searchPrefix);
}
