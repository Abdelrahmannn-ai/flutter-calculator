class Calculation {
  final String formula;
  final String result;
  final DateTime date;

  Calculation({
    required this.formula,
    required this.result,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {"formula": formula, "result": result, "date": date};
  }

  factory Calculation.fromMap(Map map) {
    return Calculation(
      formula: map["formula"],
      result: map["result"],
      date: map["date"],
    );
  }
}
