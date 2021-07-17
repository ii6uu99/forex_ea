//+------------------------------------------------------------------+
//|                                         LinearRegressionLine.mq5 |
//|                                   Copyright © 2008, Antonuk Oleg |
//|                                            antonukoleg@gmail.com |
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2008, Antonuk Oleg"
//--- Copyright
#property link      "antonukoleg@gmail.com"
//---- indicator description
#property description "Drawing linear regression line using the indicator buffer"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers
#property indicator_buffers 1 
//--- one plot is used
#property indicator_plots   1
//+-------------------------------------------------+
//| LinearRegression drawing parameters             |
//+-------------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- DeepPink color is used as the indicator line color
#property indicator_color1  clrDeepPink
//--- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator 1 line width is equal to 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "LinearRegressionLine"
//+-------------------------------------------------+
//|  Declaration of constants                       |
//+-------------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-------------------------------------------------+
//| Indicator input parameters                      |
//+-------------------------------------------------+
input uint LinearRegressionPeriod=50; // Period of LinearRegression
input int Shift=0;                    // Horizontal shift of the indicator in bars
//+-------------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double LineBuffer[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(LinearRegressionPeriod+1);
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(LineBuffer,true);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"LinearRegression(",LinearRegressionPeriod,")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[])    // price array for the indicator calculation
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(RESET);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total-min_rates_total);
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(price,true);
//--- declaration of integer variables
   int limit;
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1;  // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for calculation of new bars only
//--- the main loop of indicator reset
   for(int bar=limit; bar>=int(LinearRegressionPeriod) && !IsStopped(); bar--) LineBuffer[bar]=0.0;
//--- declarations of local variables 
   double sumy=0.0;
   double sumx=0.0;
   double sumxy=0.0;
   double sumx2=0.0;
//---
   for(int bar=0; bar<int(LinearRegressionPeriod); bar++)
     {
      sumy+=price[bar];
      sumxy+=price[bar]*bar;
      sumx+=bar;
      sumx2+=bar*bar;
     }
//---
   double c=sumx2*LinearRegressionPeriod-sumx*sumx;
//---
   if(!c)
     {
      Alert("LinearRegression error: can\'t resolve equation");
      return(RESET);
     }
//---
   double b=(sumxy*LinearRegressionPeriod-sumx*sumy)/c;
   double a=(sumy-sumx*b)/LinearRegressionPeriod;
//--- drawing Linear regression trendline in indicator buffer
   for(int bar=0; bar<int(LinearRegressionPeriod); bar++) LineBuffer[bar]=a+b*bar;
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
