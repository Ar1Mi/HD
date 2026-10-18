-- Polska strona kodowa (1250) dla kolumn varchar, zgodna z plikami źródłowymi
ALTER DATABASE Studenci COLLATE Polish_CI_AS;
GO
USE Studenci;
GO
-- Ćwiczenie 1.2 [3] + Zadanie 1.1: tabela docelowa
IF OBJECT_ID(N'dbo.ImieNazwisko') IS NULL
    CREATE TABLE dbo.ImieNazwisko (
        Student  varchar(250),
        NrAlbumu varchar(10)
    );
GO
SELECT DATABASEPROPERTYEX(N'Studenci', 'Collation') AS collation;
