--task3



-- exercise 3.1

--на уровнетаблицы

drop table if exists A_1, B_1

create table A_1(
id bigserial not null primary key,
data varchar(20))

create table B_1(
id bigserial not null primary key,
data varchar(20),
a_id bigint,
foreign key (a_id) references A_1 (id))

insert into B_1(data)
values 
	('Kasym'),
	('Misha'),
	('Nastya')
	
insert into A_1(data)
values 
	('Novosibirsk'),
	('Moscow'),
	('Atyrau'),
	('Astana'),
	('Omsk'),
	('Sochi'),
	('Kazan')
	
insert into B_1(id, data)
values
	(1, 'Kostya'),
	(2, 'Misha')
	
delete from A_1
where data = 'Moscow'

update A_1
set id = 20
where id = 1
	
	
insert into B_1(data, a_id)
select A_1.data, A_1.id from A_1

delete from A_1
where data = 'Atyrau'

update A_1
set id = 2022
where id = 2


select * from A_1

select * from B_1

------ на уровне SQL запроса
drop table if exists A_2, B_2


create table A_2(
id bigserial not null primary key,
data varchar(20))

create table B_2(
id bigserial not null primary key,
data varchar(20),
a_id bigint,
foreign key (a_id) references A_2 (id) on delete restrict on update cascade)

--on delete restrict - если есть запись в В, то не удалится соответствующий из А
--on update cascade - если изменились данные о записи А, то в В все обновится

insert into B_2(data)
values 
	('Kasym'),
	('Misha'),
	('Nastya')
	
insert into A_2(data)
values 
	('Novosibirsk'),
	('Moscow'),
	('Atyrau'),
	('Astana'),
	('Omsk'),
	('Sochi'),
	('Kazan')
	
insert into B_2(id, data)
values
	(1, 'Kostya'), --foreign key error
	(2, 'Misha')
	
insert into B_2(data, a_id)
select A_2.data, A_2.id from A_2

delete from A_2 
where data = 'Moscow'  -- foreign key restrict

update A_2
set data = 'California'
where data = 'Atyrau'

update A_2
set id = 2022
where id = 1

select * from B_2

select * from A_2


--exesice 3.2

--один к одному
create table people(
id bigserial not null primary key,
person_name varchar(30)
)

create table inn(
id bigserial not null primary key,
inn_number bigint not null,
person_id bigint not null,
foreign key (person_id) references people (id) on delete cascade on update cascade)

--многие ко многим - ***
--многие ко многим - связь

create table food(
food_id bigserial not null primary key,
food_name varchar(20) not null)

insert into food(food_name)
values
	('Молоко'),
	('Хлеб'),
	('Сыр'),
	('Шоколад'),
	('Кофе')

create table food_chain(
id bigserial not null primary key,
f_id bigint not null,
s_id bigint not null,
foreign key (f_id) references food (food_id) on delete restrict on update cascade,
foreign key (s_id) references food_supplier (food_sup_id) on delete restrict on update cascade)

create table food_supplier(
food_sup_id bigserial not null primary key,
food_sup_name varchar(20) not null,
food_sup_phone varchar(20))

insert into food_supplier(food_sup_name, food_sup_phone)
values 
	('ООО Happy Food', '+7(960)753-10-10'),
	('ИП Питание','+7(856)092-03-03'),
	('ООО Food Master','+7(953)743-33-77'),
	('OAO Snack','+7(800)800-80-80'),
	('ООО InterPastry','+7(800)444-44-00')

--один ко многим - когда одной записи из главной таблицы сопоставляется множетсво значений из связанной таблицы 
--и когда каждой записи из связанной таблицы сопоставляется ! запись из главной таблицы
--один ко многим- связь водитель - авто

create table driver(
id bigserial not null primary key,
driver_name varchar(30) not null)

create table car(
id bigserial not null primary key,
car_number varchar(10),
driver_id bigint not null,
foreign key (driver_id) references driver (id) on delete set null)

	

 
--exercise 3.3

drop table if exists people

create table people(
id bigserial not null primary key,
mother_name varchar(20),
father_name varchar(20),
first_name varchar(20) not null,
second_name varchar(20) not null,
last_name varchar(20) not null,
date_of_birth date not null,
city_of_birth varchar(20),
registr_date date,
home_street varchar (20),
house_number int,
flat_number int,
work_place varchar(20),
work_adress varchar(20),
cell_phone varchar(14),
stationary_phone varchar(12),
pasport_number int)

