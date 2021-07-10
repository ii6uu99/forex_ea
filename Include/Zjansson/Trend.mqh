//+------------------------------------------------------------------+
//|                                                        Trend.mqh |
//|                       Copyright 2021, Zjansson Technologies Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Zjansson Technologies Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Object.mqh>
#include <Zjansson\Coordinate.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Trend : public CObject
  {
private:
   double            a;
   double            b;
public:
   Coordinate          *previous;
   Coordinate          *current;
                     Trend(Coordinate *previous, Coordinate *current);
   double            Predict(datetime);
                    ~Trend();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trend::Trend(Coordinate *_previous, Coordinate *_current)
  {
   previous = _previous;
   current = _current;

   if(current.time - previous.time == 0.0)
     { // To avoid division by zero - default to 0.0
      a = 0.0;
      b = 0.0;
     }
   else
     {
      a = (current.price - previous.price) / (current.time - previous.time);
      b = current.price - (a * current.time);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Trend::Predict(const datetime time)
  {
   return (a * time + b);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trend::~Trend()
  {
  }
//+------------------------------------------------------------------+
