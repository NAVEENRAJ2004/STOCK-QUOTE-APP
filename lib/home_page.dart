import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _typeAheadController = TextEditingController();
  final String apiKey = 'cr4ujbhr01qrns9ln7ogcr4ujbhr01qrns9ln7p0';
  Map<String, dynamic>? stockData;
  bool isLoading = false;
  String? errorMessage;
  List<String> watchlist = []; // List to hold watchlist symbols

  Future<List<Map<String, dynamic>>> fetchStockSuggestions(String query) async {
    final url = 'https://finnhub.io/api/v1/search?q=$query&token=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List result = json.decode(response.body)['result'];
      return result
          .map((item) => {
        'symbol': item['symbol'],
        'description': item['description'],
      })
          .toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> fetchStockData(String symbol) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      stockData = null;
    });

    final url = 'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['c'] == 0 && data['d'] == null) {
          setState(() {
            errorMessage = 'No data available for this symbol.';
            isLoading = false;
          });
        } else {
          setState(() {
            stockData = {
              'symbol': symbol,
              'currentPrice': data['c'],
              'change': data['d'],
              'percentChange': data['dp'],
            };
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch stock data.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> addToWatchlist(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedWatchlist = prefs.getStringList('watchlist') ?? [];
    if (!storedWatchlist.contains(symbol)) {
      storedWatchlist.add(symbol);
      await prefs.setStringList('watchlist', storedWatchlist);
      setState(() {
        watchlist = storedWatchlist;
      });
    }
  }

  String formatNumber(double number) {
    final formatter = NumberFormat.simpleCurrency(decimalDigits: 2);
    return formatter.format(number);
  }

  String formatPercentage(double number) {
    return '${number.toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STONKS'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TypeAheadField<Map<String, dynamic>>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _typeAheadController,
                decoration: InputDecoration(
                  labelText: 'Search Stock Symbol',
                  border: OutlineInputBorder(),
                ),
              ),
              suggestionsCallback: fetchStockSuggestions,
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion['symbol']),
                  subtitle: Text(suggestion['description']),
                );
              },

              noItemsFoundBuilder: (context) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('No symbols found.'),
              ), onSuggestionSelected: (Map<String, dynamic> suggestion) {
              _typeAheadController.text = suggestion['symbol'];
              fetchStockData(suggestion['symbol']);
            },
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator()
            else if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              )
            else if (stockData != null)
                Column(
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              stockData!['symbol'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Current Price: ${formatNumber(stockData!['currentPrice'])}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Change: ${formatNumber(stockData!['change'])} (${formatPercentage(stockData!['percentChange'])})',
                              style: TextStyle(
                                fontSize: 18,
                                color: stockData!['change'] >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => addToWatchlist(stockData!['symbol']),
                              child: Text('Add to Watchlist'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            SizedBox(height: 20),
            if (watchlist.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Watchlist',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ...watchlist.map((symbol) => ListTile(
                    title: Text(symbol),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        List<String> storedWatchlist = prefs.getStringList('watchlist') ?? [];
                        storedWatchlist.remove(symbol);
                        await prefs.setStringList('watchlist', storedWatchlist);
                        setState(() {
                          watchlist = storedWatchlist;
                        });
                      },
                    ),
                  )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
