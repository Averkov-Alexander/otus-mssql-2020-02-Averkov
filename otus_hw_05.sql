 --���� ������ HelpDesk
 --����������: ����������� � ��������� ����������, ����������� � IT-�������������
 --�������� �������:
 --1. �������������� (Departments)
 --2. ������������ (Users)
 --3. ��������� (Incidents)

USE [master]
GO

--1. ������� ���� ������.
CREATE DATABASE HelpDesk;
GO

use HelpDesk;
GO

--2. 3-4 �������� ������� ��� ������ �������.

CREATE TABLE Departmetns(
	id 	 int not null identity(1, 1)  primary key,
	Name nvarchar(100) not null
)
GO

CREATE TABLE Users(
	id 	 int not null identity(1, 1)  primary key,
	FullName nvarchar(100) not null,
	DepartmentID int not null,
	FOREIGN KEY (DepartmentID) REFERENCES Departmetns(ID)
)
GO

CREATE TABLE Incidents(
	--3. ��������� � ������� ����� ��� ���� ��������� ������.
	id 	 int not null identity(1, 1) primary key, 	--��������� ����
	Subject nvarchar(50) not null,
	Description nvarchar(MAX) not null,
	UserID int not null,
	DepartmentID int not null,
	Date date,
	LastEditedWhen datetime2(7),
	--3. ��������� � ������� ����� ��� ���� ��������� ������.
	FOREIGN KEY (DepartmentID) REFERENCES Departmetns(ID), 	--������� ����
	FOREIGN KEY (UserID) REFERENCES Users(ID) --������� ����
)
GO
	-- 5. �������� �� ������ ����������� � ������ ������� �� ���� ������.
	-- ������ ������ ���� �����������, �.�. ��� ������ ������ ���� ������ �� ������ �����������,
	-- ������� ����� ���������� ��� ���� ����� ������������������ ��������� ����
ALTER TABLE Incidents ADD  CONSTRAINT DF_Incidents_LastEditedWhen DEFAULT (sysdatetime()) FOR LastEditedWhen;

--4. 1-2 ������� �� �������.
CREATE NONCLUSTERED INDEX IX_Incidents_UserID ON Incidents(UserID)
GO

CREATE NONCLUSTERED INDEX IX_Incidents_DepartmentID ON Incidents(DepartmentID)
GO