--например, хотим получить дату рождения, но для этого нужно объединять несколько атрибутов
--ФИО - то же самое
--столько имен! ужасно! 

insert into people(mother_name, father_name, first_name, second_name, last_name, date_of_birth, city_of_birth, registr_date, home_street, house_number, flat_number, work_place, work_adress, cell_phone, stationary_phone, pasport_number)
values 
	('Анна', 'Олег', 'Михаил', 'Буфетов', 'Олегович', '1978-03-12', 'Томск', '1996-02-20', 'пр. Ленина', 2, 24, 'CoSpace Ltd', 'Продольная 12 оф. 4', '+7(960)8434390', '254-34-67', 654023),
	('Вера', 'Михаил', 'Светлана', 'Булкина', 'Михайловна', '1998-03-25', 'Тюмень', '2000-12-12', 'Марковная', 7, 14, 'У Дяди Васи', 'центральная 1', '+7(920)9431356', '340-45-67', 109324),
	('Лена', 'Виктор', 'Виктор', 'Тумбочкин', 'Викторович', '1987-05-22', 'Иркутск', '1996-02-20', 'пр. Ленина', 19, 4, 'CompArts Inc', 'Днепровская 7 оф 123', '+7(927)2203910', '203-234-231', 750237),
	('Лена', 'Олег', 'Павел', 'Петров', 'Олегович', '1991-02-07', 'Новосибирск', '1996-02-20', 'Карла Маркса', 17, 7, 'Думадуй', 'научная 13 оф 345', '+7(834)6559181', '531-45-51', 467416),
	('Антонина', 'Евгений', 'Евгения', 'Буфетова', 'Евгеньевна', '1988-08-18', 'Новосибирск', '2007-07-27', 'пр. Лукашкино', 27, 14, 'Красота', 'Инженерная 15 оф 123', '+7(960)9007455', '290-88-39', 873301)
	
select * from people 

select concat_ws(' ', first_name, second_name, last_name) from people 

select first_name, city_of_birth 
from people 
where work_place like '%Ltd'

select first_name, date_of_birth
from people where city_of_birth = 'Новосибирск'

delete from people 
where second_name = 'Буфетов'

---a вдруг где-то Ltd.
update people
set cell_phone = 0
where work_place like '%Ltd'
--сделаем update по улице или work_place, a вдруг другое немного название? точка не там
--а у нач 100500+ дейсвий выполнились
	
	
--exercise 3.4

--1 НФ - если все атрибуды содержат атомарные значения (по определению все таблицы в 1 НФ)

--2НФ - если находится в 1НФ, и все неключевые атрибуты функционально полно зависят от первичного ключа

--3НФ - если находится в 2НФ и все неключевые атрибуты зависят только от первичного ключа
--Транзитивная зависимость - косвенная связь между значения в одной и той же таблице, которая вызывает функциональную зависимость

--таблица находится в 4НФ - если она находится в НФБК и не содержит многозначных зависимостей
--НФБК - т.и.т, когда детерминанты функциональных зависимостей являются первичными ключами.


--не нормальная избыточная форма
магазин: (торговый зал)
	название(имя, адрес)
	товары(название, цена продажи, цена поставки, поставшик, кол-во)

--как альтернатива:
--1НФ
кофе:
	название
	сорт
	фирма
	склад
	адрес
	район_доставки
	цена
	скидка
	

--2НФ
кофе:
	название
	сорт
	склад
	район_доставки
	адрес
	цена
	
фирма:
	название
	скидка
		
--скидка больше зависит от поставщика, чем от названия - неполная зависимость
				
--3НФ

--у кофе не может быть адреса, кофе->склад->адрес, т.е. существует транзитивная зависимость:

кофе:  
	название
	сорт
	цена
	
склад:
	название
	адрес
	район_доставки
	
фирма:
	название
	скидка
		
--4НФ
склад:
	название
	адрес
	район_доставки
	
--название -> адрес
--название -> район_доставки
--таким образом у нас многозначная зависимость адрес и района доставки
	
--если добавим новую позицию нужно добавить новые записи районов доставки,
--если будет ошибка, то получится так, что опредленному виду кофе будут соответствовать оперделенные районы доставки
	
склад:
	название
	адрес
	
доставка:
	адрес
	район_доставки 
	
кофе:  
	сорт --арабика, робуста, смесь
	название --арабика-Бразилия, робуста- эфиопия.
	напиток --предполагаем, что напиток делается только из определенных сортов
	
--предположим, что ранее латте делали только на арабике, а теперь хотим на эспрессо смеси тоже 
	
фирма:
	название
	скидка
