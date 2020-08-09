PRO USER_INTERFACE, file_total_count, MULTIPLE=multiple, SINGLE=single, TIMING=timing, COLUMNID=columnid
  COMMON user_interface_variables, satid, mode, boundary1, boundary2, tag
     
  tag = 2
  mode = 0
  boundary1_default = 0.0d
  boundary2_default = 1.0d
  boundary1 = boundary1_default
  boundary2 = boundary2_default
  
  
  scnumber = file_total_count
  satid = 0
  IF KEYWORD_SET(multiple) THEN BEGIN
    IF file_total_count EQ 1 THEN MESSAGE, 'CALL ADATIS_LOAD WITH MORE NUMBER OF FILES'
    REPEAT BEGIN
      READ, scnumber, prompt = 'ENTER NUMBER OF SATELLITES>'
    ENDREP UNTIL (scnumber GT 1 AND scnumber LE file_total_count)
    satid = 1 + INDGEN(scnumber)
    IF scnumber LT file_total_count THEN BEGIN
      FOR sat=0, scnumber-1 DO BEGIN
        REPEAT BEGIN
          READ, readsat, prompt = STRCOMPRESS('ENTER SAT ID' + '#' + STRING(sat + 1) + '>')
        ENDREP UNTIL ((readsat GE 1) AND (readsat LE file_total_count))
        satid[sat] = readsat
      ENDFOR
    ENDIF
    satid -= 1
  ENDIF 
  
  IF KEYWORD_SET(single) THEN BEGIN
    IF file_total_count GT 1 THEN BEGIN
      REPEAT BEGIN
        READ, readsat, prompt = STRCOMPRESS('ENTER SAT ID' + '# 1>')
       ENDREP UNTIL ((readsat GE 1) AND (readsat LE file_total_count))
      satid = readsat - 1
    ENDIF
  ENDIF 
  
  IF KEYWORD_SET(columnid) THEN BEGIN
    REPEAT BEGIN
      READ, tag, prompt = 'ENTER COLUMN ID>'
    ENDREP UNTIL (tag GE 2)
    tag -= 1
  ENDIF 
  
  IF  KEYWORD_SET(timing) THEN BEGIN
    READ, mode ,prompt = 'ENTER PLEASE MODE OF BOUNDARY REPRESENTATION (0 IN RELATIVE UNITS, 1 IN UNITS OF TIME)>'
    mode = BOOLEAN(mode)
    IF mode THEN BEGIN
      boundary1 = [0s, 0s, 0s]
      boundary2 = [23s, 59s, 59s]
      REPEAT BEGIN
        READ, argboundary10, prompt = 'ENTER LOW DATA BOUNDARY (HH FROM 0 TO 23)>'
        READ, argboundary11, prompt = 'ENTER LOW DATA BOUNDARY (MM FROM 0 TO 59)>'
        READ, argboundary12, prompt = 'ENTER LOW DATA BOUNDARY (SS FROM 0 TO 59)>'
        READ, argboundary20, prompt = 'ENTER UPPER DATA BOUNDARY (HH FROM 0 TO 23)>'
        READ, argboundary21, prompt = 'ENTER UPPER DATA BOUNDARY (MM FROM 0 TO 59)>'
        READ, argboundary22, prompt = 'ENTER UPPER DATA BOUNDARY (SS FROM 0 TO 59)>'
      ENDREP UNTIL ((argboundary10 LE argboundary20) OR (argboundary11 LE argboundary21) OR (argboundary12 LT argboundary22) $
        AND (argboundary10 GE boundary1[0]) AND (argboundary11 GE boundary1[1]) AND (argboundary12 GE boundary1[2]) $
        AND (argboundary20 LE boundary2[0]) AND (argboundary21 LE boundary2[1]) AND (argboundary22 LE boundary2[2]))
      boundary1 = FIX([argboundary10, argboundary11, argboundary12])
      boundary2 = FIX([argboundary20, argboundary21, argboundary22])
    ENDIF ELSE BEGIN
      REPEAT BEGIN
        READ, boundary1, prompt = 'ENTER LOW DATA BOUNDARY (FROM 0 TO 1)>'
        READ, boundary2, prompt = 'ENTER UPPER DATA BOUNDARY (FROM 0 TO 1)>'
      ENDREP UNTIL ((boundary1 LT boundary2) AND (boundary1 GE boundary1_default) AND (boundary2 LE boundary2_default))
    ENDELSE
  ENDIF

END