
declare @enddate as datetime = '1/1/1980'  
,  @startdate as datetime  = '1/1/1980'  ; --12/21/2020: changded datatype to datetime



set @startdate = {?StartingDate} --12/21/2020: for Crystal Reports parameters; comment out when debugging in SSSMS, but uncomment before pasting query to Crystal Reports; variable is used on line 87
set @enddate ={?EndingDate} --12/21/2020: for Crystal Reports parameters; comment out when debugging in SSSMS, but uncomment before pasting query to Crystal Reports; variable is used on line 87





SELECT DISTINCT

MAX(A.B1_FILE_DD),

A.B1_ALT_ID                                                                                                                                  [RECORD NUMBER],

D.B1_WORK_DESC                                                                                                                               [DETAILED DESCRIPTION], 
A.B1_APP_TYPE_ALIAS                                                                                                                          [RECORD TYPE],
A.B1_APPL_STATUS                                                                                                                             [RECORD STATUS],

-- LEAD(B.SD_APP_DES , 1) OVER (ORDER BY B.SD_APP_DES),

dbo.FN_GET_PRI_ADDRESS_PARTIAL('TAMPA', A.B1_PER_ID1, A.B1_PER_ID2, A.B1_PER_ID3  ) + ', '+
reverse(SUBSTRING(  reverse( dbo.FN_GET_PRI_ADDRESS_FULL('TAMPA', A.B1_PER_ID1, A.B1_PER_ID2, A.B1_PER_ID3  )), 1, 5) )                      [ADDRESS]
, dbo.FN_GET_APP_SPEC_INFO(B.SERV_PROV_CODE, B.B1_PER_ID1, B.B1_PER_ID2, B.B1_PER_ID3, 'Facilitated Project?')                               [FACILIATED PROJECT]
, dbo.FN_GET_APP_SPEC_INFO(B.SERV_PROV_CODE, B.B1_PER_ID1, B.B1_PER_ID2, B.B1_PER_ID3, 'Private Provider?')                                  [PRIVATE PROVIDER]
, dbo.FN_GET_APP_SPEC_INFO(B.SERV_PROV_CODE, B.B1_PER_ID1, B.B1_PER_ID2, B.B1_PER_ID3, 'New Construction Type')                              [NEW CONSTRUCTION TYPE]
, dbo.FN_GET_APP_SPEC_INFO(B.SERV_PROV_CODE, B.B1_PER_ID1, B.B1_PER_ID2, B.B1_PER_ID3, 'Job Value')                                          [TOTAL PROJECT VALUE]
, dbo.FN_GET_APP_SPEC_INFO(B.SERV_PROV_CODE, B.B1_PER_ID1, B.B1_PER_ID2, B.B1_PER_ID3, 'Total Sq Ft')                                        [TOTAL SQ FT]
, dbo.FN_GET_APP_SPEC_INFO(B.SERV_PROV_CODE, B.B1_PER_ID1, B.B1_PER_ID2, B.B1_PER_ID3, 'Occupancy Category')                                 [OCCUPANCY CATEGORY]
, dbo.FN_GET_APP_SPEC_INFO(B.SERV_PROV_CODE, B.B1_PER_ID1, B.B1_PER_ID2, B.B1_PER_ID3, 'Number of Units')                                    [NUMBER OF UNITS]
                                                                                                                     
--,A. REC_STATUS     

,B.GPROCESS_HISTORY_SEQ_NBR
,B.SD_APP_DES                                                                                                                                [CURRENT STATUS]       

,FORMAT(A.B1_FILE_DD, 'MM/dd/yyyy')                                                                                                         [OPENED DATE]   
,FORMAT(F.SD_APP_DD, 'MM/dd/yyyy')                                                                                                          [ISSUANCE DATE]
,FORMAT(E.SD_APP_DD, 'MM/dd/yyyy')                                                                                                          [CERTIFICATION DATE]

,CASE 

    WHEN E.SD_APP_DES LIKE '%COC%' THEN 'COC'
    WHEN E.SD_APP_DES LIKE '%COO Issued%' THEN 'COO'
    ELSE 'Not Eligible'

