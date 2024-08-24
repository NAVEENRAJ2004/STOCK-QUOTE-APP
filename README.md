# STONKS

STONKS is a Flutter app designed to provide real-time stock information. It integrates with a stock API to allow users to search for stocks, view their quotes, and manage a watchlist.

## Features

- **Search for Stocks**: Users can search for stocks by symbol and view relevant information.
- **Stock Quote Display**: Displays stock information including symbol, current price, change (amount and percentage), and optionally the company name.
- **Watchlist Management**:
    - Add stocks to the watchlist.
    - View real-time prices and percentage change between low and high prices.
    - Remove stocks from the watchlist.
    - Refresh watchlist data.

## Installation

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/NAVEENRAJ2004/STOCK-QUOTE-APP
    ```

2. **Navigate to the Project Directory**:
    ```bash
    cd stonks
    ```

3. **Install Dependencies**:
   Ensure you have Flutter installed and run:
    ```bash
    flutter pub get
    ```

4. **Add API Key**:
   Replace `'YOUR_API_KEY'` in the `home_page.dart` file with your actual API key from [Finnhub](https://finnhub.io/).

5. **Run the App**:
    ```bash
    flutter run
    ```

## Usage

1. **Search for Stocks**:
    - Enter a stock symbol in the search bar to view real-time data and add it to the watchlist.

2. **Add to Watchlist**:
    - Click "Add to Watchlist" to add the stock to your watchlist.

3. **View Watchlist**:
    - The watchlist shows real-time prices, changes, low/high prices, and the percentage change between low and high.

4**Delete from Watchlist**:
    - Use the delete button next to a stock in the watchlist to remove it.

## Project Structure

- **`lib/main.dart`**: Entry point of the Flutter application.
- **`lib/home_page.dart`**: Contains the main functionality including search and watchlist features.
- - **`lib/watchlist_page.dart`**: Project dependencies and metadata.
- **`pubspec.yaml`**: Project dependencies and metadata.

## Dependencies

- `flutter`: ^2.0.0 (or latest)
- `http`: ^0.13.3 (or latest)
- `flutter_typeahead`: ^3.1.0 (or latest)
- `shared_preferences`: ^2.0.7 (or latest)
- `intl`: ^0.17.0## Acknowledgements

- [Finnhub API](https://finnhub.io/) for providing stock market data.
- Flutter community for their support and resources.

