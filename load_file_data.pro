PRO LOAD_FILE_DATA, scnumber, filename, record, ptrdata, rcdnumber
  NUMBER_OF_SATELLITES = scnumber 
  IF N_ELEMENTS(filename) EQ 0 THEN BEGIN
  filename = []
    FOR sc = 0, NUMBER_OF_SATELLITES - 1 DO BEGIN
      temp = DIALOG_PICKFILE(PATH='C:\adatis\data', /READ, /MUST_EXIST, TITLE="Choose file to load")
      filename = [filename, temp]
    ENDFOR
  ENDIF

  IF N_ELEMENTS(filename) NE NUMBER_OF_SATELLITES THEN BEGIN
    PRINT, 'WARNING FOR USER'
    MESSAGE, "UNCORRECT NUMBER OF FILES"
  ENDIF ELSE BEGIN
    PRINT, 'START OF DATA LOADING'
  ENDELSE

  number_of_lines_list = []
  FOR i = 0, N_ELEMENTS(filename) - 1 DO BEGIN
    temp_number_of_lines = FILE_LINES(filename[i])
    number_of_lines_list = [number_of_lines_list, temp_number_of_lines]
    PRINT, 'TRY TO LOAD: ', filename[i], ' ', STRCOMPRESS('NUMBER OF LINES: '+STRING(temp_number_of_lines))
  ENDFOR
  number = MIN(number_of_lines_list)
  rcdnumber = number
  
  data = REPLICATE(record, number)
  ptrdata = PTRARR(NUMBER_OF_SATELLITES, /ALLOCATE_HEAP)

  FOR sc = 0, NUMBER_OF_SATELLITES - 1 DO BEGIN
    nrecords = 0ULL
    OPENR, lun, filename[sc], /GET_LUN
    WHILE NOT EOF(lun) AND (nrecords LT number) DO BEGIN
      READF, lun, record
      data[nrecords] = record
      nrecords = nrecords + 1
    ENDWHILE
    FREE_LUN, lun
    *ptrdata[sc] = data
    PRINT, 'LOADED: ', filename[sc], STRCOMPRESS(' AS SAT ID -'+STRING(sc+1))
  ENDFOR
  PRINT, 'DATA LOADED'

END