//Version: 9
//Updated: December 22, 2006
//+------------------------------------------------------------------+
//|                       XP Moving Average                          | 
//|                                                         xpMA3.mq4 |
//|                                         Developed by Coders Guru |
//|                                            http://www.xpworx.com |
//+------------------------------------------------------------------+

#property link      "http://www.xpworx.com"


#property indicator_chart_window
#property indicator_buffers 4
//---
#property indicator_color1  clrGold  //Yellow
#property indicator_color2  clrOrangeRed  //Red
#property indicator_color3  clrDodgerBlue  //Blue
//---
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
//---
#define MODE_DEMA    4
#define MODE_TEMA    5
#define MODE_T3MA    6
#define MODE_JMA     7
#define MODE_HMA     8
#define MODE_DECEMA  9
#define MODE_SALT    10

/* Moving average types constants: */
//------------------------------------
enum maType {
     mSMA,     //Simple moving average
     mEMA,     //Exponential moving average
     mSMMA,    //Smoothed moving average
     mLWMA,    //Linear weighted moving average
     mDEMA,    //Double Exponential moving average
     mTEMA,    //Triple Exponential moving average
     mT3,      //T3 moving average
     mJMA,     //Jurik moving average
     mHMA,     //Hull moving average
     mDECEMA,  //DECEMA moving average
     mSATL     //SALT indicator
};
//------------------------------------*/

/* Applied price constants:
-------------------------------
PRICE_CLOSE    0     Close price. 
PRICE_OPEN     1     Open price. 
PRICE_HIGH     2     High price. 
PRICE_LOW      3     Low price. 
PRICE_MEDIAN   4     Median price, (high+low)/2. 
PRICE_TYPICAL  5     Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6     Weighted close price, (high+low+close+close)/4.
--------------------------------- */


/*extern*/ int    TimeFrame               = 0;
extern   int      MA_Period               = 34;
extern   maType   MA_Type                 = 1;
extern ENUM_APPLIED_PRICE  MA_Applied     = PRICE_CLOSE;
extern   double   T3MA_VolumeFactor       = 0.8;
extern   double   JMA_Phase               = 0;
extern   int      Step_Period             = 4;

extern   bool     DebugMode               = false;

extern string   pro  = "xpMA_v99";
string   ver  = "";


double UpBuffer[];
double DownBuffer[];
double Buffer3[];
double buffer[];
double tempbuffer[];
double matriple[];
double signal[];

int    nShift;   

int init()
{
   DeleteStamp();
   ver = GenVer();
   IndicatorBuffers(7); 

   SetIndexStyle(1,DRAW_LINE);  //,STYLE_DOT,1);
   SetIndexBuffer(2,UpBuffer);
   SetIndexStyle(1,DRAW_LINE);  //,STYLE_DOT,2);
   SetIndexBuffer(1,DownBuffer);
   SetIndexStyle(0,DRAW_LINE);  //,STYLE_DOT,2);
   SetIndexBuffer(0,Buffer3);
   
   SetIndexBuffer(3,signal);
   SetIndexBuffer(4,buffer);
   SetIndexBuffer(5,tempbuffer);
   SetIndexBuffer(6,matriple);
   
   SetIndexLabel(0,"XP Moving Average");
   SetIndexLabel(1,"DownBuffer");
   SetIndexLabel(2,"UpBuffer");
   SetIndexLabel(3,"Signal");
   
    switch(_Period)
      {
        case     1: nShift = 5;   break;    
        case     5: nShift = 7;   break; 
        case    15: nShift = 10;   break; 
        case    30: nShift = 15;  break; 
        case    60: nShift = 20;  break; 
        case   240: nShift = 30;  break; 
        case  1440: nShift = 80;  break; 
        case 10080: nShift = 150; break; 
        case 43200: nShift = 250; break;               
      }
 
   return(0);
}

int deinit()
{
   DeleteStamp();
   return(0);
}



