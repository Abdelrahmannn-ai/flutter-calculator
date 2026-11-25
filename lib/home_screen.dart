import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'calculation.dart';
import 'calculator_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CalculatorCubit cubit = context.read<CalculatorCubit>();

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.tabIndex,
            children: const [CalculatorView(), HistoryView()],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.tabIndex,
            backgroundColor: Colors.black,
            selectedItemColor: const Color(0xFFFF9F0A),
            unselectedItemColor: Colors.grey,
            onTap: cubit.changeTab,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate),
                label: "Calculator",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: "History",
              ),
            ],
          ),
        );
      },
    );
  }
}

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  static const Color operatorColor = Color(0xFFFF9F0A);
  static const Color topColor = Color(0xFFA5A5A5);

  @override
  Widget build(BuildContext context) {
    CalculatorCubit cubit = context.read<CalculatorCubit>();

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: BlocBuilder<CalculatorCubit, CalculatorState>(
                  builder: (context, state) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            state.expression,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            child: Text(
                              state.display,
                              style: const TextStyle(
                                fontSize: 70,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    CalcButton(
                      text: "AC",
                      color: topColor,
                      textColor: Colors.black,
                      onTap: cubit.clear,
                    ),
                    CalcButton(
                      text: "+/-",
                      color: topColor,
                      textColor: Colors.black,
                      onTap: cubit.toggleSign,
                    ),
                    CalcButton(
                      text: "%",
                      color: topColor,
                      textColor: Colors.black,
                      onTap: cubit.percent,
                    ),
                    CalcButton(
                      text: "/",
                      color: operatorColor,
                      onTap: () => cubit.setOperator("/"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    CalcButton(text: "7", onTap: () => cubit.addDigit("7")),
                    CalcButton(text: "8", onTap: () => cubit.addDigit("8")),
                    CalcButton(text: "9", onTap: () => cubit.addDigit("9")),
                    CalcButton(
                      text: "x",
                      color: operatorColor,
                      onTap: () => cubit.setOperator("x"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    CalcButton(text: "4", onTap: () => cubit.addDigit("4")),
                    CalcButton(text: "5", onTap: () => cubit.addDigit("5")),
                    CalcButton(text: "6", onTap: () => cubit.addDigit("6")),
                    CalcButton(
                      text: "-",
                      color: operatorColor,
                      onTap: () => cubit.setOperator("-"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    CalcButton(text: "1", onTap: () => cubit.addDigit("1")),
                    CalcButton(text: "2", onTap: () => cubit.addDigit("2")),
                    CalcButton(text: "3", onTap: () => cubit.addDigit("3")),
                    CalcButton(
                      text: "+",
                      color: operatorColor,
                      onTap: () => cubit.setOperator("+"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    CalcButton(
                      text: "0",
                      flex: 2,
                      onTap: () => cubit.addDigit("0"),
                    ),
                    CalcButton(text: ".", onTap: cubit.addDot),
                    CalcButton(
                      text: "=",
                      color: operatorColor,
                      onTap: cubit.calculate,
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

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          IconButton(
            onPressed: () => context.read<CalculatorCubit>().clearHistory(),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          if (state.history.isEmpty) {
            return const Center(
              child: Text(
                "No calculations yet",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              Calculation entry = state.history[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.formula,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "= ${entry.result}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat("dd/MM/yyyy  hh:mm a").format(entry.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CalcButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final int flex;

  const CalcButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color = const Color(0xFF333333),
    this.textColor = Colors.white,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            shape: const StadiumBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Text(text, style: const TextStyle(fontSize: 26)),
        ),
      ),
    );
  }
}
