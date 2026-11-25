import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'calculation.dart';

class CalculatorState {
  final String display;
  final String expression;
  final int tabIndex;
  final List<Calculation> history;

  const CalculatorState({
    this.display = "0",
    this.expression = "",
    this.tabIndex = 0,
    this.history = const [],
  });
}

class CalculatorCubit extends Cubit<CalculatorState> {
  final Box box = Hive.box("history");

  String _current = "0";
  String _expression = "";
  double? _firstNumber;
  String? _operator;
  bool _startNew = false;
  int _tabIndex = 0;
  List<Calculation> _history = [];

  CalculatorCubit() : super(const CalculatorState()) {
    for (var item in box.values) {
      _history.add(Calculation.fromMap(item));
    }
    _history = _history.reversed.toList();
    _show();
  }

  void changeTab(int index) {
    _tabIndex = index;
    _show();
  }

  void addDigit(String digit) {
    if (_startNew || _current == "0") {
      if (_operator == null) {
        _expression = "";
      }
      _current = digit;
      _startNew = false;
    } else {
      _current = _current + digit;
    }
    _show();
  }

  void addDot() {
    if (_startNew) {
      _current = "0.";
      _startNew = false;
    } else if (!_current.contains(".")) {
      _current = "$_current.";
    }
    _show();
  }

  void setOperator(String op) {
    if (_operator != null && !_startNew) {
      double result =
          _applyOperator(_firstNumber!, double.parse(_current), _operator!);
      _current = _format(result);
      _firstNumber = result;
    } else {
      _firstNumber = double.parse(_current);
    }

    _operator = op;
    _startNew = true;
    _expression = "${_format(_firstNumber!)} $op";
    _show();
  }

  void calculate() {
    if (_operator == null) {
      return;
    }

    double second = double.parse(_current);
    double result = _applyOperator(_firstNumber!, second, _operator!);
    String formula = "${_format(_firstNumber!)} $_operator ${_format(second)}";

    _firstNumber = null;
    _operator = null;
    _startNew = true;

    if (!result.isFinite) {
      _current = "0";
      _expression = "";
      emit(CalculatorState(
        display: "Error",
        tabIndex: _tabIndex,
        history: _history,
      ));
      return;
    }

    _current = _format(result);
    _expression = "$formula =";

    Calculation entry = Calculation(
      formula: formula,
      result: _current,
      date: DateTime.now(),
    );
    box.add(entry.toMap());
    _history = [entry, ..._history];
    _show();
  }

  void clear() {
    _current = "0";
    _expression = "";
    _firstNumber = null;
    _operator = null;
    _startNew = false;
    _show();
  }

  void toggleSign() {
    _current = _format(double.parse(_current) * -1);
    _show();
  }

  void percent() {
    _current = _format(double.parse(_current) / 100);
    _show();
  }

  Future<void> clearHistory() async {
    await box.clear();
    _history = [];
    _show();
  }

  void _show() {
    emit(CalculatorState(
      display: _current,
      expression: _expression,
      tabIndex: _tabIndex,
      history: _history,
    ));
  }

  double _applyOperator(double first, double second, String op) {
    switch (op) {
      case "+":
        return first + second;
      case "-":
        return first - second;
      case "x":
        return first * second;
      default:
        return first / second;
    }
  }

  // toInt() drops the ".0" so 5 + 3 shows 8 and not 8.0
  String _format(double value) {
    if (value.isFinite && value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}
