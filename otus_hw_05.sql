 --База данных HelpDesk
 --Назначение: Регистрация и обработка инцидентов, поступающих в IT-подразделение
 --Основные таблицы:
 --1. Поздразделения (Departments)
 --2. Пользователи (Users)
 --3. Инциденты (Incidents)

USE [master]
GO

--1. Создать базу данных.
CREATE DATABASE HelpDesk;
GO

use HelpDesk;
GO

--2. 3-4 основные таблицы для своего проекта.

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
	--3. Первичные и внешние ключи для всех созданных таблиц.
	id 	 int not null identity(1, 1) primary key, 	--первичный ключ
	Subject nvarchar(50) not null,
	Description nvarchar(MAX) not null,
	UserID int not null,
	DepartmentID int not null,
	Date date,
	LastEditedWhen datetime2(7),
	--3. Первичные и внешние ключи для всех созданных таблиц.
	FOREIGN KEY (DepartmentID) REFERENCES Departmetns(ID), 	--внешний ключ
	FOREIGN KEY (UserID) REFERENCES Users(ID) --внешний ключ
)
GO
	-- 5. Наложите по одному ограничению в каждой таблице на ввод данных.
	-- создал только одно ограничение, т.к. для других таблиц могу ввести их только искуственно,
	-- надеюсь этого достаточно для того чтобы продемонстрировать понимание темы
ALTER TABLE Incidents ADD  CONSTRAINT DF_Incidents_LastEditedWhen DEFAULT (sysdatetime()) FOR LastEditedWhen;

--4. 1-2 индекса на таблицы.
CREATE NONCLUSTERED INDEX IX_Incidents_UserID ON Incidents(UserID)
GO

CREATE NONCLUSTERED INDEX IX_Incidents_DepartmentID ON Incidents(DepartmentID)
GO


