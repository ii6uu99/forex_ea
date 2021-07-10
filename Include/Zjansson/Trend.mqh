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

public:
   Coordinate          *previous;
   Coordinate          *current;
                     Trend(Coordinate *previous, Coordinate *current);
                    ~Trend();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trend::Trend(Coordinate *_previous, Coordinate *_current)
  {
   previous = _previous;
   current = _current;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trend::~Trend()
  {
  }
//+------------------------------------------------------------------+
