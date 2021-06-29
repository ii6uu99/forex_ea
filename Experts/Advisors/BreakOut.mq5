//+------------------------------------------------------------------+
//|                                                     Reversal.mq5 |
//|                       Copyright 2021, Zjansson Technologies Ltd. |
//|                              https://github.com/Entreco/forex_ea |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Zjansson Technologies Ltd."
#property link      "https://github.com/Entreco/forex_ea"
#property version   "1.00"

#include "../../Include/Plotting.mqh";
#include "../../Include/Trading.mqh";

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

bool outsideBounds =false;

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
   double resistance = FindResistance(PriceInformation, MinBars, MaxBars-MinBars);
   PlotHorizontal("Resistance", resistance, clrRed);

// Create Support Line
   double support = FindSupport(PriceInformation, MinBars, MaxBars-MinBars);
   PlotHorizontal("Support", support, clrBlue);

// Dont trade if outside trading hours
   if(outsideTradingHours(START_HOUR,STOP_HOUR))
      return;

// Dont Trade if trade already active
   if(PositionSelect(_Symbol)==true)   // if we already have an opened position, return
      return;

// Get price
   MqlTick latest_price;     // To be used for getting recent/latest price quotes
   SymbolInfoTick(_Symbol,latest_price); // Get latest price

// Reset outsideBounds flag condition
   if(latest_price.bid>=support && latest_price.ask<=resistance)
      outsideBounds=false;

// If outside bounds flag set, return
   if(outsideBounds)
      return;

// If too much volume, abort
   if(Volume() < MinVolume || Volume() > MaxVolume)
      return;

// Place Buy if price breaks resistance
   if(latest_price.bid>resistance)
     {
      double TPdiff = latest_price.ask-support;
      double TP = latest_price.ask + TPMultiplier*TPdiff;
      double SL = latest_price.ask - SLMultiplier*TPdiff;

      //PlaceTrade(latest_price.ask,SL,TP,ORDER_TYPE_BUY, RiskFactor);
      Buy(latest_price.bid, SL, TP, RiskFactor);

      outsideBounds = true;
     }

// Place Sell if price breaks support
   if(latest_price.ask<support)
     {
      double TPdiff = resistance-latest_price.bid;
      double TP = latest_price.bid - TPMultiplier*TPdiff;
      double SL = latest_price.bid + SLMultiplier*TPdiff;

      //PlaceTrade(latest_price.bid,SL,TP,ORDER_TYPE_SELL, RiskFactor);
      Sell(latest_price.bid, SL, TP, RiskFactor);

      outsideBounds = true;
     }
  }

//+------------------------------------------------------------------+
