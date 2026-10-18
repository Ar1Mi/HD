-- Ćwiczenie 1.2 [1]: baza Studenci z prostym modelem odzyskiwania
IF DB_ID(N'Studenci') IS NULL
    CREATE DATABASE Studenci;
GO
ALTER DATABASE Studenci SET RECOVERY SIMPLE;
GO
SELECT name, recovery_model_desc FROM sys.databases WHERE name = N'Studenci';
