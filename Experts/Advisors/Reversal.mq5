//+------------------------------------------------------------------+
//|                                                     Reversal.mq5 |
//|                       Copyright 2021, Zjansson Technologies Ltd. |
//|                              https://github.com/Entreco/forex_ea |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Zjansson Technologies Ltd."
#property link      "https://github.com/Entreco/forex_ea"
#property version   "1.00"

#include "../../Include/Zjansson/Coordinate.mqh"
#include "../../Include/Zjansson/Plotting.mqh"
#include "../../Include/Zjansson/Trading.mqh"

//--- input parameters
input double RiskFactor=0.2;
input int      MinBars=24;
input int      MaxBars=96;
input double   MinVolume=0;
input double   MaxVolume=10000;
input double TPMultiplier=0.5;
input double SLMultiplier=1.0;
input int START_HOUR = 0;
input int STOP_HOUR = 24;

bool insideBounds=false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Do we have enough bars to work with
   if(Bars(_Symbol,_Period)<MaxBars) // if total bars is less than 60 bars
      return(INIT_FAILED);

// Check MaxBars > MinBars
   if(MinBars>=MaxBars)
      return(INIT_FAILED);

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
   MqlRates PriceInformation[];  //create an array for the price data
   ArraySetAsSeries(PriceInformation,true);  //sort the array current candle downwards
   CopyRates(Symbol(),Period(),MinBars,MaxBars-MinBars,PriceInformation); //fill the array with price data

// Create Resistance Line
   Coordinate *resistance = FindMaximum(MinBars, MaxBars-MinBars);
   PlotHorizontal("Resistance", resistance.price, clrRed);

// Create Support Line
   Coordinate *support = FindMinimum(MinBars, MaxBars-MinBars);
   PlotHorizontal("Support", support.price, clrBlue);

// Plot Trends
   Trend *resistanceTrend = FindResistanceTrend(MinBars, MaxBars);
   PlotTrend("Resistance Trend", resistanceTrend, clrDarkRed);

   Trend *supportTrend = FindSupportTrend(MinBars, MaxBars);
   PlotTrend("Support Trend", supportTrend, clrDarkBlue);

// Dont trade if outside trading hours
   if(outsideTradingHours(START_HOUR,STOP_HOUR))
      return;

// Dont Trade if trade already active
   if(PositionSelect(_Symbol)==true)   // if we already have an opened position, return
      return;

// If price is within bounds reset flag
   MqlTick latest_price;     // To be used for getting recent/latest price quotes
   SymbolInfoTick(_Symbol,latest_price); // Get latest price
   if(latest_price.bid>=support.price && latest_price.ask<=resistance.price)
      insideBounds = true;

// If current price is not within bounds, return
   if(!insideBounds)
      return;

// If too much volume, abort
   if(Volume() < MinVolume || Volume() > MaxVolume)
      return;

// Place Buy if price breaks support
   if(latest_price.ask<support.price)
     {
      double TPdiff = resistance.price-latest_price.ask;
      double TP = latest_price.ask + TPMultiplier*TPdiff;
      double SL = latest_price.ask - SLMultiplier*TPdiff;

      PlaceTrade(latest_price.ask,SL,TP,ORDER_TYPE_BUY, RiskFactor);

      insideBounds = false;
     }

// Place Sell if price breaks resistance
   if(latest_price.bid>resistance.price)
     {
      double TPdiff = latest_price.bid-support.price;
      double TP = latest_price.bid - TPMultiplier*TPdiff;
      double SL = latest_price.bid + SLMultiplier*TPdiff;

      PlaceTrade(latest_price.bid,SL,TP,ORDER_TYPE_SELL, RiskFactor);

      insideBounds = false;
     }
  }

//+------------------------------------------------------------------+
