import 'package:flutter/material.dart';

void main() {
  runApp(BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<CategoryItem> categories = [
    CategoryItem('Category 1', [
      ExpenseItem('Expense 1', 10),
      ExpenseItem('Expense 2', 20),
      ExpenseItem('Expense 3', 30),
    ]),
    CategoryItem('Category 2', [
      ExpenseItem('Expense 4', 15),
      ExpenseItem('Expense 5', 25),
    ]),
    CategoryItem('Category 3', [
      ExpenseItem('Expense 6', 12),
      ExpenseItem('Expense 7', 18),
      ExpenseItem('Expense 8', 22),
    ]),
  ];

  double totalExpense = 0;

  @override
  void initState() {
    super.initState();
    totalExpense = _calculateTotalExpense();
  }

  double _calculateTotalExpense() {
    return categories.fold(
      0,
      (sum, category) => sum + category.expenses.fold(0, (expenseSum, expense) => expenseSum + expense.amount),
    );
  }

  void _updateTotalExpense(double amount) {
    setState(() {
      totalExpense += amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracker'),
      ),
      body: Column(
        children: [
          UserInfoSection(),
          ExpenseTotalSection(totalExpense: totalExpense),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (BuildContext context, int index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: Text('\$${category.totalExpense.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpenseScreen(category: category, updateTotalExpense: _updateTotalExpense),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text('User Information'),
    );
  }
}

class ExpenseTotalSection extends StatelessWidget {
  final double totalExpense;

  ExpenseTotalSection({required this.totalExpense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Total Expense: \$${totalExpense.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Expense Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class ExpenseScreen extends StatefulWidget {
  final CategoryItem category;
  final Function(double) updateTotalExpense;

  ExpenseScreen({required this.category, required this.updateTotalExpense});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  double categoryTotalExpense = 0;

  @override
  void initState() {
    super.initState();
    categoryTotalExpense = widget.category.expenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  void _updateExpense(ExpenseItem expense, double amountToAdd) {
    setState(() {
      expense.amount += amountToAdd;
      widget.category.totalExpense += amountToAdd; // Update total expense of the category
      widget.updateTotalExpense(amountToAdd); // Update total expense of all categories
      categoryTotalExpense += amountToAdd; // Update total expense of the category screen
    });
  }

  void _deleteExpense(ExpenseItem expense) {
    setState(() {
      widget.category.totalExpense -= expense.amount; // Update total expense of the category
      widget.updateTotalExpense(-expense.amount); // Update total expense of all categories
      categoryTotalExpense -= expense.amount; // Update total expense of the category screen
      widget.category.expenses.remove(expense);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              'Total Expense for ${widget.category.name}: \$${categoryTotalExpense.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.category.expenses.length,
              itemBuilder: (BuildContext context, int index) {
                final expense = widget.category.expenses[index];
                return ListTile(
                  title: Text(expense.name),
                  subtitle: Text('Amount: \$${expense.amount.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          _updateExpense(expense, -1);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _updateExpense(expense, 1);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteExpense(expense);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            child: Text('Add Expense'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    AddExpenseDialog(category: widget.category, updateTotalExpense: widget.updateTotalExpense),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ExpenseItem {
  String name;
  double amount;

  ExpenseItem(this.name, this.amount);
}

class CategoryItem {
  String name;
  List<ExpenseItem> expenses;
  double totalExpense;

  CategoryItem(this.name, this.expenses)
      : totalExpense = expenses.fold(0, (sum, expense) => sum + expense.amount);
}

class AddExpenseDialog extends StatefulWidget {
  final CategoryItem category;
  final Function(double) updateTotalExpense;

  AddExpenseDialog({required this.category, required this.updateTotalExpense});

  @override
  _AddExpenseDialogState createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Expense Name'),
          ),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(labelText: 'Expense Amount'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Add'),
          onPressed: () {
            final name = _nameController.text;
            final amount = double.tryParse(_amountController.text);

            if (name.isNotEmpty && amount != null) {
              setState(() {
                widget.category.expenses.add(ExpenseItem(name, amount));
                widget.category.totalExpense += amount; // Update total expense of the category
                widget.updateTotalExpense(amount); // Update total expense of all categories
              });
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
