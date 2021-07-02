//+------------------------------------------------------------------+
//|                                                     Plotting.mqh |
//|                       Copyright 2021, Zjansson Technologies Ltd. |
//|                              https://github.com/Entreco/forex_ea |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Zjansson Technologies Ltd."
#property link      "https://github.com/Entreco/forex_ea"
#property version   "1.00"

#include <Math\Stat\Math.mqh>;

//+------------------------------------------------------------------+
//| Plot Horizontal Line                                             |
//+------------------------------------------------------------------+
void PlotHorizontal(const string name, double price, long line) export
  {
   ObjectCreate(0, name,OBJ_HLINE,0,0,0);        //set object properties
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);     //set object width
   ObjectSetInteger(0,name,OBJPROP_COLOR, line); //set object colour
   ObjectMove(0,name,0,0,price);                 //move the line
  }

//+------------------------------------------------------------------+
//| Plot VLINE on current Time                                       |
//+------------------------------------------------------------------+
void PlotVertical()
  {
   ObjectCreate(0,TimeToString(TimeCurrent()),OBJ_VLINE,0,TimeCurrent(),0);
  }

//+------------------------------------------------------------------+
//|    PlotResistanceTrend                                           |
//+------------------------------------------------------------------+
void PlotResistanceTrend(const MqlRates &rates[], int lookBack = 10, long line = clrRed)
  {

   double Highs[];
   //ArraySetAsSeries(Highs, false);
   CopyHigh(_Symbol, PERIOD_CURRENT, 0, lookBack, Highs);
   
   int highIndex;
   
   highIndex = ArrayMaximum(Highs);
   MqlRates top1 = rates[highIndex];
   Highs[highIndex] = 0;
   
   highIndex = ArrayMaximum(Highs);
   MqlRates top2 = rates[highIndex];
   Highs[highIndex] = 0;
   
   const string name = "Resistance Trend";
   
   ObjectCreate(0,name,OBJ_TREND,0, top1.time, top1.high, top2.time, top2.high);
   ObjectSetInteger(0,name,OBJPROP_COLOR,line);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,true);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);
   
  }
  
//+------------------------------------------------------------------+
//|    PlotSupportTrend                                              |
//+------------------------------------------------------------------+
void PlotSupportTrend(const MqlRates &rates[], int lookBack = 10, long line = clrBlue)
  {

   double Lows[];
   //ArraySetAsSeries(Lows, false);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, lookBack, Lows);
   
   int lowIndex;
   
   lowIndex = ArrayMinimum(Lows);
   MqlRates bottom1 = rates[lowIndex];
   Lows[lowIndex] = INT_MAX;
   
   lowIndex = ArrayMinimum(Lows);
   MqlRates bottom2 = rates[lowIndex];
   Lows[lowIndex] = INT_MAX;
   
   const string name = "Support Trend";
   
   ObjectCreate(0,name,OBJ_TREND,0, bottom1.time, bottom1.low, bottom2.time, bottom2.low);
   ObjectSetInteger(0,name,OBJPROP_COLOR,line);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,true);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);

  }

//+------------------------------------------------------------------+
//| Fit line                                                         |
//+------------------------------------------------------------------+
void FitLine(const double &rates[]) export
  {
   double avg = MathAverageDeviation(rates);
   printf(avg);
  }
//+------------------------------------------------------------------+
