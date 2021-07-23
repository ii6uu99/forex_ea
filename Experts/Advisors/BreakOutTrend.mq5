//+------------------------------------------------------------------+
//|                                                BreakOutTrend.mq5 |
//|                       Copyright 2021, Zjansson Technologies Ltd. |
//|                              https://github.com/Entreco/forex_ea |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Zjansson Technologies Ltd."
#property link      "https://github.com/Entreco/forex_ea"
#property version   "1.00"

#include <Zjansson/Trend.mqh>
#include "../../Include/Zjansson/Plotting.mqh";
#include "../../Include/Zjansson/Trading.mqh";

//--- input parameters
input double RiskFactor=0.2;
input int      MinBars=5;
input int      MaxBars=48;
input double   MinVolume=0;
input double   MaxVolume=10000;
input double TPMultiplier=1.0;
input double SLMultiplier=3.0;
input int START_HOUR = 0;
input int STOP_HOUR = 24;

CTrade activeTrade;
int indicatorHandle;

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

// Init LinearRegresssion Channel indicator
   indicatorHandle = iCustom(_Symbol, PERIOD_CURRENT, "lrchannel2", 72, 1);

   iCustom(_Symbol, PERIOD_CURRENT, "AutoTrend");

// Init CTrade with Default Options
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
   MqlRates PriceInformation[];  //create an array for the price data
   ArraySetAsSeries(PriceInformation,true);  //sort the array current candle downwards
   CopyRates(_Symbol,PERIOD_CURRENT,1,MaxBars,PriceInformation); //fill the array with price data

// Extract Data from Indicator
   double data[];
   CopyBuffer(indicatorHandle, 0, 1, 72, data); // Copy 0rd buffer, from 1 to 72
   Trend *indicatorTrend = FitLine(data, 72, 1);
   PlotTrend("Regression Trend", indicatorTrend, clrPurple);

// Plot Trends
   Trend *highTrend = FindResistanceTrend(3, 48);
   PlotTrend("Resistance Trend", highTrend, clrRed);

   Trend *lowTrend = FindSupportTrend(3, 48);
   PlotTrend("Support Trend", lowTrend, clrBlue);

// Dont trade if outside trading hours
   if(outsideTradingHours(START_HOUR,STOP_HOUR))
      return;

// Dont Trade if trade already active
   if(PositionSelect(_Symbol)==true)
      return;

// Trade only on the first tick of the new bar
//   if(PriceInformation[1].tick_volume>1)
//      return;

// If too much volume, abort
   if(Volume() < MinVolume || Volume() > MaxVolume)
      return;

// Get price
   MqlTick latest_price;     // To be used for getting recent/latest price quotes
   SymbolInfoTick(_Symbol,latest_price); // Get latest price

// Reset outsideBounds flag condition
   double predictedSupportPrice = lowTrend.Predict(TimeCurrent());
   double predictedResistancePrice = highTrend.Predict(TimeCurrent());

// Place Buy if price breaks resistance
   double TPdiff = latest_price.ask-predictedSupportPrice;
   if(latest_price.bid>predictedResistancePrice && TPdiff > 0.0001)
     {
      double TP = latest_price.ask + TPMultiplier*TPdiff;
      double SL = latest_price.ask - SLMultiplier*TPdiff;

      //PlaceTrade(latest_price.ask,SL,TP,ORDER_TYPE_BUY, RiskFactor);
      Buy(&activeTrade, latest_price.ask, SL, TP, RiskFactor);
      //Open(&activeTrade, latest_price.ask, ORDER_TYPE_BUY, RiskFactor);
     }

// Place Sell if price breaks support
   TPdiff = predictedResistancePrice-latest_price.bid;
   if(latest_price.ask<predictedSupportPrice && TPdiff > 0.0001)
     {
      double TP = latest_price.bid - TPMultiplier*TPdiff;
      double SL = latest_price.bid + SLMultiplier*TPdiff;

      //PlaceTrade(latest_price.bid,SL,TP,ORDER_TYPE_SELL, RiskFactor);
      Sell(&activeTrade, latest_price.bid, SL, TP, RiskFactor);
      //Open(&activeTrade, latest_price.bid, ORDER_TYPE_SELL, RiskFactor);
     }
  }

//+------------------------------------------------------------------+
