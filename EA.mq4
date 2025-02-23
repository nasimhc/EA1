//+------------------------------------------------------------------+
//|                                                             EA.mq4 |
//|                                     Copyright 2024, Your Name Here |
//|                                             https://www.yourwebsite.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Your Name Here"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

// Enum definition for MA types
enum ENUM_MA_TYPES
{
   MA_SMA,              // Simple moving average
   MA_EMA,              // Exponential moving average
   MA_SMMA,            // Smoothed moving average
   MA_LWMA,            // Linear weighted moving average
   MA_DEMA,            // Double exponential moving average
   MA_TEMA,            // Triple exponential moving average
   MA_T3,              // T3 moving average
   MA_JURIK,           // Jurik moving average
   MA_HULL,            // Hull moving average
   MA_DECEMA,          // DECEMA moving average
   MA_SALT             // SALT indicator
};

// Trading Parameters
extern double LotSize = 0.1;              // Trading lot size
extern int StopLoss = 100;                // Stop loss in pips
extern int TakeProfit = 200;              // Take profit in pips
extern bool UseMoneyManagement = false;    // Use money management
extern double RiskPercent = 2.0;          // Risk percent when money management is enabled

// MACD1 Parameters
extern string MACD1_Label = "==== MACD1 Settings ====";  // MACD1 Settings
extern int MACD1_FastEMA = 12;            // MACD1 Fast EMA
extern int MACD1_SlowEMA = 26;            // MACD1 Slow EMA
extern int MACD1_SignalSMA = 9;           // MACD1 Signal SMA
extern bool MACD1_SoundON = false;        // MACD1 Sound Alert
extern bool MACD1_EmailON = false;        // MACD1 Email Alert

// MACD2 Parameters
extern string MACD2_Label = "==== MACD2 Settings ====";  // MACD2 Settings
extern int MACD2_FastEMA = 12;            // MACD2 Fast EMA
extern int MACD2_SlowEMA = 26;            // MACD2 Slow EMA
extern int MACD2_SignalSMA = 9;           // MACD2 Signal SMA
extern bool MACD2_SoundON = false;        // MACD2 Sound Alert
extern bool MACD2_EmailON = false;        // MACD2 Email Alert

// TDI Parameters
extern string TDI_Label = "==== TDI Settings ====";      // TDI Settings
extern int TDI_RSI_Period = 50;           // TDI RSI Period
extern int TDI_RSI_Price = PRICE_CLOSE;   // TDI RSI Price
extern int TDI_Volatility_Band = 34;      // TDI Volatility Band
extern int TDI_RSISignal_Period = 2;      // TDI RSI Signal Period
extern int TDI_RSISignal_Mode = MODE_SMA;   // TDI RSI Signal Mode (0:SMA, 1:EMA, 2:SMMA, 3:LWMA)
extern int TDI_TradeSignal_Period = 50;   // TDI Trade Signal Period
extern int TDI_TradeSignal_Mode = MODE_SMA; // TDI Trade Signal Mode (0:SMA, 1:EMA, 2:SMMA, 3:LWMA)

// xpMA1 Parameters
extern string xpMA1_Label = "==== xpMA1 Settings ====";  // xpMA1 Settings
extern int xpMA1_Period = 34;             // xpMA1 Period
extern ENUM_MA_TYPES xpMA1_MA_Type = MA_EMA;  // xpMA1 MA Type
extern int xpMA1_Price = PRICE_CLOSE;     // xpMA1 Applied Price
extern double xpMA1_T3_Factor = 0.8;      // xpMA1 T3 Volume Factor
extern double xpMA1_JMA_Phase = 0;        // xpMA1 JMA Phase
extern int xpMA1_Step_Period = 4;         // xpMA1 Step Period

// xpMA2 Parameters
extern string xpMA2_Label = "==== xpMA2 Settings ====";  // xpMA2 Settings
extern int xpMA2_Period = 34;             // xpMA2 Period
extern ENUM_MA_TYPES xpMA2_MA_Type = MA_EMA;  // xpMA2 MA Type
extern int xpMA2_Price = PRICE_CLOSE;     // xpMA2 Applied Price
extern double xpMA2_T3_Factor = 0.8;      // xpMA2 T3 Volume Factor
extern double xpMA2_JMA_Phase = 0;        // xpMA2 JMA Phase
extern int xpMA2_Step_Period = 4;         // xpMA2 Step Period

