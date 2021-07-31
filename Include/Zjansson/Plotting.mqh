//+------------------------------------------------------------------+
//|                                                     Plotting.mqh |
//|                       Copyright 2021, Zjansson Technologies Ltd. |
//|                              https://github.com/Entreco/forex_ea |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Zjansson Technologies Ltd."
#property link      "https://github.com/Entreco/forex_ea"
#property version   "1.00"

#include "Trend.mqh"
#include <Math\Stat\Math.mqh>

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
void PlotVertical(datetime stamp, long line = clrAzure)
  {
   const string name = TimeToString(stamp);
   ObjectCreate(0,name,OBJ_VLINE,0,stamp,0);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);     //set object width
   ObjectSetInteger(0,name,OBJPROP_COLOR, line); //set object colour
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlotVertical(long line = clrAliceBlue)
  {
   PlotVertical(TimeCurrent(), line);
  }

//+------------------------------------------------------------------+
//| Plot Trend line                                                  |
//+------------------------------------------------------------------+
void PlotTrend(const string name, Trend *trend, long line = clrAquamarine) export
  {
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_TREND, 0, trend.start.time, trend.start.price, trend.end.time, trend.end.price);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);     //set object width
   ObjectSetInteger(0,name,OBJPROP_COLOR, line); //set object colour
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, true);

   PlotDot(DoubleToString(trend.start.time), trend.start, clrAzure);
   PlotDot(DoubleToString(trend.end.time), trend.end, clrAliceBlue);
  }

//+------------------------------------------------------------------+
//| Plot a single Dot                                                |
//+------------------------------------------------------------------+
void PlotDot(const string name, Coordinate *dot, long line = clrAquamarine)
  {
   ObjectCreate(0, name, OBJ_TEXT, 0, dot.time, dot.price);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,12);     //set object width
   ObjectSetInteger(0,name,OBJPROP_COLOR, line); //set object colour
   ObjectSetString(0, name, OBJPROP_TEXT, CharToString(159));
  }
//+------------------------------------------------------------------+