int start()
{
   
   StampVersion(pro,ver,5,20);
   
   int limit;
   int i = 0;
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   switch (MA_Type)
   {
      case 0:
      case 1:
      case 2:
      case 3:
            {
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iMA(NULL,TimeFrame,MA_Period,0,(int)MA_Type,MA_Applied,i);
                  }
            }
            break;
      
      case 4:
            {
                  for(i=0; i<limit; i++)
                  {
                     tempbuffer[i] = iMA(NULL,TimeFrame,MA_Period,0,MODE_EMA,MA_Applied,i);
                  }
                  for(i=0; i<limit; i++)
                  {
                     matriple[i] = iMAOnArray(tempbuffer,0,MA_Period,0,MODE_EMA,i);
                  }
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iMAOnArray(matriple,0,MA_Period,0,MODE_EMA,i);
                  }
            }
            break;
      
      case 5:
            {
                  for(i=0; i<limit; i++)
                  {
                     tempbuffer[i] = iMA(NULL,TimeFrame,MA_Period,0,MODE_EMA,MA_Applied,i);
                  }
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iMAOnArray(tempbuffer,0,MA_Period,0,MODE_EMA,i);
                  }
            }
            break;
      
      case 6:
            {
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iCustom(NULL,TimeFrame,"T3MA",MA_Period,T3MA_VolumeFactor,0,i);
                  }
            }
            break;
      case 7:
            {
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iCustom(NULL,TimeFrame,"JMA",MA_Period,JMA_Phase,0,i);
                  }
            }
            break;
      
      case 8:
            {
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iCustom(NULL,TimeFrame,"HMA",MA_Period,0,i);
                  }
            }
            break;
      
      case 9:
            {
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iCustom(NULL,TimeFrame,"DECEMA_v1",MA_Period,MA_Applied,0,i);
                  }
            }
            break;

      case 10:
            {
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iCustom(NULL,TimeFrame,"SATL",0,i);
                  }
            }
            break;
            
   }

   for(int shift=0; shift<limit; shift++)
   {
       UpBuffer[shift] = buffer[shift];
       DownBuffer[shift] = buffer[shift];
       Buffer3[shift] = buffer[shift];
   }                   
   
   /*for(shift=0; shift<limit; shift++)
   {
      if (buffer[shift]<buffer[shift+1])
      {
         UpBuffer[shift] = EMPTY_VALUE;
      }
      else if (buffer[shift]>buffer[shift+1] )
      {
         DownBuffer[shift] = EMPTY_VALUE;
      } 
     else
      {
         UpBuffer[shift] = CLR_NONE;
         DownBuffer[shift] = CLR_NONE;
      }
   }*/
   
   for(shift=0; shift<limit; shift++)
   {
      double dMA = 0;
      for(int k = shift+1; k <= shift+Step_Period; k++){
         dMA += buffer[k];
      }
      dMA = dMA / Step_Period;

      if (buffer[shift] < dMA)
      {
         UpBuffer[shift] = EMPTY_VALUE;
      }
      else if (buffer[shift]>dMA)
      {
         DownBuffer[shift] = EMPTY_VALUE;
      } 
      else
      {
         UpBuffer[shift] = EMPTY_VALUE;
         DownBuffer[shift] = EMPTY_VALUE;
      }
   }
   for(shift=0; shift<limit; shift++)
   {
         signal[shift]=0;
         if(UpBuffer[shift+1] == EMPTY_VALUE &&  UpBuffer[shift] != EMPTY_VALUE && Buffer3[shift+1] != UpBuffer[shift] )
         {
            signal[shift] = 1;
         }
            
         if(DownBuffer[shift+1] == EMPTY_VALUE &&  DownBuffer[shift] != EMPTY_VALUE && Buffer3[shift+1] != DownBuffer[shift])
         {
            signal[shift] = -1;
         }
   } 
   
   if(DebugMode)
   { 
      TakeScreenShot(40);
   }

   return(0);
}

