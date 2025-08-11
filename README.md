# SQL Queries Documentation

## Introduction

This repository contains a set of SQL queries aimed at data analysis, statistics, and business optimization. The queries below address various requirements related to products, sales, brands, and sellers.

## Contents

Below are the SQL queries with detailed explanations:

### 1. Statistics of Products That Have Never Been Purchased
- Purpose:
Identify products that have never appeared in any orders.
- Displayed Information:
Product Name, Category Name, Brand Name, Supplier Name.
- SQL Query:

SELECT

  sp.TenSanPham AS 'Product Name',

  sp.TenDanhMuc AS 'Category Name',

  th.TenThuongHieu AS 'Brand Name',

  sp.NhaCungCap AS 'Supplier Name'

FROM
    
    SanPham sp

LEFT JOIN
    
    SanPhamTrongDonHang spd ON sp.MaSanPham = spd.MaSanPham

LEFT JOIN
    
    ThuongHieu th ON sp.MaThuongHieu = th.MaTH

WHERE
    
    spd.MaDonHang IS NULL;

  ### 2. Count the Number of Products by Each Brand
- Purpose:
Calculate the total number of products belonging to each brand.
- Displayed Information:
Brand Name, Product Count.
- SQL Query:

SELECT
    
    th.TenThuongHieu AS 'Brand Name',
    
    COUNT(sp.MaSanPham) AS 'Product Count'

FROM
   
    SanPham sp

JOIN
    
    ThuongHieu th ON sp.MaThuongHieu = th.MaTH

GROUP BY
    
    th.TenThuongHieu;

### 3. Products with the Highest Average Rating by Brand
- Purpose:
Find the product with the highest average rating for each brand.
- Displayed Information:
Brand Name, Product Name, Average Rating.
- SQL Query:

WITH AvgRatings AS (
    
    SELECT
       
        sp.MaSanPham,
        
        sp.MaThuongHieu,
        
        sp.TenSanPham,
        
        th.TenThuongHieu,
        
        AVG(dg.DiemDanhGia) AS AverageRating
    
    FROM
        
        SanPham sp
    
    INNER JOIN
        
        ThuongHieu th ON sp.MaThuongHieu = th.MaTH
    
    LEFT JOIN
       
        DanhGiaSanPham dg ON sp.MaSanPham = dg.MaSanPham
    
    GROUP BY
        
        sp.MaSanPham, sp.MaThuongHieu, sp.TenSanPham, th.TenThuongHieu
)

SELECT
    
    AR.MaThuongHieu AS 'Brand ID',
    
    AR.TenThuongHieu AS 'Brand Name',
    
    AR.TenSanPham AS 'Product Name',
    
    AR.AverageRating AS 'Average Rating'

FROM
    
    AvgRatings AR

JOIN (
    
    SELECT
        
        MaThuongHieu,
        
        MAX(AverageRating) AS MaxAverageRating
    
    FROM
        
        AvgRatings
    
    GROUP BY
        
        MaThuongHieu
) 
MaxRatings ON AR.MaThuongHieu = MaxRatings.MaThuongHieu
    
    AND AR.AverageRating = MaxRatings.MaxAverageRating;

### 4. Products Sold Less Than 10 Units in January 2024 by Seller "XYZ"
- Purpose:
Retrieve the information of products sold in quantities below 10 units by seller "XYZ" during January 2024.
- Displayed Information:
Product Name, Quantity Sold.
- SQL Query:

SELECT
    
    SanPham.TenSanPham AS 'Product Name',
    
    SUM(SanPhamTrongDonHang.SoLuong) AS 'Quantity Sold'

FROM DonHang

JOIN SanPhamTrongDonHang ON DonHang.MaDonHang = SanPhamTrongDonHang.MaDonHang

JOIN SanPham ON SanPhamTrongDonHang.MaSanPham = SanPham.MaSanPham

JOIN TaiKhoan ON DonHang.MaNhaCungCap = TaiKhoan.MaTaiKhoan

WHERE

    DonHang.TinhTrangDonHang IN ('Being Delivered', 'Successfully Delivered')
    
    AND (DonHang.NgayDatHang >= '2024-01-01' AND DonHang.NgayDatHang < '2024-02-01')
    
    AND TaiKhoan.TenTaiKhoan = 'XYZ'

GROUP BY

    SanPham.TenSanPham

HAVING

    SUM(SanPhamTrongDonHang.SoLuong) < 10;

### 5. Products Sold the Most by Month in 2023
- Purpose:
Find the best-selling product for each month of the year 2023.
- Displayed Information:
Month, Product Name, Quantity Sold.
- SQL Query:

WITH cte AS (
   
    SELECT
       
        MONTH(DonHang.NgayDatHang) AS 'Month',
        
        SanPham.TenSanPham AS 'Product Name',
        
        SUM(SanPhamTrongDonHang.SoLuong) AS 'Quantity Sold',
       
        DENSE_RANK() OVER(PARTITION BY MONTH(DonHang.NgayDatHang) ORDER BY SUM(SanPhamTrongDonHang.SoLuong) DESC) AS 'Rank'
   
    FROM DonHang
    
    JOIN SanPhamTrongDonHang ON DonHang.MaDonHang = SanPhamTrongDonHang.MaDonHang
    
    JOIN SanPham ON SanPhamTrongDonHang.MaSanPham = SanPham.MaSanPham
    
    WHERE
        
        DonHang.TinhTrangDonHang IN ('Being Delivered', 'Successfully Delivered')
        
        AND YEAR(DonHang.NgayDatHang) = 2023
   
    GROUP BY
       
        MONTH(DonHang.NgayDatHang), SanPham.TenSanPham
)

SELECT
   
    Month,
   
    ProductName,
    
    QuantitySold

FROM cte

WHERE
   
    Rank = 1;

### 6. Total Revenue of Seller "XYZ" by Month in 2023
- Purpose:
Calculate the total revenue of seller "XYZ" for each month of the year 2023 (only including successfully delivered orders).
- Displayed Information:
Month, Total Revenue.
- SQL Query:

SELECT
    
    MONTH(DonHang.NgayDatHang) AS 'Month',
    
    SUM(SanPham.Gia * SanPhamTrongDonHang.SoLuong * (1 - SanPhamTrongDonHang.GiamGia)) AS 'Revenue'

FROM DonHang

JOIN SanPhamTrongDonHang ON DonHang.MaDonHang = SanPhamTrongDonHang.MaDonHang

JOIN SanPham ON SanPhamTrongDonHang.MaSanPham = SanPham.MaSanPham

JOIN TaiKhoan ON DonHang.MaNhaCungCap = TaiKhoan.MaTaiKhoan

WHERE

    DonHang.TinhTrangDonHang IN ('Being Delivered', 'Successfully Delivered')
    
    AND YEAR(DonHang.NgayDatHang) = 2023
    
    AND TaiKhoan.TenTaiKhoan = 'XYZ'

GROUP BY MONTH(DonHang.NgayDatHang);
