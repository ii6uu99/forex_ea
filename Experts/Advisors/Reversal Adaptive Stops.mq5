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
input int SLpoints = 100;
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
   double resistance = FindResistance(PriceInformation, MinBars, MaxBars-MinBars);
   PlotHorizontal("Resistance", resistance, clrRed);

// Create Support Line
   double support = FindSupport(PriceInformation, MinBars, MaxBars-MinBars);
   PlotHorizontal("Support", support, clrBlue);

// Check if we're ready for a new trade
   if(PositionSelect(_Symbol)==false)
     {
      // Dont trade if outside trading hours
      if(outsideTradingHours(START_HOUR,STOP_HOUR))
         return;

      // If price is within bounds reset flag
      MqlTick latest_price;     // To be used for getting recent/latest price quotes
      SymbolInfoTick(_Symbol,latest_price); // Get latest price
      if(latest_price.bid>=support && latest_price.ask<=resistance)
         insideBounds = true;

      // If current price is not within bounds, return
      if(!insideBounds)
         return;

      // If too much volume, abort
      if(Volume() < MinVolume || Volume() > MaxVolume)
         return;

      // Place Buy if price breaks support
      if(latest_price.ask<support)
        {
         double TP = resistance;
         double SL = support-SLpoints*_Point;

         PlaceTrade(latest_price.ask,SL,TP,ORDER_TYPE_BUY, RiskFactor);

         insideBounds = false;
        }

      // Place Sell if price breaks resistance
      if(latest_price.bid>resistance)
        {
         double TP = support;
         double SL = resistance+SLpoints*_Point;

         PlaceTrade(latest_price.bid,SL,TP,ORDER_TYPE_SELL, RiskFactor);

         insideBounds = false;
        }
     }
   else// If we already have a trade open, see if we need to adapt TP and SL
     {
     double oldTP = PositionGetDouble(POSITION_TP); // Get TP from current trade
     double oldSL = PositionGetDouble(POSITION_SL); // Get SL from current trade
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         double newTP = NormalizeDouble(resistance,_Digits);
         double newSL = NormalizeDouble(support-SLpoints*_Point,_Digits);
         //Check if newSL and newTP are valid
         if

         ModifyTrade(PositionGetInteger(POSITION_TICKET),newSL,newTP);
        }

      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         double newTP = support;
         double newSL = resistance+SLpoints*_Point;
         ModifyTrade(PositionGetInteger(POSITION_TICKET),newSL,newTP);
        }
     }
  }

//+------------------------------------------------------------------+
