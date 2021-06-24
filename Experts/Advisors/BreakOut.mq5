//+------------------------------------------------------------------+
//|                                                     BreakOut.mq5 |
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
input int      MaxBars=240;
input double   MinVolume=2000;
input int ADRLookBack=7;
input int ADRMultiplierSL=1;
input int ADRMultiplierTP=1;

bool outsideBounds=false;

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
   ArraySetAsSeries(PriceInformation, true);  //sort the array current candle downwards
   CopyRates(Symbol(),Period(),MinBars,MaxBars-MinBars,PriceInformation); //fill the array with price data

// Create Resistance Line
   double resistance = FindResistance(PriceInformation, MinBars, MaxBars-MinBars);
   PlotHorizontal("Resistance", resistance, clrRed);

// Create Support Line
   double support = FindSupport(PriceInformation, MinBars, MaxBars-MinBars);
   PlotHorizontal("Support", support, clrBlue);
   
   PlotTrend("Schuin", support, clrGreen, 25.0);


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
      outsideBounds = false;

// If no trade but the price is outside bounds, return
   if(outsideBounds)
      return;

// If not enough volume, abort
   if(!VolumeMoreThan(MinVolume))
      return;

//--- Get the last price quote using the MQL5 MqlTick Structure

// Price is outsideBounds (either high or low) and we dont have an active trade --> go trade
   int ADR = ComputeADR(ADRLookBack);

// Place Sell if price breaks support
   if(latest_price.bid<support)
     {
      int loss = ADRMultiplierSL*ADR;
      int profit = ADRMultiplierTP*ADR;
      PlaceTrade(latest_price.bid,loss,profit,ORDER_TYPE_SELL, RiskFactor);

      outsideBounds = true;
     }

// Place Buy if price breaks resistance
   if(latest_price.ask>resistance)
     {
      int loss = -1*ADRMultiplierSL*ADR;
      int profit = -1*ADRMultiplierTP*ADR;
      PlaceTrade(latest_price.ask,loss,profit,ORDER_TYPE_BUY, RiskFactor);

      outsideBounds = true;
     }
  }


//+------------------------------------------------------------------+
