--exercise 5

--exersise 5.1
--deadlock
drop table if exists player;

create table player(
player_id serial primary key,
player_name varchar(20),
player_points int);

insert into player(player_name, player_points)
values
	('BigKing', 120),
	('Eagle', 10),
	('Comandor', 210);

select * from player


-- если выполняют параллельно - словим deadlock,
--т.к. select ... for update по умолчанию устанавливает 
begin;
	select player_points  
	from player
	where player_id  = 1
	for update; --блокировка/ монопольный захват
	update player 
	set player_points = player_points - 2
	where player_id = 2;
commit;

begin;
	select player_points  
	from player 
	where player_id = 2
	for update;
	update player 
	set player_points = player_points + 2
	where player_id = 1;
commit;

--решение на уровне sql:
-- в одной транзакции просто заблокировать все сразу.

--exercise 5.2.1
begin;
	insert into player(player_id, player_name, player_points) values (7, 'Ghost', 70);
	savepoint save_point;
	update player 
	set player_points = player_points - 2
	where player_id = 7;
	rollback to savepoint save_point;
commit;

select * from player

--exercise 5.2.3  --рекурсия
select * from player

drop function if exists func();

create function func() returns trigger as $$
	begin
		update player set player_points = player_points + 2 where player_id = 7; --снова срабатывает триггер
		return new;
	end;
$$
	language plpgsql; 

drop trigger if exists trigger1 on player;

create trigger trigger1 
	before update 
	on player 
	for each row
execute procedure func();

update player set player_points = player_points + 2 where player_id = 7; --срабатывает триггер

select * from player

--5.2.2 -- бескончный цикл

drop table if exists player_save 

create table player_save(
player_id serial primary key,
player_name varchar(20),
player_points int);

insert into player_save select * from player

drop function if exists func();

create function func() returns trigger as $$
	begin
		update player_save set player_points = player_points + 2 where player_id = 7; --снова срабатывает триггер
		return new;
	end;
$$
	language plpgsql; 

drop trigger if exists trigger1 on player;

create trigger trigger1 
	before update 
	on player 
	for each row
execute procedure func();

create function func1() returns trigger as $$
	begin
		update player set player_points = player_points + 2 where player_id = 7; --снова срабатывает триггер
		return new;
	end;
$$
	language plpgsql;
	
drop trigger if exists trigger1 on player;

create trigger trigger2 
	before update 
	on player_save  
	for each row
execute procedure func1();

update player set player_points = player_points + 2 where player_id = 7;

-- скрипт вызывает trigger1 
--trigger1 вызывает trigger2
--trigger2 вызывает trigger1


--exercise 5.3
drop table if exists sales; 

create table sales(
id serial primary key,
item_name varchar(20),
sale_date date);

insert into sales(item_name, sale_date)
values 
	('iPhone6', '2022-01-01'),
	('MacAir', '2022-02-03'),
	('iPhone8', '2022-02-28'),
	('RedMi 6', '2022-04-12'),
	('MacPro', '2022-03-07'),
	('Macmini', '2022-04-25'),
	('Xiaomi', '2021-12-29')


drop function if exists find_on_date(start_date date, end_date date);

create or replace function find_on_date (start_date date, end_date date)
returns setof date
as $$
declare
	res_date date;
begin
	return query select sale_date --добавляем в результирующее множество
		from sales 
		where sale_date >= start_date and sale_date <= end_date;	
	if not found then 
	raise exception 'No sales on this date';
	end if;
	
	return;
end;
$$ language plpgsql;

select find_on_date('2022-01-01', '2022-12-31');

select find_on_date('2020-01-01', '2020-12-31'); --ошибка


--exercise 5.4