END AS                                                                                                                                       [CERTIFICATION TYPE]




FROM B1PERMIT A 



OUTER APPLY

(SELECT TOP (1)  B.* 

    FROM GPROCESS_HISTORY B 
    WHERE     
   
    B.B1_PER_ID1 = A.B1_PER_ID1  AND
    B.B1_PER_ID2 = A.B1_PER_ID2  AND
    B.B1_PER_ID3 = A.B1_PER_ID3  AND
    
    B.SERV_PROV_CODE = A.SERV_PROV_CODE 

    ORDER BY B.GPROCESS_HISTORY_SEQ_NBR  DESC
) B

OUTER APPLY 

(SELECT TOP (1) C.* 
FROM GPROCESS C
WHERE 

    C.B1_PER_ID1 = B.B1_PER_ID1  AND
    C.B1_PER_ID2 = B.B1_PER_ID2  AND
    C.B1_PER_ID3 = B.B1_PER_ID3  AND
    
    C.SERV_PROV_CODE = B.SERV_PROV_CODE

) C

OUTER APPLY 
(SELECT TOP (1) D.*

FROM BWORKDES D 
WHERE

    D.B1_PER_ID1 = C.B1_PER_ID1  AND
    D.B1_PER_ID2 = C.B1_PER_ID2  AND
    D.B1_PER_ID3 = C.B1_PER_ID3  AND
    
    D.SERV_PROV_CODE = C.SERV_PROV_CODE
) D

OUTER APPLY 

(SELECT TOP (1) E.*

FROM GPROCESS_HISTORY E

WHERE 

    (E.SD_APP_DES LIKE '%COC%' or  E.SD_APP_DES LIKE '%COO Issued%') AND
    E.SD_PRO_DES = 'Certification' AND
    E.B1_PER_ID1 = D.B1_PER_ID1  AND
    E.B1_PER_ID2 = D.B1_PER_ID2  AND
    E.B1_PER_ID3 = D.B1_PER_ID3  AND
    
    E.SERV_PROV_CODE = D.SERV_PROV_CODE

    ORDER BY B.GPROCESS_HISTORY_SEQ_NBR  DESC
) E

OUTER APPLY 

(SELECT TOP (1) F.*

FROM GPROCESS_HISTORY F
WHERE 

    F.SD_PRO_DES = 'Issuance' AND
    F.SD_APP_DES = 'Issued' AND
    F.B1_PER_ID1 = E.B1_PER_ID1  AND
    F.B1_PER_ID2 = E.B1_PER_ID2  AND
    F.B1_PER_ID3 = E.B1_PER_ID3  AND
    
    F.SERV_PROV_CODE = E.SERV_PROV_CODE

)F


WHERE A.B1_FILE_DD >=  @startdate AND

A.B1_FILE_DD <=  @enddate

--A.B1_ALT_ID ='BLD-21-0478298'
AND A.B1_PER_TYPE = 'Commercial'
AND A.B1_PER_GROUP = 'Building'
AND A.B1_ALT_ID NOT LIKE '%TMP%'
AND A.B1_ALT_ID NOT LIKE '%CMP%'
AND A.REC_STATUS = 'A'
AND A.serv_prov_code               = 'Tampa'






GROUP BY A.B1_FILE_DD, 
         A.B1_ALT_ID, 
         D.B1_WORK_DESC, 
         A.B1_APP_TYPE_ALIAS, 
         A.B1_APP_TYPE_ALIAS, 
         A.B1_APPL_STATUS, 
         A.B1_PER_ID1,
         A.B1_PER_ID2 ,
         A.B1_PER_ID3,

         B.SERV_PROV_CODE,
         B.B1_PER_ID1,
         B.B1_PER_ID2,
         B.B1_PER_ID3,
         B.GPROCESS_HISTORY_SEQ_NBR,
         B.SD_APP_DES,

        E.SD_APP_DD,
        E.SD_APP_DES,

         F.SD_APP_DD


ORDER BY MAX(A.B1_FILE_DD), B1_ALT_ID DESC