FUNCTION DEFFER, x ;function calculates difference between elements of array
  number=N_ELEMENTS(x)
  dx=DBLARR(number)
  dx[number-1]=x[number-1]-x[number-2]
  FOR i=0, number-2 DO BEGIN
    dx[i]=(x[i+1]-x[i])
  ENDFOR
  RETURN, dx
END

PRO ADATIS_DATA
  TIC

  ;-------------------------------
  name='C:\adatis\data\input_data.txt'

  ;File data reading
  GET_LUN, gg
  OPENR, gg, name
  jata=READ_ASCII(name, DATA_START=0);
  CLOSE, gg
  FREE_LUN, gg
  
  ;size of file
  timesize=1000
  columns=2
  timesize=N_ELEMENTS(jata.field1[0, *])
  columns=N_ELEMENTS(jata.field1[*, 0])
  data=DBLARR(columns, timesize)

  ;file reading
  GET_LUN, ff
  OPENR, ff, name
  READF, ff, data
  CLOSE, ff
  FREE_LUN, ff
  
  ;reading
  time=data[0, 0:timesize-1]
  field=data[1, 0:timesize-1]

  ;boundaries and limiting
  boundary1=0.0;
  boundary2=1.0;
  ;enter boundary
;  READ, boundary1, prompt = 'Enter low data boundary (from 0 to 1) : '
;  READ, boundary2, prompt = 'Enter upper data boundary (from 0 to 1) : '
  mini=FLOOR((timesize-1)*boundary1);
  maxi=FLOOR((timesize-1)*boundary2);
  tmini=time[mini]
  tmaxi=time[maxi]

  number=maxi-mini+1
  t=DBLARR(number)
  f=DBLARR(number)
  num=INDGEN(number, /UL64)
  ;num=num+mini

  t[*]=time[mini:maxi]
  f[*]=field[mini:maxi]

  dt=(t[number-1]-t[0])/(number-1)
  

;  ;Artificial data
;  dt=0.01
;  t_start=72000.00
;  t_end=72010.00
;  number=FLOOR((t_end-t_start)/dt)+1
;  t=t_start+dt*DINDGEN(number)
;  a0=10.00
;  a1=1.00
;  a2=1.00
;  a3=1.00 
;  f1=4.00
;  f2=12.00
;  f3=1.00
;  ;f=a0+a3*COS(2*!dpi*f3*t+1)
;  f=a0+a1*SIN(2*!dpi*f1*t)+a2*COS(2*!dpi*f2*t+10)
;  ;f=a0+a1*SIN(2*!dpi*f1*t)+a2*COS(2*!dpi*f2*t)+a3*COS(2*!dpi*f3*t+1)
;  tmini=t[0]
;  tmaxi=t[number-1]
  
  tt_disc=DEFFER(t)
  
  fmean=MEAN(f)
  fstddev=STDDEV(f)
  fskewness=SKEWNESS(f)
  fkurtosis=KURTOSIS(f)

  ;-------------------------------
  ;Timing in UT
  dummy = LABEL_DATE(DATE_FORMAT='%H:%I:%S')
  hour=FLOOR(tmini/86400.)
  minute=FLOOR(1440.*(tmini/86400.-hour))
  second=tmini-60.*minute
  MyDates=TIMEGEN(number, STEP_SIZE=dt, START=JULDAY(1,1,2000, hour, minute, second), UNITS='S')
  
  ;Time interval calculation
  addmajor=2
  addseconds=1./addmajor*(number-1)*dt
  addbase=10.^(FLOOR(ALOG10(addseconds)))
  add=1
  add=addbase*FLOOR(addseconds/addbase)
  IF add GT 60.0 THEN BEGIN
    add=60.0*FLOOR(add/60.0)
  ENDIF
  IF add GT 600.0 THEN BEGIN
    add=600.0*FLOOR(add/600.0)
  ENDIF
  ;PRINT, addseconds, addbase, add
  
  ;-------------------------------
  ;Graphing  
  plot0=PLOT(MyDates, field, $ 
    XTITLE='Time(hh:mm:ss)', YTITLE='Field(nT)', $
    XTICKFORMAT='LABEL_DATE', XSTYLE=1, XMINOR=4, $
    XTICKINTERVAL=JULDAY(1,1,2000, hour, minute, second+add)-JULDAY(1,1,2000, hour, minute, second))
     
  ymax=1.5*MAX(ABS(tt_disc))
  ymin=-ymax
  plot1=PLOT(num, tt_disc , YRANGE=[ymin, ymax], XMAJOR=4, $
    TITLE='Discreteness beetween time tags', XTITLE='Sample', YTITLE='Time(s)')  
  
  ;-------------------------------
  ;Printing
  PRINT, 'Sample number : ', number
  PRINT, 'Mean value : ', fmean
  PRINT, 'Standart deviation : ', fstddev
  PRINT, 'Skewness : ', fskewness
  PRINT, 'Kurtosis : ', fkurtosis
  PRINT, 'Mean discreteness : ', MEAN(tt_disc), ' sec and general discretness : ', dt, ' sec'

  TOC
END