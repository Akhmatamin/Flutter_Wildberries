import 'package:intl/intl.dart';

final _numberFormat = NumberFormat.decimalPattern('ru');

String formatPrice(num price) => '${_numberFormat.format(price)} сом';
