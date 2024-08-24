import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WatchlistPage extends StatefulWidget {
  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final String apiKey = 'cr4ujbhr01qrns9ln7ogcr4ujbhr01qrns9ln7p0';
  List<Map<String, dynamic>> watchlistData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    List<String>? watchlist = prefs.getStringList('watchlist') ?? [];

    watchlistData = await Future.wait(watchlist.map((symbol) => fetchStockData(symbol)).toList());

    setState(() {
      isLoading = false;
    });
  }

  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    final url = 'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'symbol': symbol,
        'currentPrice': data['c'],
        'change': data['d'],
        'percentChange': data['dp'],
      };
    } else {
      throw Exception('Failed to fetch stock data.');
    }
  }

  Future<void> removeFromWatchlist(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? watchlist = prefs.getStringList('watchlist') ?? [];
    watchlist.remove(symbol);
    await prefs.setStringList('watchlist', watchlist);
    loadWatchlist();
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
        title: Text('Watchlist'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadWatchlist,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: watchlistData.length,
        itemBuilder: (context, index) {
          final stock = watchlistData[index];
          return ListTile(
            title: Text(stock['symbol']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Price: ${formatNumber(stock['currentPrice'])}'),
                Text('Change: ${formatNumber(stock['change'])} (${formatPercentage(stock['percentChange'])})',
                    style: TextStyle(
                        color: stock['change'] >= 0 ? Colors.green : Colors.red)),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => removeFromWatchlist(stock['symbol']),
            ),
          );
        },
      ),
    );
  }
}
