CREATE PROCEDURE dbo.CreateCouponCampaign (    
 @CreateUserID INT,         
 @PricePercent DECIMAL(15,2), 
 @Coupon VARCHAR(100),    
 @DateStart DATETIME,    
 @DateExpire DATETIME,
 @SignatureList VARCHAR(MAX),
 @PlanList VARCHAR(MAX),
 @ShowUserID INT = NULL,
)  AS      
BEGIN      
 
 DECLARE @Signature TABLE (SignatureID INT)    
 INSERT INTO @Signature     
 SELECT [value] FROM dbo.fnSplitStringToIntTable(@SignatureList, ',')    

 DECLARE @Plan TABLE (PlanID INT)    
 INSERT INTO @Plan     
 SELECT [value] FROM dbo.fnSplitStringToIntTable(@PlanList, ',')  

DECLARE @tmpCoupon TABLE (CouponID INT)


	 INSERT INTO  Base_Coupon.dbo.Coupon (CreateUserID, ShowUserID, ID, ShowUserName, [Name], Coupon, Amount, AvailableAmount, DateStart, DateExpire, IsActive, DiscountPercentage) 
	 OUTPUT inserted.CouponID INTO @tmpCoupon
	 VALUES ( @CreateUserID, @ShowUserID, NULL, NULL,  NULL, @Coupon, 1, 1, @DateStart, @DateExpire, 1, @PricePercent )


	 INSERT INTO Base_Coupon.dbo.CouponProducts (CouponID, SignatureID, PlanID, Price, IsActive)    
	 SELECT 
		c.CouponID, st.SignatureID, p.PlanID, CAST(sp.Price - (@PricePercent/100 * sp.Price) AS DECIMAL(15,2)), 1    
	 FROM 
		Base_Signature.dbo.Signatures s  
		INNER JOIN 
			Marketup_Main..SignaturePlan sp on sp.SignatureID = s.SignatureID
		INNER JOIN 
			@Signature st on st.SignatureID = s.SignatureID
		INNER JOIN 
			@Plan p on p.PlanID = s.PlanID	
		CROSS APPLY 
			@tmpCoupon c
 
END
