--a. Thống kê các sản phẩm chưa được mua lần nào. Thông tin hiển thị gồm: Tên sản phẩm, tên danh mục, tên thương hiệu, tên nhà cung cấp
SELECT 
    sp.TenSanPham AS 'Tên Sản Phẩm', 
    sp.TenDanhMuc AS 'Tên Danh Mục', 
    th.TenThuongHieu AS 'Tên Thương Hiệu', 
    sp.NhaCungCap AS 'Tên Nhà Cung Cấp'
FROM 
    SanPham sp
LEFT JOIN 
    SanPhamTrongDonHang spd ON sp.MaSanPham = spd.MaSanPham
LEFT JOIN 
    ThuongHieu th ON sp.MaThuongHieu = th.MaTH
WHERE 
    spd.MaDonHang IS NULL;

--b. Thống kê số lượng sản phẩm theo từng thương hiệu. Thông tin hiển thị gồm: Tên thương hiệu, số lượng sản phẩm
SELECT 
    th.TenThuongHieu, 
    COUNT(sp.MaSanPham) AS 'SoLuongSanPham'
FROM 
    SanPham sp
JOIN 
    ThuongHieu th ON sp.MaThuongHieu = th.MaTH
GROUP BY 
    th.TenThuongHieu;

--c. Lấy thông tin sản phẩm có điểm đánh giá trung bình lớn nhất theo từng thương hiệu. Thông tin hiển thị gồm: Tên thương hiệu, tên sản phẩm, điểm đánh giá trung bình.
WITH AvgRatings AS (
    SELECT
        sp.MaSanPham,
        sp.MaThuongHieu,
        sp.TenSanPham,
        th.TenThuongHieu,
        AVG(dg.DiemDanhGia) AS DiemDanhGiaTrungBinh
    FROM
        SanPham sp
    INNER JOIN
        ThuongHieu th ON sp.MaThuongHieu = th.MaTH
    LEFT JOIN
        DanhGiaSanPham dg ON sp.MaSanPham = dg.MaSanPham
 
    GROUP BY
        sp.MaSanPham,
        sp.MaThuongHieu,
        sp.TenSanPham,
        th.TenThuongHieu
)
SELECT
    AR.MaThuongHieu AS [Mã Thương Hiệu],
    AR.TenThuongHieu AS [Tên Thương Hiệu],
    AR.TenSanPham AS [Tên Sản Phẩm],
    AR.DiemDanhGiaTrungBinh AS [Điểm Đánh Giá Trung Bình]
FROM
    AvgRatings AR
JOIN (
    SELECT
        MaThuongHieu,
        MAX(DiemDanhGiaTrungBinh) AS MaxDiemDanhGiaTrungBinh
    FROM
        AvgRatings
    GROUP BY
        MaThuongHieu
) MaxRatings ON AR.MaThuongHieu = MaxRatings.MaThuongHieu
    AND AR.DiemDanhGiaTrungBinh = MaxRatings.MaxDiemDanhGiaTrungBinh;

--d. . Lấy thông tin các sản phẩm có số lượng bán được ít hơn 10 trong tháng 1 năm 2024 của tài khoản (người bán) "XYZ"
--   Các thông tin hiển thị: Tên sản phẩm, số lượng bán được.
SELECT 
	SanPham.TenSanPham
	, SUM(SanPhamTrongDonHang.SoLuong) as SoLuong
FROM DonHang
JOIN SanPhamTrongDonHang
	ON DonHang.MaDonHang = SanPhamTrongDonHang.MaDonHang
JOIN SanPham
	ON SanPhamTrongDonHang.MaSanPham = SanPham.MaSanPham
JOIN TaiKhoan
	ON DonHang.MaNhaCungCap = TaiKhoan.MaTaiKhoan
WHERE
	DonHang.TinhTrangDonHang in ('Dang giao','Da giao thanh cong')
	and (DonHang.NgayDatHang >= '2024-01-01' and DonHang.NgayDatHang < '2024-02-01')
	and TaiKhoan.TenTaiKhoan = 'trungkien1'
GROUP BY 
	SanPham.TenSanPham
HAVING 
	SUM(SanPhamTrongDonHang.SoLuong)  < 10

-- e. Lấy thông tin các sản phẩm có số lượng bán được nhiều nhất trong từng tháng của năm 2023.
--  Thông tin hiển thị gồm: Tháng, Tên sản phẩm, Số lượng bán được
WITH cte as (
	SELECT
		MONTH(DonHang.NgayDatHang) as Thang
		, SanPham.TenSanPham
		, SUM(SanPhamTrongDonHang.SoLuong) as SoLuong
		, DENSE_RANK() OVER(PARTITION BY MONTH(DonHang.NgayDatHang) ORDER BY SUM(SanPhamTrongDonHang.SoLuong) DESC) as rank
	FROM DonHang
	JOIN SanPhamTrongDonHang
		ON DonHang.MaDonHang = SanPhamTrongDonHang.MaDonHang
	JOIN SanPham
		ON SanPhamTrongDonHang.MaSanPham = SanPham.MaSanPham
	WHERE
		DonHang.TinhTrangDonHang in ('Dang giao','Da giao thanh cong')
		and YEAR(DonHang.NgayDatHang) = 2023
	GROUP BY 
		MONTH(DonHang.NgayDatHang) 
		, SanPham.TenSanPham
)
SELECT 
	Thang
	, TenSanPham
	, SoLuong
FROM cte
WHERE
	rank = 1
-- f. Thống kê tổng doanh thu của tài khoản (người bán) "XYZ" trong từng tháng của năm 2023, chỉ tính đơn hàng thành công.
--	Thông tin hiển thị gồm: Tháng, Tổng doanh thu
SELECT 
	MONTH(DonHang.NgayDatHang) as Thang
	, SUM(SanPham.Gia * SanPhamTrongDonHang.SoLuong * (1 - SanPhamTrongDonHang.GiamGia)) as DoanhThu
FROM DonHang
JOIN SanPhamTrongDonHang
	ON DonHang.MaDonHang = SanPhamTrongDonHang.MaDonHang
JOIN SanPham
	ON SanPhamTrongDonHang.MaSanPham = SanPham.MaSanPham
JOIN TaiKhoan
	ON DonHang.MaNhaCungCap = TaiKhoan.MaTaiKhoan
WHERE
	DonHang.TinhTrangDonHang in ('Dang giao','Da giao thanh cong')
	and YEAR(DonHang.NgayDatHang) = 2023
	and TaiKhoan.TenTaiKhoan = 'trungkien1'
GROUP BY MONTH(DonHang.NgayDatHang)





