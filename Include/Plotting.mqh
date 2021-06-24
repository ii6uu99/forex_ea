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
//| Fit line                                                         |
//+------------------------------------------------------------------+
void FitLine(const double &rates[]) export
{
   double avg = MathAverageDeviation(rates);
   printf(avg);
}