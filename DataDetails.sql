

use Base_01
go


CREATE PROCEDURE DataDetails (  
   @Cnpj VARCHAR(20)  
 , @StartDate DATETIME = NULL  
) AS   
BEGIN  

 -- Localiza a Instalação  
 DECLARE @CleanCnpj VARCHAR(20) = Base_01.dbo.fnGetNumericCharacters(@Cnpj)  
 DECLARE @ID INT = (SELECT TOP 1 ii.ID   
 FROM User_Table (nolock) ii   
 WHERE   
  ii.Cnpj IN (@Cnpj, @CleanCnpj)  
  AND ii.DeletedDate IS NULL  
 ORDER BY  
  ii.ID   
 );  
  
 IF(ISNULL(@ID, 0) = 0)  
  RETURN;  
  
 -- Determina o Periodo  
 DECLARE @MaxStartDate DATETIME = DATEADD(month, DATEDIFF(month, 0, DATEADD(m, -1, GETDATE())), 0)  
 DECLARE @MinStartDate DATETIME = DATEADD(month, -12, @MaxStartDate)  
  
 SET @StartDate = IIF(@StartDate IS NULL, @MaxStartDate, DATEADD(month, DATEDIFF(month, 0, @StartDate), 0))  
  
 IF(NOT (@StartDate BETWEEN @MinStartDate AND @MaxStartDate))  
  SET @StartDate = IIF(@StartDate < @MinStartDate, @MinStartDate, @MaxStartDate);  
  
 DECLARE @EndDate DATETIME = EOMONTH(@StartDate)  
  
 --SELECT @StartDate, @EndDate, @Cnpj, @CleanCnpj, @ID  
  

/* Dados do Estabelecimento */

