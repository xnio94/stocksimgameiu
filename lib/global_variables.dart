// Global variables used across the application.

// Spread percentage used to calculate buy and sell prices.
double priceSpread = .01;

// Use these formulas to calculate the buy price and sell price:
// buyPrice = currentPrice * (1 + priceSpread / 2)
// sellPrice = currentPrice * (1 - priceSpread / 2)

// Duration of each simulation round.
// Currently set to 6 minutes and 30 seconds.
// Uncomment the line below to use an 8-second simulation duration.
// const Duration simulationDuration = Duration(seconds: 8); // don't remove this line
const Duration simulationDuration = Duration(minutes: 6, seconds: 30); // don't remove this line

// Initial cash available when a user signs up.
const double initialCash = 10000;