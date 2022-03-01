/* База данных «Техобслуживание»  */

-- справочник моделей автомобилей, включая бренд
select
   *
from
    BrandModels;
go

-- справочник цветов автомобилей
select
    *
from
    Colors;
go

-- справочник специальностей работников
select
    *
from
    Specialties;
go

-- персональные данные
select
    *
from
    Persons;
go

-- справочник неисправностей
select
    *
from
    Malfunctions;
go

-- услуги, оказываемые станцией
select
    *
from
    [Services];
go

-- клиенты
select
   Clients.Id
   , Persons.Surname
   , Persons.[Name]
   , Persons.Patronymic
   , Persons.Passport
   , Clients.BornDate
   , Clients.ResidencePermit
from
    Clients join Persons on Clients.IdPerson = Persons.Id;
go

-- работники
select
   Workers.Id
   , Persons.Surname
   , Persons.[Name]
   , Persons.Patronymic
   , Persons.Passport
   , Specialties.Speciality
   , Workers.Category
   , Workers.Salary
   , Workers.WorkExperience
from
    Workers join Persons on Workers.IdPerson = Persons.Id
            join Specialties on Workers.IdSpecialty = Specialties.Id;
go

-- автомобили
select
   Cars.Id
   , Persons.Surname + N' ' + Substring(Persons.[Name], 1, 1) + N'.' + Substring(Persons.Patronymic, 1, 1) + N'.' as [Owner]
   , BrandModels.BrandModel
   , Colors.Color
   , Cars.Plate
   , Cars.YearManuf
from
    Cars join (Clients join Persons on Clients.IdPerson = Persons.Id) on Cars.IdClient = Clients.Id
         join BrandModels on Cars.IdBrand = BrandModels.Id
         join Colors on Cars.IdColor = Colors.Id;
go

-- факты ремонта
select
   RepairFacts.Id
   , Cars.Plate as Car
   , Persons.Surname + N' ' + Substring(Persons.[Name], 1, 1) + N'.' + Substring(Persons.Patronymic, 1, 1) + N'.' as Client
   , RepairFacts.DateStart
   , RepairFacts.DateFinish
from
    RepairFacts join (Clients join Persons on Clients.IdPerson = Persons.Id) on RepairFacts.IdClient = Clients.Id
                join Cars on RepairFacts.IdCar = Cars.Id;
go

-- факты поломки
select
   BrakeFacts.Id
   , Cars.Plate as Car
   , Malfunctions.Malfunction
   , [Services].[Service]
   , Persons.Surname + N' ' + Substring(Persons.[Name], 1, 1) + N'.' + Substring(Persons.Patronymic, 1, 1) + N'.' as Worker
from
    BrakeFacts join (Workers join Persons on Workers.IdPerson = Persons.Id) on BrakeFacts.IdWorker = Workers.Id
               join (RepairFacts join Cars on RepairFacts.IdCar = Cars.Id) on BrakeFacts.IdRepairFact = RepairFacts.Id
               join Malfunctions on BrakeFacts.IdMalfunction = Malfunctions.Id
               join [Services] on BrakeFacts.IdService = [Services].Id;
go

-- запросы по заданию

-- Запрос 1. Фамилия, имя, отчество и адрес владельца автомобиля
--           с данным номером государственной регистрации.
declare @plate nvarchar(12) = N'О169РК';
select
   Cars.Plate
   , Persons.Surname 
   , Persons.[Name]
   , Persons.Patronymic
   , Clients.ResidencePermit
from
    Cars join (Clients join Persons on Clients.IdPerson = Persons.Id) on Cars.IdClient = Clients.Id
where
    Cars.Plate = @plate;
go
    

-- Запрос 2. Марка и год выпуска автомобиля данного владельца.
declare @passport nvarchar(12) = N'12 21 345671'; -- серия и номер паспорта владельца
select
   Cars.Plate
   , BrandModels.BrandModel
   , Cars.YearManuf
from
    Cars join (Clients join Persons on Clients.IdPerson = Persons.Id) on Cars.IdClient = Clients.Id
         join BrandModels on Cars.IdBrand = BrandModels.Id
