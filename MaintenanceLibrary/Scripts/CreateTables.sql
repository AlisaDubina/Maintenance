-- Создание таблиц базы данных "Техобслуживание"

-- удаление существующих таблиц
drop table if exists BrakeFacts;
drop table if exists RepairFacts;
drop table if exists Malfunctions;
drop table if exists [Services];
drop table if exists Cars;
drop table if exists Colors;
drop table if exists BrandModels;
drop table if exists Workers;
drop table if exists Clients;
drop table if exists Persons;
drop table if exists Specialties;
go


-- Таблица -  справочник специальностей работников
create table dbo.Specialties (
	Id          int          not null primary key identity (1, 1),
	Speciality  nvarchar(40) not null    -- название специальности
);
go


-- Таблица персональных данных, одинаковых для работников 
-- и клиентов - Persons
create table dbo.Persons (
	Id          int          not null primary key identity (1, 1),
	Passport    nvarchar(15) not null,    -- Серия и номер паспорта персоны
	Surname     nvarchar(60) not null,    -- Фамилия персоны
	[Name]      nvarchar(50) not null,    -- Имя персоны
	Patronymic  nvarchar(60) not null     -- Отчество персоны
);
go


-- Таблица сведений о клиентах
create table dbo.Clients (
	Id              int           not null primary key identity (1, 1),
	IdPerson        int           not null,    -- Внешний ключ, связь с персональными данными
	BornDate        date          not null,    -- Дата рождения 
	ResidencePermit nvarchar(255) not null     -- Прописка 
	
	-- внешний ключ - связь 1:1 к таблице Persons
	constraint  FK_Clients_Persons foreign key (IdPerson) references dbo.Persons(Id)
);
go


-- Таблица сведений о работниках
create table Workers(
    Id             int          not null primary key identity(1, 1),
	IdPerson       int          not null,  -- Внешний ключ, связь с персональными данными
	IdSpecialty    int          not null,  -- Внешний ключ, связь с специальностями
	Category       nvarchar(60) not null,  -- Разряд
	Salary         float        not null,  -- Должностной оклад
	WorkExperience int          not null,  -- Стаж работы
	IsDismissed    bit          not null,  -- Признак уволен (true - уволен)

	constraint  FK_Workers_Persons     foreign key (IdPerson)    references dbo.Persons(Id),
	constraint  FK_Workers_Specialties foreign key (IdSpecialty) references dbo.Specialties(Id)
);
go


-- Названия моделей автомобилей, включая бренд
create table BrandModels (
	Id          int          not null primary key identity (1, 1),
	BrandModel  nvarchar(30) not null    -- название бренда, модели
);
go


-- Названия цветов автомобилей
create table Colors (
	Id     int          not null primary key identity (1, 1),
	Color  nvarchar(30) not null    -- название цвета
);
go

-- Таблица автомобилей 
create table dbo.Cars (
    Id          int          not null primary key identity (1, 1),
	IdBrand     int          not null, -- внешний ключ, ссылка на BravdModels, бренд-модель автомобиля
	IdColor     int          not null, -- внешний ключ, ссылка на Colors, цвет автомобиля
	IdClient    int          not null, -- внешний ключ, ссылка на Clients, владелец автомобиля
	Plate       nvarchar(12) not null, -- гос. регистрационный номер автомобиля
	YearManuf   int          not null, -- год производства автомобиля

	-- ограничение уникальности значения столбца
	constraint  CK_Cars_Plate       unique(Plate),
	
	-- внешние ключи
	constraint  FK_Cars_Clients foreign key (IdClient) references dbo.Clients(Id), 
	constraint  FK_Cars_BrandModels foreign key (IdBrand) references dbo.BrandModels(Id), 
	constraint  FK_Cars_Colors foreign key (IdColor) references dbo.Colors(Id) 
);
go


-- Таблица услуг, оказываемых станцией
create table dbo.[Services] (
    Id             int          not null primary key identity (1, 1),
	[Service]      nvarchar(80) not null, -- название услуги
	WorkCost       int          not null, -- стоимость услуги
	SparePartsCost int          not null, -- стоимость запчастей

    -- ограничения полей таблицы
	constraint CK_Services_WorkCost       check (WorkCost > 0),
	constraint CK_Services_SparePartsCost check (SparePartsCost >= 0)
);
go


-- Таблица неисправностей
create table Malfunctions (
	Id           int          not null primary key identity (1, 1),
	Malfunction  nvarchar(50) not null    -- описание неисправности
);
go


-- Таблица фактов ремонта
create table dbo.RepairFacts (
    Id          int          not null primary key identity (1, 1),
	IdCar       int          not null, -- внешний ключ, ссылка на Cars, автомобиль
	IdClient    int          not null, -- внешний ключ, ссылка на Clients (Клиент сдает в ремонт не обязательно автомобиль, владельцем которого он является)
	DateStart   date         not null, -- дата начала ремонта
    DateFinish  date         not null, -- дата возврата автомобиля
	
	-- внешние ключи
	constraint  FK_RepairFacts_Cars foreign key (IdCar) references dbo.Cars(Id), 
	constraint  FK_RepairFacts_Clients foreign key (IdClient) references dbo.Clients(Id), 
);
go


-- Таблица фактов поломки
create table dbo.BrakeFacts (
    Id            int          not null primary key identity (1, 1),
	IdMalfunction int          not null, -- внешний ключ, ссылка на Malfunctions, неисправность
	IdWorker      int          not null, -- внешний ключ, ссылка на Workers, работник
	IdRepairFact  int          not null, -- внешний ключ, ссылка на RepairFacts, факт ремонта
	IdService     int          not null, -- внешний ключ, ссылка на Services, улуга
	[DateTime]    datetime     not null, -- время устранения неисправности
	
	-- внешние ключи
	constraint  FK_BrakeFacts_RepairFacts foreign key (IdRepairFact) references dbo.RepairFacts(Id), 
	constraint  FK_BrakeFacts_Workers foreign key (IdWorker) references dbo.Workers(Id), 
	constraint  FK_BrakeFacts_Malfunctions foreign key (IdMalfunction) references dbo.Malfunctions(Id), 
	constraint  FK_BrakeFacts_Services foreign key (IdService) references dbo.[Services](Id), 
);
go