void TakeScreenShot(int exit_on = -1)
{
   int count = 1;
   
   if(!GlobalVariableCheck("ssc"))
   {
    GlobalVariableSet("ssc",1);
    count = 1;
   }
   else
   {
      count = GlobalVariableGet("ssc") + 1;
      GlobalVariableSet("ssc",count); 
   }
   
   if ( exit_on > 0 && count > exit_on ) return;  //(0);
   
   string filename = "xpMA\\" + "xpMA_" + _Symbol +  "_" + DoubleToStr(count,0) + ".jpg";
   ScreenShot(filename,320,480);
}
string PeriodToText()
{
   switch (_Period)
   {
      case 1:
            return("M1");
            break;
      case 5:
            return("M5");
            break;
      case 15:
            return("M15");
            break;
      case 30:
            return("M30");
            break;
      case 60:
            return("H1");
            break;
      case 240:
            return("H4");
            break;
      case 1440:
            return("D1");
            break;
      case 10080:
            return("W1");
            break;
      case 43200:
            return("MN1");
            break;
   }
   return("Period error!");  //("Ошибка периода");
}

void StampVersion(string Pro , string Ver , int x , int y)
{
   string Obj="Stamp_" + Pro;  
   int objs = ObjectsTotal();
   string name;
  
   for(int cnt=0;cnt<ObjectsTotal();cnt++)
   {
      name=ObjectName(cnt);
      if (StringFind(name,Obj,0)>-1) 
      {
         ObjectSet(Obj,OBJPROP_XDISTANCE,x);
         ObjectSet(Obj,OBJPROP_YDISTANCE,y);
         ObjectsRedraw();
      }
      else
      {
         ObjectCreate(Obj,OBJ_LABEL,0,0,0);
         ObjectSetText(Obj,Pro + " - " + Ver,8,"arial",Orange);
         ObjectSet(Obj,OBJPROP_XDISTANCE,x);
         ObjectSet(Obj,OBJPROP_YDISTANCE,y);
         ObjectsRedraw();
      }
   }
   if (ObjectsTotal() == 0)
   {
         ObjectCreate(Obj,OBJ_LABEL,0,0,0);
         ObjectSetText(Obj,Pro + " - " + Ver,8,"arial",Orange);
         ObjectSet(Obj,OBJPROP_XDISTANCE,x);
         ObjectSet(Obj,OBJPROP_YDISTANCE,y);
         ObjectsRedraw();

   }
   
   return;  //(0);
}
void DeleteStamp()
{
   int objs = ObjectsTotal();
   string name;
   for(int cnt=ObjectsTotal()-1;cnt>=0;cnt--)
   {
      name=ObjectName(cnt);
      if (StringFind(name,"Stamp",0)>-1) ObjectDelete(name);
      ObjectsRedraw();
   }
}

string GenVer()
{
   string t1;
   if(MA_Type==0) t1="SMA"; 
   if(MA_Type==1) t1="EMA"; 
   if(MA_Type==2) t1="SMMA"; 
   if(MA_Type==3) t1="LWMA"; 
   if(MA_Type==4) t1="DEMA"; 
   if(MA_Type==5) t1="TEMA"; 
   if(MA_Type==6) t1="T3MA"; 
   if(MA_Type==7) t1="JMA"; 
   if(MA_Type==8) t1="HMA";
   if(MA_Type==9) t1="DECEMA";
   if(MA_Type==10) t1="SALT";
   
   return (t1+"("+MA_Period+")"); 
}

void DeleteAllObjects()
{
   int objs = ObjectsTotal();
   string name;
   for(int cnt=ObjectsTotal()-1; cnt>=0; cnt--)
   {
      name=ObjectName(cnt);
      if (StringFind(name,"xpMA",0)>-1) ObjectDelete(name);
   }
}
