//+------------------------------------------------------------------+
//|                                                       BBands.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Indicators\Trend.mqh>
#include "../../Include/Zjansson/Plotting.mqh";
#include "../../Include/Zjansson/Trading.mqh";

//--- input parameters
input double RiskFactor = 0.2;
input int      MinBars=24;
input int      MaxBars=96;
input int SlowEMAPeriod = 40;
input int FastEMAPeriod = 5;

bool TrendLong = false;

CTrade activeTrade;
CiMA slowEMA;
CiMA fastEMA;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   slowEMA.Create(_Symbol,PERIOD_CURRENT,SlowEMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   fastEMA.Create(_Symbol,PERIOD_CURRENT,FastEMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   activeTrade = CreateTradeWithDefaults();

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
// Refresh indicators
   slowEMA.Refresh(OBJ_ALL_PERIODS);
   fastEMA.Refresh(OBJ_ALL_PERIODS);

   MqlRates PriceInformation[];  //create an array for the price data
   ArraySetAsSeries(PriceInformation,true);  //sort the array current candle downwards
   CopyRates(Symbol(),Period(),MinBars,MaxBars-MinBars,PriceInformation); //fill the array with price data

// Create Resistance Line
   Coordinate *resistance = FindMaximum(MinBars, MaxBars-MinBars);
   PlotHorizontal("Resistance", resistance.price, clrRed);

// Create Support Line
   Coordinate *support = FindMinimum(MinBars, MaxBars-MinBars);
   PlotHorizontal("Support", support.price, clrBlue);

// Determine Trend Direction and EMA Cross
   bool EMACross = false;
   if(!TrendLong)
     {
      if(fastEMA.Main(1) > slowEMA.Main(1))
        {
         TrendLong = true;
         EMACross = true;
         PlotVertical();
        }
     }
   else
     {
      if(fastEMA.Main(1) < slowEMA.Main(1))
        {
         TrendLong = false;
         EMACross = true;
         PlotVertical();
        }
     }


// Dont Trade if trade already active
   if(PositionSelect(_Symbol)==true)   // if we already have an opened position, return
      if(EMACross)
         CloseTrade(&activeTrade, PositionGetInteger(POSITION_TICKET));
      else
         return;

// Get price
   MqlTick latest_price;     // To be used for getting recent/latest price quotes
   SymbolInfoTick(_Symbol,latest_price); // Get latest price

// Place SELL when EMA's cross and trend changes to short
   if(EMACross && !TrendLong)
     {
      //PlaceTrade(latest_price.bid,0,0,ORDER_TYPE_SELL,RiskFactor);
      Sell(&activeTrade, latest_price.bid, 0, 0, RiskFactor);
     }
// Place BUY when EMA's cross and trend changes to long
   if(EMACross && TrendLong)
     {
      //PlaceTrade(latest_price.ask,0,0,ORDER_TYPE_BUY,RiskFactor);
      Buy(&activeTrade, latest_price.ask, 0, 0, RiskFactor);
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
