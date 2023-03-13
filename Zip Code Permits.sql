


  Declare
    @start_mnth date ,    @startdate date,  @yr_roll1 as int,  @yr_roll2 as int, @end_mnth   date 
    
    set @startdate =   DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)  ;    --   GETDATE() ;   
 
    set @yr_roll1 = case when datepart(mm,@startdate) = 12 then 0 else  datepart(mm,@startdate) end   ;
    set @yr_roll2 = case when datepart(mm,@startdate) = 12 then 1 else  0 end   ;    
 
    set @start_mnth = cast(  cast ( datepart(mm,@startdate) as varchar(4) ) + '/01/' + cast(datepart( yy, @startdate) as varchar(4) ) as date ); 
    set @end_mnth   = cast(  cast ( @yr_roll1+1 as varchar(4) ) + '/01/' + cast(datepart( yy, @startdate)+@yr_roll2 as varchar(4) ) as date );   


--USE ACCELA_Reporting ;   -- _Reporting 

set nocount on ;
set transaction isolation level read uncommitted; 

  
select  addr, zip, job_value, recType,   permit_issue_dt , b1_alt_id, app_name,  convert(Date , '02/01/2023') startdate,   convert(Date , '02/01/2023') enddate
from (  
   select     b1_alt_id, addr ,  zip,  JobValue  job_value, b1_per_type  recType, permit_issue_dt ,  b1_special_text  app_name
   from (                                       
     SELECT    distinct    
        p.b1_per_type, p.b1_alt_id, 1 as knt, min (cast( id.sd_app_dd as date )) over ( partition by p.b1_alt_id )  permit_issue_dt , 
        CASE WHEN IsNumeric( CONVERT(VARCHAR(12), dbo.FN_GET_APP_SPEC_INFO('TAMPA', p.b1_per_id1, p.b1_per_id2, p.b1_per_id3, 'Job Value') )  ) = 1 then  
             round ( dbo.FN_GET_APP_SPEC_INFO('TAMPA', p.b1_per_id1, p.b1_per_id2, p.b1_per_id3, 'Job Value') , 2, 0 )  else 0 End  AS  JobValue,
        dbo.FN_GET_PRI_ADDRESS_partial('TAMPA', p.b1_per_id1, p.b1_per_id2, p.b1_per_id3 ) addr , p.b1_special_text
        , reverse( SUBSTRING(  reverse( dbo.FN_GET_PRI_ADDRESS_FULL('TAMPA', p.b1_per_id1, p.b1_per_id2, p.b1_per_id3  )), 1, 5) ) zip	 	 
     FROM 
        dbo.GPROCESS_HISTORY id with (nolock) 												
         JOIN dbo.B1PERMIT p with (nolock) ON p.serv_prov_code = id.serv_prov_code and p.b1_per_id1 = id.b1_per_id1 and p.b1_per_id2 = id.b1_per_id2 and p.b1_per_id3 = id.b1_per_id3 
     where 
          p."REC_STATUS" = 'A' and  p."B1_PER_GROUP" = 'Building' and p."B1_PER_TYPE" in (  'Residential' ) and                             
          id.SD_APP_DES = 'Issued'    and p.b1_per_sub_type = 'New Construction and Additions'    and 
         id.serv_prov_code = 'TAMPA' and    id.sd_pro_des = 'Issuance' and  
         dbo.FN_GET_APP_SPEC_INFO('TAMPA', p.B1_PER_ID1, p.B1_PER_ID2, p.B1_PER_ID3, 'New Construction') =  'Yes'   and
          ( id.SD_APP_DD >=    '05'  and id.SD_APP_DD <     '05'+1  )  and  len( p."B1_ALT_ID" ) = 14  		  							  				          
      ) ilv   	 

 union all

  select      
       b1_alt_id, addr	, zip, job_value, b1_per_type  recType, pid permit_issue_dt,  b1_special_text	 app_name
  from (
     select   distinct                    
        p.b1_alt_id , 
        dbo.FN_GET_PRI_ADDRESS_PARTIAL('TAMPA', p.b1_per_id1, p.b1_per_id2, p.b1_per_id3 ) addr 
        , (
          select top 1
             min ( cast ( dbo.FN_GET_APP_SPEC_INFO('TAMPA', id.b1_per_id1, id.b1_per_id2, id.b1_per_id3, 'Permit issue date')  as date ) ) over ( partition by p.b1_alt_id ) pid
          from 
             dbo.xapp2ref d with (nolock) 
             left outer join dbo.b1permit id 	with (nolock) on  d.serv_prov_code = id.serv_prov_code and d.b1_per_id1 = id.b1_per_id1 and d.b1_per_id2 = id.b1_per_id2 and d.b1_per_id3 = id.b1_per_id3   				
          where   
             dbo.FN_GET_APP_SPEC_INFO('TAMPA', id.b1_per_id1, id.b1_per_id2, id.b1_per_id3, 'Permit issue date')  <> ''  and  
             p.serv_prov_code = d.serv_prov_code and p.b1_per_id1 = d.b1_master_id1 and p.b1_per_id2 = d.b1_master_id2 and p.b1_per_id3 = d.b1_master_id3
             and not exists 
              (   
                select 1          
                from 
                  dbo.b1permit ip  with (nolock)  join  dbo.gprocess_history dd with (nolock) 	on  
                  ip.serv_prov_code = dd.serv_prov_code  and ip.b1_per_id1 = dd.b1_per_id1 and ip.b1_per_id2 = dd.b1_per_id2  and ip.b1_per_id3 = dd.b1_per_id3  
                where                
                   p.b1_alt_id = ip.b1_alt_id and dd.sd_app_des = 'Issued' and dd.sd_pro_des = 'Issuance'  and ip.serv_prov_code = 'TAMPA'               
               )
          )  pid  
          , p.b1_per_sub_type , p.b1_per_type, p.b1_file_dd, p.b1_special_text , p.b1_appl_status permit_status,   
            CASE WHEN IsNumeric( CONVERT(VARCHAR(12), dbo.FN_GET_APP_SPEC_INFO('TAMPA', p.b1_per_id1, p.b1_per_id2, p.b1_per_id3, 'Job Value') )  ) = 1 then  
                round ( dbo.FN_GET_APP_SPEC_INFO('TAMPA', p.b1_per_id1, p.b1_per_id2, p.b1_per_id3, 'Job Value') , 2, 0 )  else 0 End  AS job_value 	
          , reverse( SUBSTRING(  reverse( dbo.FN_GET_PRI_ADDRESS_FULL('TAMPA', p.b1_per_id1, p.b1_per_id2, p.b1_per_id3  )), 1, 5) ) zip
     from    
        dbo.b1permit p with (nolock) 	
        JOIN dbo.xapp2ref d with (nolock) ON  p.serv_prov_code = d.serv_prov_code and p.b1_per_id1 = d.b1_master_id1 and p.b1_per_id2 = d.b1_master_id2 and p.b1_per_id3 = d.b1_master_id3
         JOIN dbo.b1permit id with (nolock) ON   d.serv_prov_code = id.serv_prov_code and d.b1_per_id1 = id.b1_per_id1 and d.b1_per_id2 = id.b1_per_id2 and d.b1_per_id3 = id.b1_per_id3   				
     where                                
         p.rec_status = 'A' and p.b1_per_group = 'Building' and p.b1_per_type in ( 'Residential' ) and  p.serv_prov_code = 'TAMPA'                                                 				
         and p.b1_per_sub_type in ( 'New Construction and Additions' )  and  p.b1_per_category = 'NA'   
         and dbo.FN_GET_APP_SPEC_INFO('TAMPA', p.b1_per_id1, p.b1_per_id2, p.b1_per_id3, 'New Construction') =  'Yes'  
         and len( p.b1_alt_id ) = 14  and substring ( id.b1_alt_id, 1,3) in ( 'HSS' )  
     ) ilv   
  where 
       pid >= 5 and  pid <  5+1  
)
ilv