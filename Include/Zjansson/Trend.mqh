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
   Coordinate*        start;
   Coordinate*        end;
                     Trend(double a, double b, datetime start, datetime end);
                     Trend(Coordinate *previous, Coordinate *current);
   double            Predict(datetime);
                    ~Trend();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trend::Trend(double _a,double _b, datetime _start, datetime _end)
  {
   a = _a;
   b = _b;

   start = new Coordinate(_start, Predict(_start));
   end = new Coordinate(_end, Predict(_end));
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
//| Fit line through array, array needs to be sorted in time         |
//+------------------------------------------------------------------+
Trend* FitLine(int period)
  {

// Prepare Arrays
   double High[];
   ArraySetAsSeries(High,true);
   CopyHigh(_Symbol,PERIOD_CURRENT,0,period+1,High);
   datetime Times[];
   ArraySetAsSeries(Times,true);
   CopyTime(_Symbol,PERIOD_CURRENT,0,period+1,Times);

// Prepare variables
   double sumy=0.0;
   double sumx=0.0;
   double sumxy=0.0;
   double sumx2=0.0;
   datetime averageX = AverageDateTime(Times);
   double averageY = AverageDouble(High);

   for(int bar=1; bar<=period; bar++)
     {
      datetime x = Times[bar] - averageX;
      double y = High[bar] - averageY;
      sumy += y;
      sumxy += y * bar;
      sumx += bar;
      sumx2 += bar*bar;
     }

// Work In Progres => THIS DOESN'T WORK
   double c=sumx2*period-sumx*sumx;
   double b=(sumxy*period-sumx*sumy)/c;
   double a=(sumy-sumx*b)/period;

   return new Trend(a, b, Times[1], Times[period]);
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
