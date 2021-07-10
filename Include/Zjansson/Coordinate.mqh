//+------------------------------------------------------------------+
//|                                                   Coordinate.mqh |
//|                       Copyright 2021, Zjansson Technologies Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Zjansson Technologies Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Object.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Coordinate : public CObject
  {
private:

public:
   datetime          time;
   double            price;
                     Coordinate(const datetime, const double);
                    ~Coordinate();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Coordinate::Coordinate(const datetime _time, double _price)
  {
   time = _time;
   price = _price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Coordinate::~Coordinate()
  {
  }
//+------------------------------------------------------------------+
