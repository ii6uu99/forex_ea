//+------------------------------------------------------------------+
//|                                                       BBands.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Indicators\Trend.mqh>
#include "../../Include/Plotting.mqh";
#include "../../Include/Trading.mqh";

//--- input parameters
input double RiskFactor = 0.2;
input int      BBandPeriod=20;
input int SlowEMAPeriod = 120;
input int FastEMAPeriod = 5;

bool TrendLong = false;

CiBands BBand;
CiMA slowEMA;
CiMA fastEMA;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   BBand.Create(_Symbol,PERIOD_CURRENT,BBandPeriod,0,2,PRICE_CLOSE);
   slowEMA.Create(_Symbol,PERIOD_CURRENT,SlowEMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   fastEMA.Create(_Symbol,PERIOD_CURRENT,FastEMAPeriod,0,MODE_EMA,PRICE_CLOSE);

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
   BBand.Refresh(OBJ_ALL_PERIODS);
   slowEMA.Refresh(OBJ_ALL_PERIODS);
   fastEMA.Refresh(OBJ_ALL_PERIODS);

// Dont Trade if trade already active
   if(PositionSelect(_Symbol)==true)   // if we already have an opened position, return
      return;

// Determine Trend Direction and EMA Cross
   bool EMACross = false;
   if(!TrendLong)
     {
      if(fastEMA.Main(1) > slowEMA.Main(1))
        {
         TrendLong = true;
         EMACross = true;
         Print("EMACRoss & Trendlong=true");
        }
     }
   else
     {
      if(fastEMA.Main(1) < slowEMA.Main(1))
        {
         TrendLong = false;
         EMACross = true;
         Print("EMACRoss & Trendlong=false");
        }
     }

// Draw line where EMACross happened
   if(EMACross)
      ObjectCreate(0,TimeToString(TimeCurrent()),OBJ_VLINE,0,TimeCurrent(),0);


// Get price
   MqlTick latest_price;     // To be used for getting recent/latest price quotes
   SymbolInfoTick(_Symbol,latest_price); // Get latest price

// If Price hits upper band place sell
   if((latest_price.bid > BBand.Upper(1)) && !TrendLong)
     {
      double tp = BBand.Base(1);
      double sl = 2*latest_price.bid - tp;
      PlaceTrade(latest_price.bid,sl,tp,ORDER_TYPE_SELL,RiskFactor);
     }
// If Price hits lower band place buy
   if((latest_price.ask < BBand.Lower(1)) && TrendLong)
     {
      double tp = BBand.Base(1);
      double sl = 2*latest_price.ask - tp;
      PlaceTrade(latest_price.ask,sl,tp,ORDER_TYPE_BUY,RiskFactor);
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
