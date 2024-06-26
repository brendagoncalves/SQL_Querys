CREATE PROCEDURE CompanyDetailsGet (  
  @Cnpj VARCHAR(20)  
 , @StartDate DATETIME = NULL  
) AS   
BEGIN  
  
 DECLARE @query NVARCHAR(MAX) = ''  
 IF (CHARINDEX('-dev', @@SERVERNAME) > 0 OR CHARINDEX('-hml', @@SERVERNAME) > 0)  
 BEGIN  
  SET @query = 'EXEC Base_01..DataDetails @cnpj = @Cnpj, @StartDate = @StartDate';  
 END  
 ELSE  
 BEGIN  
  SET @query = 'EXEC ServerOne.Base_01.dbo.DataDetails @Cnpj = @Cnpj, @StartDate = @StartDate';  
 END  
  
 EXEC sp_executesql  
  @stmt   = @query,  
  @params   = N'@Cnpj VARCHAR(20), @StartDate DATETIME',  
  @Cnpj = @Cnpj,   
  @StartDate = @StartDate   
    
END
