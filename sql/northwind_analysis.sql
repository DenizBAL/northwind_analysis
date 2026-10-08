	SELECT e.FirstName + ' ' + e.LastName  AS 'Çalışan',
	m.FirstName + ' ' + m.LastName  AS 'Yönetici'
	FROM Employees e
	LEFT JOIN Employees m ON e.ReportsTo=m.EmployeeID

	-- Andrew Fuller Yönetici 5 çalışana bakıyor. Steven Buchanan yönetici yardımcısı 3 çalışana bakıyor.

	SELECT e.FirstName+ ' ' + e.LastName AS 'Çalışan', t.TerritoryDescription as 'Sorumlu Bölge'
	FROM Employees e
	LEFT JOIN EmployeeTerritories et ON e.EmployeeID= et.EmployeeID
	LEFT JOIN Territories t ON t.TerritoryID=et.TerritoryID

	-- "Çalışan+ ID + Sorumlu Bölge" zinciri takip edilerek. Çalışanların hangi bölgeden sorumlu olduğu bulundu.


	SELECT e.FirstName + ' ' + e.LastName AS Calisan,
       COUNT(et.TerritoryID) AS BolgeSayisi
	FROM Employees e
	LEFT JOIN EmployeeTerritories et ON e.EmployeeID = et.EmployeeID
	GROUP BY e.FirstName, e.LastName
	ORDER BY BolgeSayisi DESC;
	
	-- Çalışanlar kaç bölgeye bakıyor. Robert King Adlı çalışan en çok bölgeye bakan kişidir.

----------------------------------------------------------------------------------------------------------

		-- 1) Sipariş toplamları
	SELECT o.OrderID, o.CustomerID,
		   SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS OrderTotal
	FROM Orders o
	JOIN [Order Details] od ON o.OrderID = od.OrderID
	GROUP BY o.OrderID, o.CustomerID;

	-- 2) Cirosuna göre ilk 10 müşteri
	SELECT TOP 10 c.CompanyName,
		   SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS Ciro
	FROM Customers c
	JOIN Orders o ON c.CustomerID = o.CustomerID
	JOIN [Order Details] od ON o.OrderID = od.OrderID
	GROUP BY c.CompanyName
	ORDER BY Ciro DESC;

	-- 3) Aylık ciro ve kümülatif toplam
	WITH Aylik AS (
	  SELECT DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS Ay,
			 SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS Ciro
	  FROM Orders o
	  JOIN [Order Details] od ON o.OrderID = od.OrderID
	  GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
	)
	SELECT Ay, Ciro, SUM(Ciro) OVER (ORDER BY Ay) AS KumulatifCiro
	FROM Aylik;

	-- 4) Geciken sevkiyatlar (kargo firmasına göre)
	SELECT s.CompanyName,
		   COUNT(*) AS ToplamSevkiyat,
		   SUM(CASE WHEN o.ShippedDate > o.RequiredDate THEN 1 ELSE 0 END) AS Geciken
	FROM Orders o
	JOIN Shippers s ON o.ShipVia = s.ShipperID
	WHERE o.ShippedDate IS NOT NULL
	GROUP BY s.CompanyName;

	-- 5) Stok kritik seviyede olan ürünler
	SELECT p.ProductName, su.CompanyName AS Tedarikci,
		   p.UnitsInStock, p.UnitsOnOrder, p.ReorderLevel
	FROM Products p
	JOIN Suppliers su ON p.SupplierID = su.SupplierID
	WHERE p.UnitsInStock + p.UnitsOnOrder < p.ReorderLevel
	  AND p.Discontinued = 0;