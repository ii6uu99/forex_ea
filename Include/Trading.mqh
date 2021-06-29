//+------------------------------------------------------------------+
//|                                                     Plotting.mqh |
//|                       Copyright 2021, Zjansson Technologies Ltd. |
//|                              https://github.com/Entreco/forex_ea |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Zjansson Technologies Ltd."
#property link      "https://github.com/Entreco/forex_ea"
#property version   "1.00"

#include <Trade\Trade.mqh>


//+------------------------------------------------------------------+
//| Finds Resistance - Maximum Rate                                  |
//+------------------------------------------------------------------+
double FindResistance(const MqlRates &rates[], int start, int count)
  {
   int HighestCandle;      //create variable for highest price
   double High[];           //create array for price data
   ArraySetAsSeries(High,true);     //sort array from current candle downwards
   CopyHigh(Symbol(),Period(),start,count,High);    //fill the array with the high prices
   HighestCandle = ArrayMaximum(High,0,count);  //get the highest candle price
   return rates[HighestCandle].high;
  }

//+------------------------------------------------------------------+
//| Finds Support - Minimum Rate                                               |
//+------------------------------------------------------------------+
double FindSupport(const MqlRates &rates[], int start, int count)
  {
   int LowestCandle;      //create variable for highest price
   double Low[];           //create array for price data
   ArraySetAsSeries(Low,true);     //sort array from current candle downwards
   CopyLow(Symbol(),Period(),start,count,Low);    //fill the array with the high prices
   LowestCandle = ArrayMinimum(Low,0,count);  //get the lowest candle price
   return rates[LowestCandle].low;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlaceTrade(double price,double stopLoss,double takeProfit,int orderType, double riskFactor)
  {
// Create traderequest
   MqlTradeRequest mrequest;  // To be used for sending our trade requests
   MqlTradeResult mresult;    // To be used to get our trade results
   ZeroMemory(mrequest);

   mrequest.action = TRADE_ACTION_DEAL;                                 // immediate order execution
   mrequest.price = NormalizeDouble(price,_Digits);          // latest Bid price
   mrequest.sl = NormalizeDouble(stopLoss,_Digits); // Stop Loss
   mrequest.tp = NormalizeDouble(takeProfit,_Digits); // Take Profit
   mrequest.symbol = _Symbol;                                         // currency pair
   mrequest.volume = ComputeLot(riskFactor);                                  // number of lots to trade
   mrequest.magic = 34567;                                        // Order Magic Number
   mrequest.type= orderType;                                     // Sell Order
   mrequest.type_filling = ORDER_FILLING_FOK;                          // Order execution type
   mrequest.deviation=100;                                           // Deviation from current price

// send order
   OrderSend(mrequest,mresult);
  }
  
//+------------------------------------------------------------------+
//| Opens a long position with specified parameters                  |
//+------------------------------------------------------------------+
void Buy(CTrade* trade, double price,double stopLoss,double takeProfit, double riskFactor)
  {
   double volume = ComputeLot(riskFactor);
   double normalPrice = NormalizeDouble(price, _Digits);
   double normalStopLoss = NormalizeDouble(stopLoss,_Digits);
   double normalTakeProfit = NormalizeDouble(takeProfit,_Digits);

   bool result = trade.Buy(volume, _Symbol, normalPrice, normalStopLoss, normalTakeProfit, "Buy");
   if(!result)
      Print("Buy() method failed. Return code=", trade.ResultRetcode(), " (", trade.ResultRetcodeDescription(), ")");
  }
//+------------------------------------------------------------------+
//| Places a pending order of the Buy Limit type with specified parameters |
//+------------------------------------------------------------------+
void BuyLimit(CTrade* trade, double price,double stopLoss,double takeProfit, double riskFactor, ENUM_ORDER_TYPE_TIME typeMime = ORDER_TIME_DAY, datetime expirationTime = 0)
  {
   double volume = ComputeLot(riskFactor);
   double normalPrice = NormalizeDouble(price, _Digits);
   double normalStopLoss = NormalizeDouble(stopLoss,_Digits);
   double normalTakeProfit = NormalizeDouble(takeProfit,_Digits);

   trade.BuyLimit(volume, normalPrice, _Symbol, normalStopLoss,normalTakeProfit,typeMime, expirationTime, "BuyLimit");
  }

//+------------------------------------------------------------------+
//| Places a pending order of the Buy Stop type with specified parameters |
//+------------------------------------------------------------------+
void BuyStop(CTrade* trade, double price,double stopLoss,double takeProfit, double riskFactor, ENUM_ORDER_TYPE_TIME typeMime = ORDER_TIME_DAY, datetime expirationTime = 0)
  {
   double volume = ComputeLot(riskFactor);
   double normalPrice = NormalizeDouble(price, _Digits);
   double normalStopLoss = NormalizeDouble(stopLoss,_Digits);
   double normalTakeProfit = NormalizeDouble(takeProfit,_Digits);

   trade.BuyStop(volume, normalPrice, _Symbol, normalStopLoss,normalTakeProfit,typeMime, expirationTime, "BuyStop");
  }


//+------------------------------------------------------------------+
//| Opens a short position with specified parameters                  |
//+------------------------------------------------------------------+
void Sell(CTrade* trade, double price,double stopLoss,double takeProfit, double riskFactor)
  {
   double volume = ComputeLot(riskFactor);
   double normalPrice = NormalizeDouble(price, _Digits);
   double normalStopLoss = NormalizeDouble(stopLoss,_Digits);
   double normalTakeProfit = NormalizeDouble(takeProfit,_Digits);

   bool result = trade.Sell(volume, _Symbol, normalPrice, normalStopLoss, normalTakeProfit, "Sell");
   if(!result)
      Print("Sell() method failed. Return code=", trade.ResultRetcode(), " (", trade.ResultRetcodeDescription(), ")");
  }
//+------------------------------------------------------------------+
//| Places a pending order of the Sell Limit type with specified parameters |
//+------------------------------------------------------------------+
void SellLimit(CTrade* trade, double price,double stopLoss,double takeProfit, double riskFactor, ENUM_ORDER_TYPE_TIME typeMime = ORDER_TIME_DAY, datetime expirationTime = 0)
  {
   double volume = ComputeLot(riskFactor);
   double normalPrice = NormalizeDouble(price, _Digits);
   double normalStopLoss = NormalizeDouble(stopLoss,_Digits);
   double normalTakeProfit = NormalizeDouble(takeProfit,_Digits);

   trade.SellLimit(volume, _Symbol, normalPrice, normalStopLoss, normalTakeProfit, typeMime, expirationTime, "SellLimit");
  }
//+------------------------------------------------------------------+
//| Places a pending order of the Sell Stop type with specified parameters |
//+------------------------------------------------------------------+
void SellStop(CTrade* trade, double price,double stopLoss,double takeProfit, double riskFactor, ENUM_ORDER_TYPE_TIME typeMime = ORDER_TIME_DAY, datetime expirationTime = 0)
  {
   double volume = ComputeLot(riskFactor);
   double normalPrice = NormalizeDouble(price, _Digits);
   double normalStopLoss = NormalizeDouble(stopLoss,_Digits);
   double normalTakeProfit = NormalizeDouble(takeProfit,_Digits);

   trade.SellStop(volume, _Symbol, normalPrice, normalStopLoss, normalTakeProfit, typeMime, expirationTime, "SellStop");
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrade* CreateTradeWithDefaults(
   ulong magic = 34567,
   ENUM_ORDER_TYPE_FILLING filling = ORDER_FILLING_FOK,
   ulong deviation = 100,
   ENUM_LOG_LEVELS logLevel = LOG_LEVEL_ALL
)
  {
   CTrade *trade = new CTrade();
   trade.SetExpertMagicNumber(magic);
   trade.SetTypeFilling(filling);
   trade.SetDeviationInPoints(deviation);
   trade.LogLevel(logLevel);
   return trade;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ComputeLot(double riskFactor)
  {
   double contractSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);
   double minLotSize = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);

   return MathMax(minLotSize,MathRound(riskFactor*balance/contractSize*100)/100);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Volume()
  {
   double volumeArray[];
   int VolumeDefinition = iVolumes(_Symbol, _Period, VOLUME_TICK);
   ArraySetAsSeries(volumeArray, true);

   CopyBuffer(VolumeDefinition, 0, 0, 3, volumeArray);
   float CurrentVolume = volumeArray[0];
   float LastVolume = volumeArray[1];

   return LastVolume;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Compute Average True Range in points, default period = PERIOD_D1                           |
//+------------------------------------------------------------------+
int ComputeATR(int lookBack, ENUM_TIMEFRAMES period = PERIOD_D1)
  {
   MqlRates ATRBars[];  //create an array for the price data
   CopyRates(Symbol(),period,1,lookBack+1,ATRBars); //fill the array with price data// Get bars

   double sum=0.0;
   for(int i=0; i<lookBack; i++)
     {
      sum += MathAbs(ATRBars[i].close-ATRBars[i].open);
     }

   return (sum/lookBack/_Point);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool outsideTradingHours(int START_HR,int STOP_HR)
  {
   MqlDateTime Time;
   TimeCurrent(Time);

   if(START_HR>STOP_HR)
      return (Time.hour < START_HR && Time.hour > STOP_HR);

   if(START_HR<STOP_HR)
      return (Time.hour > START_HR && Time.hour < STOP_HR);

   return false;
  }
//+------------------------------------------------------------------+
void ModifyTrade(long ticket,double newTP, double newSL)
  {
   MqlTradeRequest mrequest;  // To be used for sending our trade requests
   MqlTradeResult mresult;    // To be used to get our trade results
   ZeroMemory(mrequest);

   mrequest.action  =TRADE_ACTION_SLTP; // type of trade operation
   mrequest.position=ticket;   // ticket of the position
   mrequest.tp      =NormalizeDouble(newTP,_Digits);                // Take Profit of the position
   mrequest.sl      =NormalizeDouble(newSL,_Digits);                // Take Profit of the position

   OrderSend(mrequest,mresult);
  }
//+------------------------------------------------------------------+
void CloseTrade(long ticket)
  {
   CTrade m_trade;
   m_trade.PositionClose(ticket);
  }
//+------------------------------------------------------------------+
