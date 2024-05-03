CREATE PROCEDURE SendDataNF	(@Recipients NVARCHAR(MAX))
AS
BEGIN 


DECLARE
    @subject NVARCHAR(200) = CONCAT(' Envio Mensal | Total NF ', CONVERT(nvarchar, GETDATE(), 103))
	
DECLARE
		@htmlBody NVARCHAR(MAX)=''

	SET @htmlBody = 
		+ N'	<html>'
		+ N'	<head>'
		+ N'	<style>'
		+ N'	table, th, td {'
		+ N'	  border: 1px solid black;'
		+ N'	  border-collapse: collapse;'
		+ N'	}'
		+ N'	th, td {'
		+ N'	  padding-left: 5px;'
		+ N'	  padding-right: 5px;'
		+ N'	}'
		+ N'	</style>'
		+ N'	</head>'
		+ N'	<body>'

		+ N'<H3>Total Geral</H3>' 
		+ N'<table>'
		+ N'<tr>
		<th>Qtde</th>'
		+ N'</tr>'
		+ CAST((
				SELECT					
					td = COUNT(1)
				FROM 
					Base_NF..NF_Main (NOLOCK) nf
				INNER JOIN 
					Base_NF..NF_Main_Control (NOLOCK) c ON nf.ID	  = c.ID 															           
									AND nf.NF_ID = c.NF_ID
				WHERE 
					c.id_status = 81 
				AND c.code = 110
				AND c.dt_created BETWEEN CONCAT(CAST(DATEADD(MONTH, -1, GETDATE()) AS DATE), ' 00:00:00') AND CONCAT(CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), ' 23:59:59')
				AND nf.dt_nf_issue BETWEEN CONCAT(CAST(DATEADD(DAY, -1, DATEADD(MONTH, -1, GETDATE())) AS DATE), ' 00:00:00') AND CONCAT(CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), ' 23:59:59')
				
	
				FOR XML PATH('tr'),
					TYPE
				) AS NVARCHAR(MAX))

		+ N'</table>'


		+ N'<H3>Total Por Modelo NF</H3>' 
		+ N'<table>'
		+ N'<tr>
		<th>Modelo</th><th>Qtde</th>'
		+ N'</tr>'
		+ CAST((
				SELECT	
					td = nf.id_model, '', 
					td = COUNT(1)					
				FROM 
					Base_NF..NF_Main (NOLOCK) nf
				INNER JOIN 
					Base_NF..NF_Main_Control (NOLOCK) c ON nf.ID	  = c.ID 															           
									AND nf.NF_ID = c.NF_ID
				WHERE 
					c.id_status = 81 
				AND c.code = 110
				AND c.dt_created BETWEEN CONCAT(CAST(DATEADD(MONTH, -1, GETDATE()) AS DATE), ' 00:00:00') AND CONCAT(CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), ' 23:59:59')
				AND nf.dt_nf_issue BETWEEN CONCAT(CAST(DATEADD(DAY, -1, DATEADD(MONTH, -1, GETDATE())) AS DATE), ' 00:00:00') AND CONCAT(CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), ' 23:59:59')
				GROUP BY 
					nf.id_model
	
				FOR XML PATH('tr'),
					TYPE
				) AS NVARCHAR(MAX))
		+ N'</table>'


		+ N'<H3>Total Por UF</H3>' 
		+ N'<table>'
		+ N'<tr>
		<th>UF</th><th>Qtde</th>'
		+ N'</tr>'
		+ CAST((
				SELECT 
						td = nf.company_uf, '',
						td = COUNT(1) 
				FROM 
					Base_NF..NF_Main (NOLOCK) nf
				INNER JOIN 
					Base_NF..NF_Main_Control (NOLOCK) c ON nf.ID	  = c.ID 															           
									AND nf.NF_ID = c.NF_ID
				WHERE 
					c.id_status = 81 
				AND c.code = 110
				AND c.dt_created BETWEEN CONCAT(CAST(DATEADD(MONTH, -1, GETDATE()) AS DATE), ' 00:00:00') AND CONCAT(CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), ' 23:59:59')
				AND nf.dt_nf_issue BETWEEN CONCAT(CAST(DATEADD(DAY, -1, DATEADD(MONTH, -1, GETDATE())) AS DATE), ' 00:00:00') AND CONCAT(CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), ' 23:59:59')
					GROUP BY 
						nf.company_uf
					ORDER BY 
						nf.company_uf
	
				FOR XML PATH('tr'),
					TYPE
				) AS NVARCHAR(MAX))
		+ N'</table>'


		+ N' </body>'
		+ N' </html>';
	   	 
	EXECUTE msdb.dbo.sp_send_dbmail 
		@profile_name = 'default', 
		@recipients = @Recipients,
		@Subject = @Subject, 
		@Body = @htmlBody,
		@body_format = 'HTML'


END 
GO