where
    Persons.Passport = @passport;
go


-- Запрос 3. Перечень устраненных неисправностей в автомобиле данного владельца.
declare @passport nvarchar(12) = N'12 21 345671'; -- серия и номер паспорта владельца
select
   BrakeFacts.Id
   , Cars.Plate as Car
   , Malfunctions.Malfunction
from
    BrakeFacts join (RepairFacts join (Cars join (Clients join Persons on Clients.IdPerson = Persons.Id) on Cars.IdClient = Clients.Id) 
                                                   on RepairFacts.IdCar = Cars.Id) on BrakeFacts.IdRepairFact = RepairFacts.Id
               join Malfunctions on BrakeFacts.IdMalfunction = Malfunctions.Id
where 
    Persons.Passport = @passport;
go

-- Запрос 4. Фамилия, имя, отчество работника станции, устранявшего 
--           данную неисправность в автомобиле данного клиента, 
--           и время ее устранения.
declare @passport nvarchar(12) = N'12 21 345671', -- серия и номер паспорта клиента
        @malfunction nvarchar(50) = N'Неисправность двигателя'; -- неисправность

select
   Cars.Plate as Car
   , Malfunctions.Malfunction
   , Persons.Surname as WorkerSurname
   , Persons.[Name] as WorkerName
   , Persons.Patronymic as WorkerPatronymic
   , BrakeFacts.[DateTime]
from
    BrakeFacts join (Workers join Persons on Workers.IdPerson = Persons.Id) on BrakeFacts.IdWorker = Workers.Id
               join (RepairFacts join Cars on RepairFacts.IdCar = Cars.Id) on BrakeFacts.IdRepairFact = RepairFacts.Id
               join Malfunctions on BrakeFacts.IdMalfunction = Malfunctions.Id
               join (RepairFacts R join (Clients join Persons P on Clients.IdPerson = P.Id)
                      on R.IdClient = Clients.Id) on BrakeFacts.IdRepairFact = R.Id
where 
    P.Passport = @passport and Malfunctions.Malfunction = @malfunction;
go

-- Запрос 5. Фамилия, имя, отчество клиентов, сдавших в ремонт 
--           автомобили с указанным типом неисправности.
declare @malfunction nvarchar(50) = N'Неисправность двигателя';
select
   Cars.Plate as Car
   , Persons.Surname 
   , Persons.[Name]
   , Persons.Patronymic
   , Malfunctions.Malfunction
from
    BrakeFacts join (RepairFacts join (Clients join Persons on Clients.IdPerson = Persons.Id)
                      on RepairFacts.IdClient = Clients.Id) on BrakeFacts.IdRepairFact = RepairFacts.Id
               join Malfunctions on BrakeFacts.IdMalfunction = Malfunctions.Id
               join (RepairFacts Temp join Cars on Temp.IdCar = Cars.Id) on BrakeFacts.IdRepairFact = Temp.Id 
where 
    Malfunctions.Malfunction = @malfunction;
go

-- Запрос 6. Самая распространенная неисправность в автомобилях указанной марки.
declare @brand nvarchar(30) = N'Volkswagen Polo';
select
    BrandModels.BrandModel
    , Malfunctions.Malfunction
    , COUNT(*) as Amount
from
    BrakeFacts join Malfunctions on BrakeFacts.IdMalfunction = Malfunctions.Id
               join (RepairFacts join (Cars join BrandModels on Cars.IdBrand = BrandModels.Id) 
               on RepairFacts.IdCar = Cars.Id) on BrakeFacts.IdRepairFact = RepairFacts.Id 
where 
    BrandModels.BrandModel = @brand
group by
    BrandModels.BrandModel
    , Malfunctions.Malfunction
Order by 
    Amount desc;
go

-- Запрос 7. Количество рабочих каждой специальности на станции.
-- работники
select
    Specialties.Speciality
    , COUNT(*) as Amount
from
    Workers join Specialties on Workers.IdSpecialty = Specialties.Id
group by
    Specialties.Speciality
Order by 
    Amount desc;
go
