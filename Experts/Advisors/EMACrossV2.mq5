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

input int NumberOfRetests = 3;
input int SlowEMAPeriod = 50;
input int FastEMAPeriod = 20;

// Global variables
bool TrendLong = false;
datetime EMACrossTime;

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

// Check if trade is already open
   if(PositionSelect(_Symbol)==true)
      return;

// Check direction of trend and if an EMACross occured
   bool EMACross = false;
   if(TrendLong && (fastEMA.Main(0) < slowEMA.Main(0)))
     {
      TrendLong = false;
      EMACross = true;
      EMACrossTime = TimeCurrent();
      ObjectCreate(0,TimeToString(TimeCurrent()),OBJ_VLINE,0,TimeCurrent(),0);
     }
   if(!TrendLong && (fastEMA.Main(0) > slowEMA.Main(0)))
     {
      TrendLong = true;
      EMACross = true;
      EMACrossTime = TimeCurrent();
      ObjectCreate(0,TimeToString(TimeCurrent()),OBJ_VLINE,0,TimeCurrent(),0);
     }

// Get number of bars since EMACross happened
   int  BarsSinceEMACross = Bars(_Symbol,PERIOD_CURRENT,TimeCurrent(),EMACrossTime);

// Check if number of bars since cross is more than numberofretests allowed
   if(BarsSinceEMACross >= NumberOfRetests)
     {
      // Get the bars
      MqlRates rates[];
      ArraySetAsSeries(rates,true);
      int copied=CopyRates(_Symbol,PERIOD_CURRENT,0,BarsSinceEMACross,rates);
      // Check trend direction and check how many bars hit retest zone
      int retestCounter=0;
      if(TrendLong)
        {
         for(int i=0; i<BarsSinceEMACross; i++)
           {
            if(rates[i].low > slowEMA.Main(0) && rates[i].low < fastEMA.Main(0));
              retestCounter++;
           }
         if(retestCounter>=NumberOfRetests)
            // Place buy
            Print("Buy");
            //activeTrade.Buy(0.02);
        }
      else // if !Trendlong
        {
         for(int i=0; i<BarsSinceEMACross; i++)
           {
            if(rates[i].high > fastEMA.Main(0) && rates[i].low < slowEMA.Main(0));
              retestCounter++;
           }
         if(retestCounter>=NumberOfRetests)
            // Place sell
            Print("Sell");
            //activeTrade.Sell(0.02);
        }

     }
  }
//+------------------------------------------------------------------+