// xpMA3 Parameters
extern string xpMA3_Label = "==== xpMA3 Settings ====";  // xpMA3 Settings
extern int xpMA3_Period = 34;             // xpMA3 Period
extern ENUM_MA_TYPES xpMA3_MA_Type = MA_EMA;  // xpMA3 MA Type
extern int xpMA3_Price = PRICE_CLOSE;     // xpMA3 Applied Price
extern double xpMA3_T3_Factor = 0.8;      // xpMA3 T3 Volume Factor
extern double xpMA3_JMA_Phase = 0;        // xpMA3 JMA Phase
extern int xpMA3_Step_Period = 4;         // xpMA3 Step Period

// Add new risk management parameters
extern int MaxSpread = 3;                 // Maximum allowed spread (points)
extern int MaxSlippage = 3;               // Maximum allowed slippage (points)
extern int MagicNumber = 123456;          // Unique EA identifier
extern bool EnableTrailingStop = true;    // Enable trailing stop
extern int TrailingStopDistance = 50;     // Trailing stop distance (pips)
extern int BreakEvenAt = 50;              // Activate breakeven at (pips profit)

// Global Variables
int ticket = 0;
bool isNewBar = false;
datetime lastBarTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   // Check for testing environment
   if(IsTesting() || IsOptimization()) 
       MagicNumber = 0; // Disable magic number in testing
       
   // Check spread and market conditions
   if(MarketInfo(Symbol(), MODE_SPREAD) > MaxSpread) {
       Print("Spread too wide. EA not initialized.");
       return(INIT_FAILED);
   }
   
   // Check if all required indicators are present by trying to get their handles
   if(iCustom(NULL, 0, "TDI", TDI_RSI_Period, TDI_RSI_Price, TDI_Volatility_Band,
                        TDI_RSISignal_Period, TDI_RSISignal_Mode, TDI_TradeSignal_Period,
                        TDI_TradeSignal_Mode, 0, 0) == -1) {
      Print("Error: TDI indicator not found!");
      return(INIT_FAILED);
   }
   
   if(iCustom(NULL, 0, "MACD1", MACD1_FastEMA, MACD1_SlowEMA, MACD1_SignalSMA,
                  MACD1_SoundON, MACD1_EmailON, 0, 0) == -1) {
      Print("Error: MACD1 indicator not found!");
      return(INIT_FAILED);
   }
   
   if(iCustom(NULL, 0, "MACD2", MACD2_FastEMA, MACD2_SlowEMA, MACD2_SignalSMA,
                  MACD2_SoundON, MACD2_EmailON, 0, 0) == -1) {
      Print("Error: MACD2 indicator not found!");
      return(INIT_FAILED);
   }
   
   if(iCustom(NULL, 0, "xpMA1", xpMA1_Period, xpMA1_MA_Type, xpMA1_Price,
                  xpMA1_T3_Factor, xpMA1_JMA_Phase, xpMA1_Step_Period, 0, 0) == -1) {
      Print("Error: xpMA1 indicator not found!");
      return(INIT_FAILED);
   }
   
   if(iCustom(NULL, 0, "xpMA2", xpMA2_Period, xpMA2_MA_Type, xpMA2_Price,
                  xpMA2_T3_Factor, xpMA2_JMA_Phase, xpMA2_Step_Period, 0, 0) == -1) {
      Print("Error: xpMA2 indicator not found!");
      return(INIT_FAILED);
   }
   
   if(iCustom(NULL, 0, "xpMA3", xpMA3_Period, xpMA3_MA_Type, xpMA3_Price,
                  xpMA3_T3_Factor, xpMA3_JMA_Phase, xpMA3_Step_Period, 0, 0) == -1) {
      Print("Error: xpMA3 indicator not found!");
      return(INIT_FAILED);
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check basic market conditions
   if(IsTradeContextBusy() || IsStopped()) return;
   
   // Check spread
   if(MarketInfo(Symbol(), MODE_SPREAD) > MaxSpread) return;

   // Check for new bar
   if(isNewBar()) {
       ManageOpenPositions(); // Add position management
       
       if(!IsTradeOpen()) {
           // Check buy conditions
           if(CheckBuyConditions())
           {
               OpenBuy();
           }
           // Check sell conditions
           else if(CheckSellConditions())
           {
               OpenSell();
           }
       }
   }
}

