import 'dart:async';

import 'package:expensetracker/google_sheets_api.dart';
import 'package:expensetracker/plus_button.dart';
import 'package:expensetracker/top_card.dart';
import 'package:expensetracker/transaction.dart';
import 'package:flutter/material.dart';

import 'loading_circle.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isIncome = false;
  final _textcontrollerAMOUNT = TextEditingController();
  final _textcontrollerITEM = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _enterTransaction() {
    GoogleSheetsApi.insert(
      _textcontrollerITEM.text,
      _textcontrollerAMOUNT.text,
      _isIncome,
    );
    setState(() {});
  }

  void _newTransaction() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: Text('N E W  T R A N S A C T I O N'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Expense'),
                          Switch(
                            value: _isIncome,
                            onChanged: (newValue) {
                              setState(() {
                                _isIncome = newValue;
                              });
                            },
                          ),
                          Text('Income'),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Amount?',
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Enter an amount';
                                  }
                                  return null;
                                },
                                controller: _textcontrollerAMOUNT,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'For what?',
                              ),
                              controller: _textcontrollerITEM,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  MaterialButton(
                    color: Colors.grey[600],
                    child:
                        Text('Cancel', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  MaterialButton(
                    color: Colors.grey[600],
                    child: Text('Enter', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _enterTransaction();
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
              );
            },
          );
        });
  }

  // wait for the data to be fetched from google sheets
  bool timerHasStarted = false;
  void startLoading() {
    timerHasStarted = true;
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (GoogleSheetsApi.loading == false) {
        setState(() {});
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // start loading until the data arrives
    if (GoogleSheetsApi.loading == true && timerHasStarted == false) {
      startLoading();
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TopNeuCard(
                        balance: '\$' +
                            (GoogleSheetsApi.calculateIncome() -
                                    GoogleSheetsApi.calculateExpense())
                                .toString(),
                        income: GoogleSheetsApi.calculateIncome().toString(),
                        expense: GoogleSheetsApi.calculateExpense().toString(),
                        function: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    Text('T R A N S A C T I O N S',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 22)),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            Expanded(
              child: GoogleSheetsApi.loading == true
                  ? LoadingCircle()
                  : ListView.builder(
                      itemCount: GoogleSheetsApi.currentTransactions.length,
                      itemBuilder: (context, index) {
                        return MyTransaction(
                          text: GoogleSheetsApi.currentTransactions[index][0],
                          money: GoogleSheetsApi.currentTransactions[index][1],
                          expenseOrIncome:
                              GoogleSheetsApi.currentTransactions[index][2],
                        );
                      },
                    ),
            ),
            SizedBox(
              height: 10,
            ),
            PlusButton(
              child: Text(
                '+',
                style: TextStyle(color: Colors.white, fontSize: 50),
              ),
              function: _newTransaction,
            )
          ],
        ),
      ),
    );
  }
}
