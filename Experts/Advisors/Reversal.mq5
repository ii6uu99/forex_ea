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
   CopyRates(Symbol(),Period(),MinBars,MaxBars-MinBars,PriceInformation); //fill the array with price data

// Create Resistance Line
   double resistance = FindResistance(PriceInformation, MinBars, MaxBars-MinBars);
   PlotHorizontal("Resistance", resistance, clrRed);

// Create Support Line
   double support = FindSupport(PriceInformation, MinBars, MaxBars-MinBars);
   PlotHorizontal("Support", support, clrBlue);




   if(PositionSelect(_Symbol)==true)   // if we already have an opened position, return
      return;

   MqlTick latest_price;     // To be used for getting recent/latest price quotes
   if(!SymbolInfoTick(_Symbol,latest_price))
     {
      Alert("Error getting the latest price quote - error:",GetLastError(),"!!");
      return;
     }

// If price is within bounds reset flag
   if(latest_price.bid>=support && latest_price.ask<=resistance)
      insideBounds = true;

// If no trade but the price is outside bounds, return
   if(!insideBounds)
      return;

// If too much volume, abort
   if(VolumeMoreThan(MaxVolume))
      return;

//--- Get the last price quote using the MQL5 MqlTick Structure

// Place Buy if price hits support
   if(latest_price.ask<support)
     {
      double TPdiff = resistance-latest_price.ask;
      double TP = latest_price.ask + TPMultiplier*TPdiff;
      double SL = latest_price.ask - SLMultiplier*TPdiff;

      PlaceTrade(latest_price.ask,SL,TP,ORDER_TYPE_BUY, RiskFactor);

      insideBounds = false;
     }

// Place Sell if price hits resistance
   if(latest_price.bid>resistance)
     {
      double TPdiff = latest_price.bid-support;
      double TP = latest_price.bid - TPMultiplier*TPdiff;
      double SL = latest_price.bid + SLMultiplier*TPdiff;

      PlaceTrade(latest_price.bid,SL,TP,ORDER_TYPE_SELL, RiskFactor);

      insideBounds = false;
     }
  }

//+------------------------------------------------------------------+
