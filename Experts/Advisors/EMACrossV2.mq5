//+------------------------------------------------------------------+
//|                                                   EMACrossV2.mq5 |
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
input int NumberOfRetests = 3;
input int SlowEMAPeriod = 50;
input int FastEMAPeriod = 20;

// Global variables
bool TrendLong = false;
bool EMACrossed = false;
datetime BarCountStartTime;

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

// Check if trade is already open
   if(PositionSelect(_Symbol)==true)
      return;

// Check direction of trend and if an EMACross occured
   if(TrendLong && (fastEMA.Main(0) < slowEMA.Main(0)))
     {
      TrendLong = false;
      EMACrossed = true;
      PlotVertical();
     }
   if(!TrendLong && (fastEMA.Main(0) > slowEMA.Main(0)))
     {
      TrendLong = true;
      EMACrossed = true;
      PlotVertical();
     }

// Get latest price
   MqlTick latest_price;     // To be used for getting recent/latest price quotes
   SymbolInfoTick(_Symbol,latest_price); // Get latest price
   if(EMACrossed)
     {
      if(TrendLong && latest_price.last > slowEMA.Main(0) && latest_price.last > fastEMA.Main(0))
        {
         BarCountStartTime = TimeCurrent();
         EMACrossed = false;
        }
      if(!TrendLong && latest_price.last < slowEMA.Main(0) && latest_price.last < fastEMA.Main(0))
        {
         BarCountStartTime = TimeCurrent();
         EMACrossed = false;
        }
     }


// Get number of bars since EMACross happened
   int  BarsSinceStartTime = Bars(_Symbol,PERIOD_CURRENT,TimeCurrent(),BarCountStartTime);

// Check if number of bars since cross is more than numberofretests allowed
   if(BarsSinceStartTime >= NumberOfRetests)
     {
      // Get the bars
      MqlRates rates[];
      ArraySetAsSeries(rates,true);
      int copied=CopyRates(_Symbol,PERIOD_CURRENT,0,BarsSinceStartTime,rates);
      // Check trend direction and check how many bars hit retest zone
      int retestCounter=0;
      if(TrendLong)
        {
         for(int i=0; i<BarsSinceStartTime; i++)
           {
            if(rates[i].low > slowEMA.Main(0) && rates[i].low < fastEMA.Main(0))
              {
               retestCounter++;
              }

            if(retestCounter>=NumberOfRetests)
              {
               // Place buy
               Print("Buy");
               Buy(&activeTrade, latest_price.ask, 0, 0, RiskFactor);
               break; // exit the for loop -> we're done!
              }

           }
        }

      else // if !Trendlong
        {
         for(int i=0; i<BarsSinceStartTime; i++)
           {
            if(rates[i].high > fastEMA.Main(0) && rates[i].high < slowEMA.Main(0))
              {
               retestCounter++;
              }

            if(retestCounter>=1) //Downtrends are fast -> sell after 1 retest //NumberOfRetests)
              {
               // Place sell
               Print("Sell");
               Sell(&activeTrade, latest_price.bid, 0, 0, RiskFactor);
               break; // exit the for loop -> we're done!
              }

           }
        }

     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
