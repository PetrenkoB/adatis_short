PRO DATA_MANAGE,  secondarydata, primarydata, sat_id, BOTTOM_RANGE=bottom, TOP_RANGE=top, BAD_VALUE=data_forbidden, EPSILON=data_epsilon_forbidden, MODE=mode
  NUMBER_OF_SATELLITES = N_ELEMENTS(sat_id)
  number = N_ELEMENTS(*primarydata[sat_id[0]])
  columns = N_TAGS(*primarydata[sat_id[0]])
  sampling_step = []
  first_time_points = []
  last_time_points = []
  FOR sat = 0, NUMBER_OF_SATELLITES - 1 DO BEGIN
    sc = sat_id[sat]
    first_time_points = [first_time_points, (*primarydata[sc])[0].time]
    last_time_points = [last_time_points, (*primarydata[sc])[number-1].time]
    sampling_step = [sampling_step, (last_time_points[sat] - first_time_points[sat]) / number]
    ;PRINT, sc, '=>', N_ELEMENTS(*primarydata[sc])
  ENDFOR

  sampling_step_final = sampling_step[0]
  sampling_step_accuracy_relative = ABS((sampling_step_final - MEAN(sampling_step)) / MEAN(sampling_step))
  sampling_step_accuracy_relative_standard = 0.01

  IF MIN(sampling_step) LE 0.0 THEN BEGIN
    PRINT, 'WARNING FOR USER'
    PRINT, 'Time discreteness values: ', sampling_step
    PRINT, 'TIME DISCRETENESS HAS NON-POSITIVE VALUE'
    ;MESSAGE, 'TIME DISCRETENESS HAS NON-POSITIVE VALUE'
  ENDIF


  IF  sampling_step_accuracy_relative GE sampling_step_accuracy_relative_standard THEN BEGIN
    PRINT, 'WARNING FOR USER'
    PRINT, 'Time discreteness values: ', sampling_step
    PRINT, 'The reserved accuracy value for discreteness: ', sampling_step_accuracy_relative_standard
    PRINT, 'The obtained accuracy value for discreteness: ', sampling_step_accuracy_relative
    PRINT, 'RELATIVE ACCURACY BETWEEN TIME DISCRETENESS EXCEEDS THE RESERVED ACCURACY VALUE'
    ;MESSAGE, 'RELATIVE ACCURACY BETWEEN TIME DISCRETENESS EXCEEDS THE RESERVED ACCURACY VALUE'
  ENDIF


  time_relative_shift = CEIL(MAX(ABS(first_time_points - MIN(first_time_points))) / sampling_step_final)
  time_relative_shift_standard = 10
  IF time_relative_shift GE time_relative_shift_standard THEN BEGIN
    PRINT, 'WARNING FOR USER'
    PRINT, 'The reserved maximum time shift (in units of discreteness): ', time_relative_shift_standard
    PRINT, 'The obtained maximum time shift (in units of discreteness): ', time_relative_shift
    PRINT, 'TIME SHIFT IS SO LARGE'
    ;MESSAGE, 'TIME SHIFT IS SO LARGE'
  ENDIF

  IF (MIN(first_time_points) LT 0.0d) OR (MAX(last_time_points) GT 86400.0d) THEN BEGIN
    PRINT, 'WARNING FOR USER'
    PRINT, 'UNSUITABLE TIMELINE'
    ;MESSAGE, 'UNSUITABLE TIMELINE'
  ENDIF


  indexarr = PTRARR(NUMBER_OF_SATELLITES, columns, /ALLOCATE_HEAP)
  FOR sat = 0, NUMBER_OF_SATELLITES - 1 DO BEGIN
    sc = sat_id[sat]
    FOR tag = 1, columns - 1 DO BEGIN
      temp = (*primarydata[sc]).(tag)
      DATA_MANAGING_FIND_BADVALUES, data_forbidden, data_epsilon_forbidden, temp, index_bad_value, index_complement
      (*primarydata[sc])[index_bad_value].(tag) = !VALUES.D_NAN
      ;(*primarydata[sc])[index_bad_value].(tag) = 0.0
      (*indexarr[sat, tag]) = index_bad_value
    ENDFOR
    *indexarr[sat, 0] = !NULL
  ENDFOR

  IF NOT(mode) THEN BEGIN
    pos_bottom = FLOOR((number-1)*bottom)
    pos_top = FLOOR((number-1)*top)
  ENDIF ELSE BEGIN
    TIME_POSITION, (*primarydata[0]).(0), bottom[0], bottom[1], bottom[2], pos_bottom
    TIME_POSITION, (*primarydata[0]).(0), top[0], top[1], top[2], pos_top
  ENDELSE
  number = pos_top - pos_bottom + 1
  number_max = 10
  IF number LT number_max THEN BEGIN
    PRINT, 'WARNING FOR USER'
    PRINT, 'The reserved maximum points number: ', number_max
    PRINT, 'The obtained points number: ', number
    PRINT, 'DATA AMOUNT ARE NEGLIGIBLE. PLEASE, RELAUNCH PROGRAM WITH NEW DATA RANGE'
    ;MESSAGE, 'DATA AMOUNT ARE NEGLIGIBLE. PLEASE, RELAUNCH PROGRAM WITH NEW DATA RANGE'
  ENDIF

  secondarydata = PTRARR(NUMBER_OF_SATELLITES, /ALLOCATE_HEAP)
  FOR sat = 0, NUMBER_OF_SATELLITES - 1 DO BEGIN
    sc = sat_id[sat]
    *secondarydata[sat]=(*primarydata[sc])[pos_bottom:pos_top]
    ;PRINT, sc, '=>', N_ELEMENTS(*secondarydata[sc])
  ENDFOR

  FOR sat = 0, NUMBER_OF_SATELLITES - 1 DO BEGIN
    FOR tag = 1, columns - 1 DO BEGIN
      temp = TEMPORARY((*secondarydata[sat]).(tag))
      is_data_contaminated = WHERE(FINITE(temp) EQ 0, /NULL)
      ;PRINT, sc, '=>', tag, '=>', is_data_contaminated
      IF is_data_contaminated NE !NULL THEN BEGIN
        PRINT, 'WARNING FOR USER'
        ;MESSAGE, 'DATA ARE CONTAMINATED WITH BAD VALUES. PLEASE, RELAUNCH PROGRAM WITH NEW DATA RANGE'
      ENDIF
    ENDFOR
  ENDFOR

END
