//+------------------------------------------------------------------+
//|                                                         MyEA.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//--- input parameters
input double RiskFactor=0.2;
input int      MinBars=24;
input int      MaxBars=96;
input double   MaxVolume=2000;
input double TPMultiplier=0.5;
input double SLMultiplier=1.0;

bool insideBounds=false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Check MaxBars > MinBars
   if(!(MaxBars>MinBars))
     {
      Alert("Set MaxBars higher than MinBars");
      return(INIT_FAILED);
     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

// Do we have enough bars to work with
   if(Bars(_Symbol,_Period)<MaxBars) // if total bars is less than 60 bars
     {
      Alert("We don't have enough bars, EA will now exit!!");
      return;
     }


   MqlRates PriceInformation[];  //create an array for the price data

   ArraySetAsSeries(PriceInformation,true);  //sort the array current candle downwards
   int Data = CopyRates(Symbol(),Period(),MinBars,MaxBars-MinBars,PriceInformation); //fill the array with price data

// Create Resistance Line
   ObjectCreate(0,"Resistance",OBJ_HLINE,0,0,0); //set object properties
   ObjectSetInteger(0,"Resistance",OBJPROP_WIDTH,2);              //set object width
   ObjectSetInteger(0,"Resistance",OBJPROP_COLOR,clrRed);      //set object colour
   int HighestCandle;      //create variable for highest price
   double High[];           //create array for price data
   ArraySetAsSeries(High,true);     //sort array from current candle downwards
   CopyHigh(Symbol(),Period(),MinBars,MaxBars-MinBars,High);    //fill the array with the high prices
   HighestCandle = ArrayMaximum(High,0,MaxBars-MinBars);  //get the highest candle price
   ObjectMove(0,"Resistance",0,0,PriceInformation[HighestCandle].high);     //move the line

// Create Support Line
   ObjectCreate(0,"Support",OBJ_HLINE,0,0,0); //set object properties
   ObjectSetInteger(0,"Support",OBJPROP_WIDTH,2);              //set object width
   ObjectSetInteger(0,"Support",OBJPROP_COLOR,clrBlue);      //set object colour
   int LowestCandle;      //create variable for highest price
   double Low[];           //create array for price data
   ArraySetAsSeries(Low,true);     //sort array from current candle downwards
   CopyLow(Symbol(),Period(),MinBars,MaxBars-MinBars,Low);    //fill the array with the high prices
   LowestCandle = ArrayMinimum(Low,0,MaxBars-MinBars);  //get the lowest candle price
   ObjectMove(0,"Support",0,0,PriceInformation[LowestCandle].low);     //move the line

   if(PositionSelect(_Symbol)==true)   // if we already have an opened position, return
      return;

   MqlTick latest_price;     // To be used for getting recent/latest price quotes
   if(!SymbolInfoTick(_Symbol,latest_price))
     {
      Alert("Error getting the latest price quote - error:",GetLastError(),"!!");
      return;
     }

// If price is within bounds reset flag
   if(latest_price.bid>=PriceInformation[LowestCandle].low && latest_price.ask<=PriceInformation[HighestCandle].high)
      insideBounds = true;

// If no trade but the price is outside bounds, return
   if(!insideBounds)
      return;

// If enough volume, send order
   if(TooMuchVolume())
      return;

//--- Get the last price quote using the MQL5 MqlTick Structure

// Place Buy if price hits support
   if(latest_price.ask<PriceInformation[LowestCandle].low)
     {
      double TPdiff = PriceInformation[HighestCandle].high-latest_price.ask;
      double TP = latest_price.ask + TPMultiplier*TPdiff;
      double SL = latest_price.ask - SLMultiplier*TPdiff;

      PlaceTrade(latest_price.ask,SL,TP,ORDER_TYPE_BUY);

      insideBounds = false;
     }

// Place Sell if price hits resistance
   if(latest_price.bid>PriceInformation[HighestCandle].high)
     {
      double TPdiff = latest_price.bid-PriceInformation[LowestCandle].low;
      double TP = latest_price.bid - TPMultiplier*TPdiff;
      double SL = latest_price.bid + SLMultiplier*TPdiff;

      PlaceTrade(latest_price.bid,SL,TP,ORDER_TYPE_SELL);

      insideBounds = false;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlaceTrade(double price,double SL,double TP,int orderType)
  {
// Create traderequest
   MqlTradeRequest mrequest;  // To be used for sending our trade requests
   MqlTradeResult mresult;    // To be used to get our trade results
   ZeroMemory(mrequest);

   mrequest.action = TRADE_ACTION_DEAL;                                 // immediate order execution
   mrequest.price = NormalizeDouble(price,_Digits);          // latest Bid price
   mrequest.sl = NormalizeDouble(SL,_Digits); // Stop Loss
   mrequest.tp = NormalizeDouble(TP,_Digits); // Take Profit
   mrequest.symbol = _Symbol;                                         // currency pair
   mrequest.volume = ComputeLot();                                  // number of lots to trade
   mrequest.magic = 34567;                                        // Order Magic Number
   mrequest.type= orderType;                                     // Sell Order
   mrequest.type_filling = ORDER_FILLING_FOK;                          // Order execution type
   mrequest.deviation=100;                                           // Deviation from current price
//--- send order

   OrderSend(mrequest,mresult);

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TooMuchVolume()
  {
   double myPriceArray[];
   int VolumeDefinition = iVolumes(_Symbol, _Period, VOLUME_TICK);
   ArraySetAsSeries(myPriceArray, true);

   CopyBuffer(VolumeDefinition, 0, 0, 3, myPriceArray);
   float CurrentVolume = myPriceArray[0];
   float LastVolume = myPriceArray[1];

   return CurrentVolume > MaxVolume;
  }

//+------------------------------------------------------------------+
double ComputeLot()
  {
   double contractSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);
   double minLotSize = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);

   return MathMax(minLotSize,MathRound(RiskFactor*balance/contractSize*100)/100);
  }
//+------------------------------------------------------------------+
