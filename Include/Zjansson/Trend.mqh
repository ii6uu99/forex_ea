//+------------------------------------------------------------------+
//|                                                        Trend.mqh |
//|                       Copyright 2021, Zjansson Technologies Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Zjansson Technologies Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Object.mqh>
#include "Coordinate.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Trend : public CObject
  {
private:
   double            a;
   double            b;
   datetime          startTime;
public:
   Coordinate*        start;
   Coordinate*        end;
                     Trend(double a, double b, datetime start, datetime end, int period);
                     Trend(Coordinate *previous, Coordinate *current);
   double            Predict(datetime);
                    ~Trend();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trend::Trend(double _a,double _b, datetime _start, datetime _end, int _period)
  {
   a = _a;
   b = _b;

   startTime=_end;

   start = new Coordinate(_start, a*-_period+b);
   end = new Coordinate(_end, a*0+b);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trend::Trend(Coordinate *_previous, Coordinate *_current)
  {

   if(_current.time - _previous.time == 0.0)
     {
      // To avoid division by zero - default to 0.0
      a = 0.0;
      b = 0.0;
     }
   else
     {
      a = (_current.price - _previous.price) / (_current.time - _previous.time);
      b = _current.price - (a * _current.time);
     }


   startTime=_current.time;

   start = _previous;
   end = _current;
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




//+------------------------------------------------------------------+
//| Finds Maximum in Array                                           |
//+------------------------------------------------------------------+
Coordinate* FindMaximum(int start, int count)
  {
   int HighestCandle;
   double High[];
   ArraySetAsSeries(High,true);
   CopyHigh(_Symbol,PERIOD_CURRENT,start,count,High);

   datetime Times[];
   ArraySetAsSeries(Times,true);
   CopyTime(_Symbol, PERIOD_CURRENT,start, count, Times);

   HighestCandle = ArrayMaximum(High,0,count);

   datetime stamp = Times[HighestCandle];
   double price = High[HighestCandle];

   return new Coordinate(stamp, price);
  }

//+------------------------------------------------------------------+
//| Finds Minimum in Array                                           |
//+------------------------------------------------------------------+
Coordinate* FindMinimum(int start, int count)
  {
   int LowestCandle;
   double Low[];
   ArraySetAsSeries(Low,true);
   CopyLow(_Symbol,PERIOD_CURRENT,start,count,Low);

   datetime Times[];
   ArraySetAsSeries(Times,true);
   CopyTime(_Symbol, PERIOD_CURRENT,start, count, Times);

   LowestCandle = ArrayMinimum(Low,0,count);

   datetime stamp = Times[LowestCandle];
   double price = Low[LowestCandle];

   return new Coordinate(stamp, price);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Finds Resistance Trend - Finds 2 Maxima in different time windows|
//+------------------------------------------------------------------+
Trend* FindResistanceTrend(int start, int count, double weight = 0.3)
  {
   int split = (1.0 * count-start)*weight;
   Coordinate *current = FindMaximum(start, split);
   Coordinate *previous = FindMaximum(count - split, split);

   return new Trend(previous, current);
  }

//+------------------------------------------------------------------+
//| Finds Support Trend - Finds 2 Minima in different time windows   |
//+------------------------------------------------------------------+
Trend* FindSupportTrend(int start, int count, double weight = 0.3)
  {
   int split = (1.0 * count-start)*weight;
   Coordinate *current = FindMinimum(start, split);
   Coordinate *previous= FindMinimum(count - split, split);

   return new Trend(previous, current);
  }

//+------------------------------------------------------------------+
//| Fit line through Highs                                           |
//+------------------------------------------------------------------+
Trend* FitHighTrend(int period, int shift = 1)
  {

// Prepare Arrays
   double High[];
   ArraySetAsSeries(High,true);
   CopyHigh(_Symbol,PERIOD_CURRENT,shift,period,High);

   return FitLine(High, period, shift);
  }

//+------------------------------------------------------------------+
//| Fit line through Low                                             |
//+------------------------------------------------------------------+
Trend* FitLowTrend(int period, int shift = 1)
  {

// Prepare Arrays
   double Low[];
   ArraySetAsSeries(Low,true);
   CopyLow(_Symbol,PERIOD_CURRENT,shift,period,Low);

   return FitLine(Low, period, shift);
  }

//+------------------------------------------------------------------+
//| Fit line through Open                                            |
//+------------------------------------------------------------------+
Trend* FitOpenTrend(int period, int shift = 1)
  {

// Prepare Arrays
   double Open[];
   ArraySetAsSeries(Open,true);
   CopyOpen(_Symbol,PERIOD_CURRENT,shift,period,Open);

   return FitLine(Open, period, shift);
  }

//+------------------------------------------------------------------+
//| Fit line through Close                                           |
//+------------------------------------------------------------------+
Trend* FitCloseTrend(int period, int shift = 1)
  {

// Prepare Arrays
   double Close[];
   ArraySetAsSeries(Close,true);
   CopyClose(_Symbol,PERIOD_CURRENT,shift,period,Close);

   return FitLine(Close, period, shift);
  }

//+------------------------------------------------------------------+
//| Fit line through array, array needs to be sorted in time         |
//+------------------------------------------------------------------+
Trend* FitLine(const double &data[], int period, int shift = 1)
  {

   datetime Times[];
   ArraySetAsSeries(Times,true);
   CopyTime(_Symbol,PERIOD_CURRENT,shift,period,Times);

// Prepare variables
   double sumY=0.0;
   double sumX=0.0;
   double sumXY=0.0;
   double sumX2=0.0;
   double Y=0.0;
   double X=0;

   for(int bar=0; bar<period; bar++)
     {
      X=Times[bar];
      Y=data[bar];
      sumX+=X;
      sumY+=Y;
      sumXY+=X*Y;
      sumX2+=MathPow(X, 2);
      X++;
     }

   double a=(sumX*sumY-period*sumXY)/(MathPow(sumX, 2)-period*sumX2);
   double b=(sumY-a*sumX)/period;

   return new Trend(a, b, Times[period-1], Times[0], period);
  }


//+------------------------------------------------------------------+
//| Returns the Average from an Array of Double's                    |
//+------------------------------------------------------------------+
double AverageDouble(const double &inputs[])
  {
   double sum=0.0;
   int size = ArraySize(inputs);
   for(int i=0; i<size; i++)
     {
      sum+=inputs[i];
     }
   return sum / size;
  }

//+------------------------------------------------------------------+
//| Returns the Average from an Array of DateTime's                  |
//+------------------------------------------------------------------+
datetime AverageDateTime(const datetime &inputs[])
  {
   double sum=0.0;
   int size = ArraySize(inputs);
   for(int i=0; i<size; i++)
     {
      sum+=inputs[i];
     }
   return sum / size;
  }
//+------------------------------------------------------------------+
