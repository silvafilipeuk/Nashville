USE Nashville 

GO

select *
FROM dbo.Nashville

-- Standarize Date Format


ALTER TABLE Nashville
ADD SaleDate2 Date;

UPDATE Nashville
SET SaleDate2 = CONVERT(Date,SaleDate)

ALTER TABLE NAshville
DROP COLUMN SaleDate


EXEC sp_rename 'dbo.Nashville.SaleDate2', 'SaleDate', 'COLUMN';