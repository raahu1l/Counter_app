import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _input = '';
  String _output = '';

  // Function to handle button press
  void _buttonPressed(String text) {
    setState(() {
      _input += text;
    });
  }

  // Function to handle calculation
  void _calculate() {
    try {
      String expression = _input;

      // Replace 'x' with '*' and '÷' with '/' to standardize operations
      expression = expression.replaceAll('x', '*').replaceAll('÷', '/');

      // Evaluate the expression
      final result = _evaluateExpression(expression);

      // Show result
      setState(() {
        _output = result.toString();
      });
    } catch (e) {
      setState(() {
        _output = 'Error';
      });
    }
  }

  // Simple expression evaluator
  double _evaluateExpression(String expression) {
    // Using Dart's built-in eval function by utilizing the built-in `dart:math`
    // For simplicity, this example only supports basic operations and parentheses

    // Handle square root
    if (expression.contains('sqrt')) {
      expression = expression.replaceAll('sqrt', '').trim();
      final num value = double.parse(expression);
      return sqrt(value);
    }

    // If it has exponentiation (`^`)
    if (expression.contains('^')) {
      var parts = expression.split('^');
      var base = double.parse(parts[0]);
      var exponent = double.parse(parts[1]);
      return pow(base, exponent).toDouble();
    }

    // Use Dart's `eval` function for simple mathematical expressions
    return _parseSimpleExpression(expression);
  }

  // Parsing simple operations with basic math
  double _parseSimpleExpression(String expression) {
    final exp = expression.replaceAll(' ', ''); // Clean spaces
    final regex = RegExp(r'(\d+(\.\d+)?|\+|\-|\*|\/|\^|\(|\))');
    List<String> tokens = regex.allMatches(exp).map((match) => match.group(0)!).toList();

    List<String> outputQueue = [];
    List<String> operatorStack = [];

    Map<String, int> precedence = {'+': 1, '-': 1, '*': 2, '/': 2, '^': 3};

    // Shunting Yard Algorithm to handle precedence and order
    for (var token in tokens) {
      if (_isNumber(token)) {
        outputQueue.add(token);
      } else if (_isOperator(token)) {
        while (operatorStack.isNotEmpty &&
            precedence[operatorStack.last]! >= precedence[token]!) {
          outputQueue.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
      } else if (token == '(') {
        operatorStack.add(token);
      } else if (token == ')') {
        while (operatorStack.isNotEmpty && operatorStack.last != '(') {
          outputQueue.add(operatorStack.removeLast());
        }
        operatorStack.removeLast(); // Remove '('
      }
    }

    while (operatorStack.isNotEmpty) {
      outputQueue.add(operatorStack.removeLast());
    }

    return _evaluateRPN(outputQueue);
  }

  bool _isNumber(String token) {
    return RegExp(r'^\d+(\.\d+)?$').hasMatch(token);
  }

  bool _isOperator(String token) {
    return ['+', '-', '*', '/', '^'].contains(token);
  }

  // Evaluate the Reverse Polish Notation (RPN)
  double _evaluateRPN(List<String> rpn) {
    List<double> stack = [];

    for (var token in rpn) {
      if (_isNumber(token)) {
        stack.add(double.parse(token));
      } else if (_isOperator(token)) {
        double b = stack.removeLast();
        double a = stack.removeLast();
        switch (token) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            stack.add(a / b);
            break;
          case '^':
            stack.add(pow(a, b).toDouble());
            break;
        }
      }
    }

    return stack.last;
  }

  // Function to clear input and output
  void _clear() {
    setState(() {
      _input = '';
      _output = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _input,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _output,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.0,
              children: [
                _buildButton('7'),
                _buildButton('8'),
                _buildButton('9'),
                _buildButton('÷'),
                _buildButton('4'),
                _buildButton('5'),
                _buildButton('6'),
                _buildButton('x'),
                _buildButton('1'),
                _buildButton('2'),
                _buildButton('3'),
                _buildButton('-'),
                _buildButton('0'),
                _buildButton('.'),
                _buildButton('sqrt'),
                _buildButton('+'),
                _buildButton('^'),
                _buildButton('C'),
                _buildButton('='),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create buttons
  Widget _buildButton(String label) {
    return ElevatedButton(
      onPressed: () {
        if (label == 'C') {
          _clear();
        } else if (label == '=') {
          _calculate();
        } else {
          _buttonPressed(label);
        }
      },
      child: Text(label, style: TextStyle(fontSize: 24)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(80, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
