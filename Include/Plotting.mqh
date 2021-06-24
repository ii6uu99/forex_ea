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
//|                                                                  |
//+------------------------------------------------------------------+
void PlotTrend(const string name, double price, long line = clrAqua, double angle = 45.0)
  {
   ObjectCreate(0, name, OBJ_TRENDBYANGLE, 0, 0, 1, price);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);     //set object width
   ObjectSetInteger(0,name,OBJPROP_COLOR, line); //set object colour
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);
//ObjectSetDouble(0,name,OBJPROP_ANGLE,angle);  //set angle

   double max_price=ChartGetDouble(0,CHART_PRICE_MAX);
   double min_price=ChartGetDouble(0,CHART_PRICE_MIN);
   ObjectCreate(0,"Rect",OBJ_RECTANGLE, 0, 0, min_price, 1000, max_price);
   ObjectSetInteger(0,"Rect",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,"Rect",OBJPROP_WIDTH,2);
   ObjectSetInteger(0,"Rect",OBJPROP_FILL,true);
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
