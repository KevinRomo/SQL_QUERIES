SELECT B1_ALT_ID AS                                                 [Record ID], 
       B1_SPECIAL_TEXT, FORMAT(B1_FILE_DD, 'MM/dd/yyyy') AS         [Opened Date],
       B1_APPL_STATUS                                               [Status], 
       FORMAT(B1_APPL_STATUS_DATE, 'MM/dd/yyyy')                    [Status Date]

 FROM b1PERMIT 

WHERE 

     B1_FILE_DD >= '01-01-2020' AND
     ( B1_ALT_ID LIKE '%SU2%' OR
      B1_ALT_ID LIKE '%SU1%' OR
      B1_ALT_ID LIKE '%REZ%'      )

ORDER BY B1_FILE_DD ASC

--SELECT * FROM b1PERMIT