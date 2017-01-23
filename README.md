# XMR-Ticker-2.1
XMR Ticker 2.1

A ticker application for the macOS statusbar written in Swift, which tracks the price of Monero.
* New icon! (Provided by /u/peanutsformonkeys)
* Now uses system font, so it’s nicely aligned with the other status bar elements
* XMR/BTC, XMR/USD symbols used rather than USD/XMR, BTC/XMR - aesthetic but important
* Now supports macOS/OSX 10.10+ (previously 10.11 and above)
* I have rearchitected the code for future features, its much cleaner, and more elegantly designed, its getting sophisticated.
* USD prices are neatly rounded to 2 dp 
* BTC prices are neatly rounded to 6 dp
* There is a completely new alert/trigger system, so you can set alerts to show in Notification Centre when the price hits certain values! <— Took a while to implement!
* Portfolio tracking in USD! (XMR Ticker shows your total balance in USD after you tell it how many coins you have)
