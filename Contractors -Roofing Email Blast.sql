SELECT Distinct


isnull(  replace(replace(replace(( rtrim(ltrim(A.b1_cae_fname))+ ' '+ rtrim(ltrim(A.b1_cae_lname))),' ','<>'),'><',''),'<>',' ') ,  
           isnull("dbo".FN_GET_CONTACT_INFO('TAMPA',A.B1_PER_ID1, A.B1_PER_ID2, A.B1_PER_ID3, 'Applicant', null, null , 'FullName', null, null), ' ')  )   Contractor_Name

           ,A.B1_EMAIL,  A.B1_LICENSE_TYPE , B.LIC_EXPIR_DD         





--CONCAT(B1_CAE_FNAME  ,  B1_CAE_LNAME) As TEST 
FROM B3CONTRA A 

LEFT OUTER JOIN RSTATE_LIC B ON

B.LIC_SEQ_NBR = A.LIC_SEQ_NBR



WHERE B1_LICENSE_TYPE ='Roofing Contractor'

AND B1_EMAIL NOT LIKE ''


ORDER BY Contractor_Name ASC
/*
SELECT DISTINCT B1_LICENSE_TYPE FROM B3CONTRA

ORDER BY B1_LICENSE_TYPE ASC
*/