//+------------------------------------------------------------------+
//| Check if it's a new bar                                           |
//+------------------------------------------------------------------+
bool isNewBar()
{
   static datetime lastBar;
   datetime currentBar = Time[0];
   if(lastBar != currentBar) {
       lastBar = currentBar;
       return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Check if trade is already open                                     |
//+------------------------------------------------------------------+
bool IsTradeOpen()
{
   for(int i = OrdersTotal()-1; i >= 0; i--) {
       if(OrderSelect(i, SELECT_BY_POS) && 
          OrderSymbol() == Symbol() && 
          OrderMagicNumber() == MagicNumber) {
           return true;
       }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Check buy conditions                                              |
//+------------------------------------------------------------------+
bool CheckBuyConditions()
{
   // 1. TDI Condition: Green line above red line
   double tdiGreen = iCustom(NULL, 0, "TDI", TDI_RSI_Period, TDI_RSI_Price, TDI_Volatility_Band,
                           TDI_RSISignal_Period, TDI_RSISignal_Mode, TDI_TradeSignal_Period,
                           TDI_TradeSignal_Mode, 1, 0);
   double tdiRed = iCustom(NULL, 0, "TDI", TDI_RSI_Period, TDI_RSI_Price, TDI_Volatility_Band,
                          TDI_RSISignal_Period, TDI_RSISignal_Mode, TDI_TradeSignal_Period,
                          TDI_TradeSignal_Mode, 0, 0);
   bool tdiCondition = (tdiGreen > tdiRed);
   
   // 2. xpMA2 Condition: Above xpMA1 and color is DodgerBlue
   double xpma1 = iCustom(NULL, 0, "xpMA1", xpMA1_Period, xpMA1_MA_Type, xpMA1_Price,
                         xpMA1_T3_Factor, xpMA1_JMA_Phase, xpMA1_Step_Period, 0, 0);
   double xpma2 = iCustom(NULL, 0, "xpMA2", xpMA2_Period, xpMA2_MA_Type, xpMA2_Price,
                         xpMA2_T3_Factor, xpMA2_JMA_Phase, xpMA2_Step_Period, 0, 0);
   double xpma2Signal = iCustom(NULL, 0, "xpMA2", xpMA2_Period, xpMA2_MA_Type, xpMA2_Price,
                               xpMA2_T3_Factor, xpMA2_JMA_Phase, xpMA2_Step_Period, 3, 0);
   bool xpma2Condition = (xpma2 > xpma1 && xpma2Signal == 1);
   
   // 3. Price Condition: Above xpMA3 and xpMA3 color is DodgerBlue
   double xpma3 = iCustom(NULL, 0, "xpMA3", xpMA3_Period, xpMA3_MA_Type, xpMA3_Price,
                         xpMA3_T3_Factor, xpMA3_JMA_Phase, xpMA3_Step_Period, 0, 0);
   double xpma3Signal = iCustom(NULL, 0, "xpMA3", xpMA3_Period, xpMA3_MA_Type, xpMA3_Price,
                               xpMA3_T3_Factor, xpMA3_JMA_Phase, xpMA3_Step_Period, 3, 0);
   bool priceCondition = (Close[0] > xpma3 && xpma3Signal == 1);
   
   // 4. MACD Conditions: Both MACD1 and MACD2 blue line above red line
   double macd1Main = iCustom(NULL, 0, "MACD1", MACD1_FastEMA, MACD1_SlowEMA, MACD1_SignalSMA,
                            MACD1_SoundON, MACD1_EmailON, 0, 0);
   double macd1Signal = iCustom(NULL, 0, "MACD1", MACD1_FastEMA, MACD1_SlowEMA, MACD1_SignalSMA,
                               MACD1_SoundON, MACD1_EmailON, 1, 0);
   double macd2Main = iCustom(NULL, 0, "MACD2", MACD2_FastEMA, MACD2_SlowEMA, MACD2_SignalSMA,
                            MACD2_SoundON, MACD2_EmailON, 0, 0);
   double macd2Signal = iCustom(NULL, 0, "MACD2", MACD2_FastEMA, MACD2_SlowEMA, MACD2_SignalSMA,
                               MACD2_SoundON, MACD2_EmailON, 1, 0);
   bool macdCondition = (macd1Main > macd1Signal && macd2Main > macd2Signal);
   
   return(tdiCondition && xpma2Condition && priceCondition && macdCondition);
}

//+------------------------------------------------------------------+
//| Check sell conditions                                             |
//+------------------------------------------------------------------+
bool CheckSellConditions()
{
   // 1. TDI Condition: Green line below red line
   double tdiGreen = iCustom(NULL, 0, "TDI", TDI_RSI_Period, TDI_RSI_Price, TDI_Volatility_Band,
                           TDI_RSISignal_Period, TDI_RSISignal_Mode, TDI_TradeSignal_Period,
                           TDI_TradeSignal_Mode, 1, 0);
   double tdiRed = iCustom(NULL, 0, "TDI", TDI_RSI_Period, TDI_RSI_Price, TDI_Volatility_Band,
                          TDI_RSISignal_Period, TDI_RSISignal_Mode, TDI_TradeSignal_Period,
                          TDI_TradeSignal_Mode, 0, 0);
   bool tdiCondition = (tdiGreen < tdiRed);
   
   // 2. xpMA2 Condition: Below xpMA1 and color is OrangeRed
   double xpma1 = iCustom(NULL, 0, "xpMA1", xpMA1_Period, xpMA1_MA_Type, xpMA1_Price,
                         xpMA1_T3_Factor, xpMA1_JMA_Phase, xpMA1_Step_Period, 0, 0);
   double xpma2 = iCustom(NULL, 0, "xpMA2", xpMA2_Period, xpMA2_MA_Type, xpMA2_Price,
                         xpMA2_T3_Factor, xpMA2_JMA_Phase, xpMA2_Step_Period, 0, 0);
   double xpma2Signal = iCustom(NULL, 0, "xpMA2", xpMA2_Period, xpMA2_MA_Type, xpMA2_Price,
                               xpMA2_T3_Factor, xpMA2_JMA_Phase, xpMA2_Step_Period, 3, 0);
   bool xpma2Condition = (xpma2 < xpma1 && xpma2Signal == -1);
   
   // 3. Price Condition: Below xpMA3 and xpMA3 color is OrangeRed
   double xpma3 = iCustom(NULL, 0, "xpMA3", xpMA3_Period, xpMA3_MA_Type, xpMA3_Price,
                         xpMA3_T3_Factor, xpMA3_JMA_Phase, xpMA3_Step_Period, 0, 0);
   double xpma3Signal = iCustom(NULL, 0, "xpMA3", xpMA3_Period, xpMA3_MA_Type, xpMA3_Price,
                               xpMA3_T3_Factor, xpMA3_JMA_Phase, xpMA3_Step_Period, 3, 0);
   bool priceCondition = (Close[0] < xpma3 && xpma3Signal == -1);
   
   // 4. MACD Conditions: Both MACD1 and MACD2 blue line below red line
   double macd1Main = iCustom(NULL, 0, "MACD1", MACD1_FastEMA, MACD1_SlowEMA, MACD1_SignalSMA,
                            MACD1_SoundON, MACD1_EmailON, 0, 0);
   double macd1Signal = iCustom(NULL, 0, "MACD1", MACD1_FastEMA, MACD1_SlowEMA, MACD1_SignalSMA,
                               MACD1_SoundON, MACD1_EmailON, 1, 0);
   double macd2Main = iCustom(NULL, 0, "MACD2", MACD2_FastEMA, MACD2_SlowEMA, MACD2_SignalSMA,
                            MACD2_SoundON, MACD2_EmailON, 0, 0);
   double macd2Signal = iCustom(NULL, 0, "MACD2", MACD2_FastEMA, MACD2_SlowEMA, MACD2_SignalSMA,
                               MACD2_SoundON, MACD2_EmailON, 1, 0);
   bool macdCondition = (macd1Main < macd1Signal && macd2Main < macd2Signal);
   
   return(tdiCondition && xpma2Condition && priceCondition && macdCondition);
}

//+------------------------------------------------------------------+
//| Open buy position                                                 |
//+------------------------------------------------------------------+
void OpenBuy()
{
   double point = MarketInfo(Symbol(), MODE_POINT);
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   
   // Convert pips to points
   double slPoints = StopLoss * (point * 10); // For 5-digit brokers
   double tpPoints = TakeProfit * (point * 10);
   
   double sl = (StopLoss > 0) ? NormalizeDouble(Ask - slPoints, digits) : 0;
   double tp = (TakeProfit > 0) ? NormalizeDouble(Ask + tpPoints, digits) : 0;
   
   for(int attempt=0; attempt<5; attempt++) {
       ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, MaxSlippage, sl, tp, 
                         "EA Buy Order", MagicNumber, 0, clrGreen);
       if(ticket > 0) break;
       Sleep(500);
       RefreshRates();
   }
   
   if(ticket < 0)
   {
      Print("OrderSend failed with error #", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Open sell position                                                |
//+------------------------------------------------------------------+
void OpenSell()
{
   double lots = CalculateLotSize();
   double sl = (StopLoss > 0) ? NormalizeDouble(Bid + StopLoss * Point, Digits) : 0;
   double tp = (TakeProfit > 0) ? NormalizeDouble(Bid - TakeProfit * Point, Digits) : 0;
   
   ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, 3, sl, tp, "EA Sell Order", 123456, 0, clrRed);
   
   if(ticket < 0)
   {
      Print("OrderSend failed with error #", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Calculate position size based on money management                  |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   if(!UseMoneyManagement)
      return LotSize;
      
   double riskMoney = AccountBalance() * RiskPercent / 100;
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   
   double lots = NormalizeDouble(riskMoney / (StopLoss * tickValue), 2);
   lots = MathFloor(lots / lotStep) * lotStep;
   
   if(lots < minLot) lots = minLot;
   if(lots > maxLot) lots = maxLot;
   
   return lots;
}

//+------------------------------------------------------------------+
//| Add trailing stop and breakeven logic                              |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   for(int i = OrdersTotal()-1; i >= 0; i--) {
       if(OrderSelect(i, SELECT_BY_POS) && 
          OrderSymbol() == Symbol() && 
          OrderMagicNumber() == MagicNumber) {
           
           if(EnableTrailingStop) {
               double newSl = 0;
               if(OrderType() == OP_BUY) {
                   double currentSl = OrderStopLoss();
                   newSl = High[0] - TrailingStopDistance * Point;
                   if(newSl > currentSl || currentSl == 0)
                       OrderModify(OrderTicket(), OrderOpenPrice(), newSl, OrderTakeProfit(), 0);
               }
               else if(OrderType() == OP_SELL) {
                   newSl = Low[0] + TrailingStopDistance * Point;
                   if(newSl < currentSl || currentSl == 0)
                       OrderModify(OrderTicket(), OrderOpenPrice(), newSl, OrderTakeProfit(), 0);
               }
           }
           
           // Breakeven logic
           if(BreakEvenAt > 0) {
               double profitPoints = (OrderType() == OP_BUY) ? 
                   (Bid - OrderOpenPrice())/Point : 
                   (OrderOpenPrice() - Ask)/Point;
                   
               if(profitPoints >= BreakEvenAt && OrderStopLoss() == OrderOpenPrice()) {
                   double newSl = OrderOpenPrice();
                   OrderModify(OrderTicket(), OrderOpenPrice(), newSl, OrderTakeProfit(), 0);
               }
           }
       }
   }
}
