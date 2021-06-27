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
input int BBandPeriod=20;
input int SlowEMAPeriod = 40;
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

// Determine Trend Direction and EMA Cross
   bool EMACross = false;
   if(!TrendLong)
     {
      if(fastEMA.Main(1) > slowEMA.Main(1))
        {
         TrendLong = true;
         EMACross = true;
        }
     }
   else
     {
      if(fastEMA.Main(1) < slowEMA.Main(1))
        {
         TrendLong = false;
         EMACross = true;
        }
     }

// Draw line where EMACross happened
   if(EMACross)
      ObjectCreate(0,TimeToString(TimeCurrent()),OBJ_VLINE,0,TimeCurrent(),0);

// Dont Trade if trade already active
   if(PositionSelect(_Symbol)==true)   // if we already have an opened position, return
      if(EMACross)
         CloseTrade(PositionGetInteger(POSITION_TICKET));
      else
         return;

// Get price
   MqlTick latest_price;     // To be used for getting recent/latest price quotes
   SymbolInfoTick(_Symbol,latest_price); // Get latest price

// Place SELL when EMA's cross and trend changes to short
   if(EMACross && !TrendLong)
     {
      PlaceTrade(latest_price.bid,0,0,ORDER_TYPE_SELL,RiskFactor);
     }
// Place BUY when EMA's cross and trend changes to long
   if(EMACross && TrendLong)
     {
      PlaceTrade(latest_price.ask,0,0,ORDER_TYPE_BUY,RiskFactor);
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
