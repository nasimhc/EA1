//+------------------------------------------------------------------+
//|                                         MACD_ColorHist_Alert.mq4 |
//|                                    Copyright � 2006, Robert Hill |
//|                                                                  |
//+------------------------------------------------------------------+
#property  copyright "Copyright � 2006, Robert Hill"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Blue
#property  indicator_color2  Red

#property indicator_width1 2
#property indicator_width2 2

//---- indicator parameters

extern bool SoundON=False;
extern bool EmailON=false;

extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];
int flagval1 = 0;
int flagval2 = 0;
//---- variables

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(0,ind_buffer1);
   SetIndexDrawBegin(0,SlowEMA);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(1,ind_buffer2);
   SetIndexDrawBegin(1,SignalSMA);

//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+FastEMA+","+SlowEMA+","+SignalSMA+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(int i=0; i<limit; i++)
      ind_buffer1[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);

   for(i=0; i<limit; i++)
      ind_buffer2[i]=iMAOnArray(ind_buffer1,Bars,SignalSMA,0,MODE_SMA,i);

   for(i=0; i<limit; i++)
   {
      if (i == 1)
      {
        if (ind_buffer1[i] > ind_buffer2[i] && ind_buffer1[i+1] <= ind_buffer2[i+1])
        {
         if (flagval1==0)
         {
           flagval1=1;
           flagval2=0;
           if (SoundON) Alert ("Macd Cross Up! ",Symbol()," ",Period()," @ ",Bid); 
           if (EmailON) SendMail("MACD Crossed up", "MACD Crossed up, Date="+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime())+" Symbol="+Symbol()+" Period="+Period());
         }
        }
        else if (ind_buffer1[i] < ind_buffer2[i] && ind_buffer1[i+1] >= ind_buffer2[i+1])
        {
         if (flagval2==0)
         {
          flagval2=1;
          flagval1=0;
          if (SoundON) Alert ("Macd Cross Down! " ,Symbol()," ",Period()," @ ",Bid); 
          if (EmailON) SendMail("MACD Crossed down","MACD Crossed Down, Date="+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime())+" Symbol="+Symbol()+" Period="+Period());
         }
        }
      }
   }
      
   return(0);
  }