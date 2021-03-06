
show "loading script...";
homeDir:first system["echo $HOME"];
storePath:homeDir,"/data/";
system "mkdir -p ",storePath;
tableNames:`chains`cboe_symbol_list;


procesJSON:{[res;ticker]
    knownCols::`cid`name`s`e`p`cs`c`cp`b`a`oi`vol`strike`expiry;
    d:  (update typ:`puts from flip knownCols!flip {x knownCols} each res`puts),
        (update typ:`calls from flip knownCols!flip {x knownCols} each res`calls);

    d:update ticker:ticker,pull_time:.z.P,expiry:("D"$raze string value res`expiry), underlying_px:(res`underlying_price) from
        delete expiry from update "J"$cid,`$name,`$s,`$e,"F"$p,`$cs,"F"$c,"F"$cp,"F"$b,"F"$a,"F"$oi,"F"$vol,"F"$ssr[;",";""] each strike from d;

     (`data`expirations)!(d;res`expirations)
 };



userAgentString:"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.112 Safari/534.30";

getChains:{[ticker]
    res:.j.k first 0N!system 0N!"curl -A \"",userAgentString,"\" -s \"http://www.google.com/finance/option_chain?q=",string[ticker],"&output=json\" | perl ",homeDir,"/omrepo/make_good_json.pl";
    procesJSON[res;ticker]
 };


getChainByExpiry:{[ticker;y;m;d]
   res:.j.k first 0N!system 0N!"curl  -A \"",userAgentString,"\" -s \"http://www.google.com/finance/option_chain?q=",string[ticker],"&output=json&expy=",string[y],"&expm=",string[m],"&expd=",string[d],"\" | perl ",homeDir,"/omrepo/make_good_json.pl";
    procesJSON[res;ticker]
 };

getFirstTwo:{[ticker]
    tryToSleep[];
    a:getChains[0N!ticker];
    expirations:update date:{"D"$"/" sv x} each string (y,'m,'d) from a`expirations;
    d:exec from 1#1_a`expirations;
    returnVal:(a`data),{[ticker;d] getChainByExpiry[ticker;d`y;d`m;d`d]`data}[ticker;] each select from 1_expirations where date < .z.D+30;
    sleepSeconds::0i;
    returnVal
 };


sleepSeconds:0i;
tryToSleep:{
        if[sleepSeconds>5;sleepSeconds::5];
        if[sleepSeconds>0;system "sleep ",string[sleepSeconds],"s"];
 };

cboe_symbol_list_savePath:-1!`$storePath,"cboe_symbol_list_",ssr[string[.z.D];":";"_"],".kdbzip";
static_data_savePath:-1!`$storePath,"static_data_",ssr[string[.z.D];":";"_"],".kdbzip";


get_cboe_symbol_list:{[]
  cboe_symbol_list:`companyName`ticker`dpm`cycle`tradedC2`leap2016`leaps2017`leaps2018`productType`lastCol
     xcol ("SSSSSSSSSS";enlist ",")0:1_system 0N!"curl -s http://www.cboe.com/publish/scheduledtask/mktdata/cboesymboldir2.csv";
    (cboe_symbol_list_savePath;17;2;6) set  cboe_symbol_list;
    cboe_symbol_list
 };



get_static_data:{[]

    b:raze each system each {0N!"curl -s \"http://finance.google.com/finance/info?infotype=infoquoteall&q=",x,"\""} each {"," sv string x }
        each 75 cut exec ticker from cboe_symbol_list;
    c:raze {.j.k 3_x} each b;
    knownCols::distinct raze key each c;
    staticData:flip knownCols!`$flip {x[knownCols]} each c;
    (static_data_savePath;17;2;6) set  staticData;
    staticData
 };

cboe_symbol_list:$[0<count key cboe_symbol_list_savePath;get cboe_symbol_list_savePath;get_cboe_symbol_list[]];
static_data:$[0<count key static_data_savePath;get static_data_savePath;get_static_data[]];

marketCaps:(`M`B)!(1e6;1e9);
static_data:update marketCap:{$[(`$last[x]) in key marketCaps; marketCaps[`$last[x]]*"F"$-1_x;"F"$x]} each string[mc] from static_data;

getStuff:{[]
    //topOptionsTickers:exec ticker from cboe_symbol_list where lastCol in `L`W; / has weekly's
    topOptionsTickers:exec ticker from cboe_symbol_list where ticker in  exec t from static_data where marketCap>2e9;

    

    chains:{@[getFirstTwo;x;[sleepSeconds::sleepSeconds+1  ;`$("Failed on Ticker ",string[x]," at time ",string[.z.P])]]} each topOptionsTickers;

    chains:raze chains[where 98=type each chains];

    (-1!`$storePath,"chains_",ssr[string[.z.P];":";"_"],".kdbzip";17;2;6) set  chains;
    show "date done and saved",string[.z.P];

     if[.z.T>22:30t;exit[0]]; // exit later

 };

.z.ts:getStuff;
show "timing starting...";
system "t 1800000";
getStuff[]; // call it once, since timer kicks off at the end

show "reached end of script";


