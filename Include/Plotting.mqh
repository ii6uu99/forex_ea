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
//|                                                                  |
//+------------------------------------------------------------------+
void PlotTrend(const string name, double price, long line = clrBlue, double angle = 45.0)
  {

   double max_price=ChartGetDouble(0,CHART_PRICE_MAX);
   double min_price=ChartGetDouble(0,CHART_PRICE_MIN);
   double shiftSize=ChartGetDouble(0, CHART_SHIFT_SIZE);

   double max=TimeCurrent();
   double min= max - shiftSize;

   ObjectCreate(0,name,OBJ_TREND,0,min,min_price,max,max_price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,line);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,false);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);

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
