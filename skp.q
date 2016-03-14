/ n is the number of ticks per second
n:100

/ tks is the number of ticks per trading day: 
/ 6 hours * 60 minutes * 60 seconds * n ticks per second
tks:6*60*60*n

/ stk is the list of stock symbold, taken from Dow Jones
stk:`MMM`AXP`APPL`BA`CAT`CVX`CSCO`KO`DD`DIS`XOM`GE`GS`HD`INTC`IBM`JNJ`JPM`MCD`MRK`MSFT`NKE`PFE`PG`TRV`UNH`UTX`VZ`V`WMT

/stktbl is the table of stock tick data
stkTBL:([] time:(); sym:(); price:(); vol:())

/daterange is the list of days for which we generate/use data
daterange:(2016.03.01D10; 2016.03.02D10; 2016.03.03D10; 2016.03.04D10; 2016.03.07D10; 2016.03.08D10; 2016.03.09D10; 2016.03.10D10)

gendaily: { [d] 
            s:([]time:(asc(tks#d + tks?0D06)); sym:tks?stk; price:((tks?100.00) + (tks#10.00)); vol:((tks?500000) +(tks#1000)));
            stkTBL::stkTBL,s;
          }

/ The table in which we will store the VWAP results
vwapTBL:([] sym:`symbol$(); date:`date$(); vwap:`float$())

/ Calculate the vwap for a particular symbol on a particular date
/ taken from tick data table T and place result in table V
vwap:{[d;s;T] J:select time,sym,price,vol from T where time.date=d, sym=s; 
              k:select sum(price*vol), sum(vol) from J;
              v:select (price%vol) from k;
              vx:`float$(value v[0]);
              m:([] sym:s; date:d; vwap:vx);
              `vwapTBL insert(m);
     }

// Give a symbol, calculate the vwap for the time period 
symvwap:{ [s] vwap[;s;stkTBL] peach daterange.date; }      

// Generate the stock data
gendaily peach daterange

// Calculate all the vwaps for the time range for all the symbols
symvwap peach stk

save `vwapTBL.csv
