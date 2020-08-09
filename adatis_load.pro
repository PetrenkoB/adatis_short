PRO ADATIS_LOAD
  ON_ERROR, 2
  COMPILE_OPT idl2, HIDDEN
  COMMON global_variables, pointer_data, file_total_count, record_structure

  record_structure = {time:0.0d, bx:0.0d, by:0.0d, bz:0.0d, b:0.0d, x:0.0d, y:0.0d, z:0.0d}
  ;record_structure = {time:0.0d, bx:0.0d}
  file_total_count = 1
  REPEAT BEGIN
    READ, file_total_count, prompt = 'ENTER NUMBER OF FILES TO LOAD>'
  ENDREP UNTIL (file_total_count GE 1)  
  file_total_count = FIX(file_total_count)
  
  LOAD_FILE_DATA, file_total_count, filename, record_structure, pointer_data, rcdnumber
  
END