DECLARE 
	@Company VARCHAR(500) = 

	( SELECT 
		TOP 1
		  ii.Company 
	FROM 
		User_Table ii
	WHERE   
		ii.Cnpj IN (@Cnpj, @CleanCnpj)  
		AND ii.DeletedDate IS NULL  
	

	)

 , 	@Name VARCHAR(500) = 

	( SELECT 
		TOP 1
		  ii.Name 
	FROM 
		User_Table ii
	WHERE   
		ii.Cnpj IN (@Cnpj, @CleanCnpj)  
		AND ii.DeletedDate IS NULL  
	

	)

 , 	@Cnae VARCHAR(500) = 

	( SELECT 
		TOP 1
		  ii.CnaeRFB 
	FROM 
		User_Table ii
	WHERE   
		ii.Cnpj IN (@Cnpj, @CleanCnpj)  
		AND ii.DeletedDate IS NULL  
	
	)

 , 	@Segment VARCHAR(500) = 

	( SELECT 
		TOP 1
		  s.Name 
	FROM 
		User_Table ii
		INNER JOIN 
			Segment (NOLOCK) s on s.SegmentID = ii.SegmentID 
	WHERE   
		ii.Cnpj IN (@Cnpj, @CleanCnpj)  
		AND ii.DeletedDate IS NULL  
	

	)

 , 	@Address VARCHAR(500) = 

	( SELECT 
		TOP 1
		  ii.Address 
	FROM 
		User_Table ii
	WHERE   
		ii.Cnpj IN (@Cnpj, @CleanCnpj)  
		AND ii.DeletedDate IS NULL  
	

	)


 , 	@AddressNumber VARCHAR(500) = 

	( SELECT 
		TOP 1
		  ii.AddressNumber 
	FROM
		User_Table ii
	WHERE   
		ii.Cnpj IN (@Cnpj, @CleanCnpj)  
		AND ii.DeletedDate IS NULL  
	

	)

 , 	@AddressComplement VARCHAR(500) = 

	( SELECT 
		TOP 1
		  ii.AddressComplement 
	FROM 
		User_Table ii
	WHERE   
		ii.Cnpj IN (@Cnpj, @CleanCnpj)  
		AND ii.DeletedDate IS NULL  
	
	)

 , 	@AddressZipCode VARCHAR(500) = 

	( SELECT 
		TOP 1
		  ii.AddressZipCode 
	FROM 
		User_Table ii
	WHERE   
		ii.Cnpj IN (@Cnpj, @CleanCnpj)  
		AND ii.DeletedDate IS NULL  
	
	)

 , 	@AddressQuarter VARCHAR(500) = 

	( SELECT 
		TOP 1
		  ii.AddressQuarter 
	FROM 
		User_Table ii
	WHERE   
		ii.Cnpj IN (@Cnpj, @CleanCnpj)  
		AND ii.DeletedDate IS NULL  
	
	)

 , 	@State VARCHAR(500) = 

	( SELECT 
		TOP 1
		  ii.State 
	FROM 
		User_Table ii
	WHERE   
		ii.Cnpj IN (@Cnpj, @CleanCnpj)  
		AND ii.DeletedDate IS NULL  
	
	)

 , 	@City VARCHAR(500) = 

	( SELECT 
		TOP 1
		  ii.City 
	FROM 
		User_Table ii
	WHERE   
		ii.Cnpj IN (@Cnpj, @CleanCnpj)  
		AND ii.DeletedDate IS NULL   
	
	
---------------------------------------------------

  DECLARE @QuotationCustomers INT = (SELECT COUNT(1) FROM SaleBudget (nolock) sb   -- qtde de orçamentos
  WHERE   
   sb.UserID = @ID  
   AND sb.dateIssue BETWEEN @StartDate AND @EndDate)  
  

  DECLARE @OrderCustomers INT = (SELECT COUNT(1) FROM SaleOrder(nolock) so   -- qtde de pedidos de vendas
  WHERE   
   so.id_omega = @ID  
   AND so.dateIssue BETWEEN @StartDate AND @EndDate)  

 
  DECLARE @CouponCustomers INT = (SELECT COUNT(1) FROM Coupon (nolock) cp   -- qtde de cupons
  WHERE   
   cp.id_omega = @ID  
   AND cp.dt_coupon BETWEEN @StartDate AND @EndDate)  
 
 
  DECLARE @CustomersAmount INT = ISNULL(@QuotationCustomers, 0) + ISNULL(@OrderCustomers, 0) + ISNULL(@CouponCustomers, 0)  -- qtde total geral (orçamento, PV, PDV (cupom) )
 
---------------------------------------------------

/* QTDE DE CUPONS E O VALOR */
 DECLARE 
	@CouponSales INT, @CouponValue DECIMAL(15,2)  
 SELECT 
	@CouponSales = COUNT(1), @CouponValue = SUM(cp.vl_total)   
 FROM 
	Coupon (nolock) cp   
 WHERE   
  cp.UserID = @ID  
  AND cp.dt_coupon BETWEEN @StartDate AND @EndDate  
  AND cp.in_canceled = 0  
     
--total vendas
 DECLARE @SalesAmount INT = ISNULL(@OrderSales, 0) + ISNULL(@CouponSales, 0)  -- qtde vendas

 DECLARE @SalesValue DECIMAL(15,2) = ISNULL(@OrderValue, 0) + ISNULL(@CouponValue, 0)  -- qtde vendas - valor
  
---------------------------------------------------

 
SELECT   
    @StartDate   [Period]  
 ,  @CleanCnpj    [Cnpj]  
 
 , @Company [Company]
 , @Name [Name]
 , @Cnae [Cnae]
 , @Segment [Segment]
 , @Address [Address]
 , @AddressNumber [AddressNumber]
 , @AddressComplement [AddressComplement]
 , @AddressZipCode [AddressZipCode]
 , @AddressQuarter [AddressQuarter]
 , @State [State]
 , @City [City]

 , @CustomersAmount  [CustomerAmount] -- qtde total geral (orçamento, PV, PDV (cupom) )

 , @SalesAmount   [SalesAmount]	-- total qtde de vendas ( pedido de venda + cupom )

 , @SalesValue   [SalesValue] -- total de vendas ( pedido de venda + cupom )


END  
