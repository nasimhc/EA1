/*------------------------------------------------------------------------------------
   Name: TDI-RT-Clone.mq4
   
   Description: A clone of the TDI indicator. 
                The volatility bands and the market base line are not exactly the same 
                but they are close enough. 
                	          
-------------------------------------------------------------------------------------*/
// Indicator properties
#property copyright "www.xaphod.com"
#property link      "www.xaphod.com"
#property strict
#property version "1.600"
#property description "A clone of the TDI-RT indicator - Simplified version"
#property description "Shows only Trade Signal and RSI Signal lines"
#property indicator_separate_window
#property indicator_buffers 3  // Reduced from 6 to 3 (2 visible + 1 hidden RSI buffer)
#property indicator_color1 clrRed    // Trade Signal
#property indicator_width1 2
#property indicator_color2 clrGreen  // RSI Signal
#property indicator_width2 2
#property indicator_color3 CLR_NONE  // Hidden RSI buffer
#property indicator_width3 1
#property indicator_level1 32
#property indicator_level2 50
#property indicator_level3 68
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor DimGray

#define INDICATOR_NAME "TDI-RT-Clone"

// Indicator parameters
extern int                RSI_Period=13;            
extern ENUM_APPLIED_PRICE RSI_Price=PRICE_CLOSE; 
extern int                Volatility_Band=34;
extern int                RSISignal_Period=2;   
extern ENUM_MA_METHOD     RSISignal_Mode=MODE_SMA;
extern int                TradeSignal_Period=7;      
extern ENUM_MA_METHOD     TradeSignal_Mode=MODE_SMA; 


// Global module varables
double gdaRSI[];      // Hidden RSI buffer
double gdaRSISig[];   // Green line
double gdaTradeSig[]; // Red line


//-----------------------------------------------------------------------------
// function: init()
// Description: Custom indicator initialization function.
//-----------------------------------------------------------------------------
int init() {
  SetIndexStyle(0, DRAW_LINE);
  SetIndexBuffer(0, gdaTradeSig);
  SetIndexLabel(0,"Trade Signal");
  
  SetIndexStyle(1, DRAW_LINE);
  SetIndexBuffer(1, gdaRSISig);
  SetIndexLabel(1,"RSI Signal");   
  
  SetIndexStyle(2, DRAW_NONE);
  SetIndexBuffer(2, gdaRSI);
  SetIndexLabel(2,NULL);
  
  IndicatorDigits(1);
  IndicatorShortName(INDICATOR_NAME);
  return(0);
}

//-----------------------------------------------------------------------------
// function: deinit()
// Description: Custom indicator deinitialization function.
//-----------------------------------------------------------------------------
int deinit() {
   return (0);
}


///-----------------------------------------------------------------------------
// function: start()
// Description: Custom indicator iteration function.
//-----------------------------------------------------------------------------
int start() {
  int iNewBars, iCountedBars, i;  
  
  // Get unprocessed bars
  iCountedBars=IndicatorCounted();
  if(iCountedBars < 0) return (-1); 
  if(iCountedBars>0) iCountedBars--;
  iNewBars=MathMin(Bars-iCountedBars, Bars-1);

  // Calc TDI data
  for(i=iNewBars-1; i>=0; i--) {
    gdaRSI[i] = iRSI(NULL,0,RSI_Period,RSI_Price,i); 
  }
  for(i=iNewBars-1; i>=0; i--) {  
    gdaRSISig[i]=iMAOnArray(gdaRSI,0,RSISignal_Period,0,RSISignal_Mode,i);
    gdaTradeSig[i]=iMAOnArray(gdaRSI,0,TradeSignal_Period,0,TradeSignal_Mode,i);
  } 
  return(0);
}
//+------------------------------------------------------------------+


