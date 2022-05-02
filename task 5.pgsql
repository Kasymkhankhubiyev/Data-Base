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
drop table if exists links, files cascade


create table links(
link_id serial not null primary key,
path_name varchar(100));

create table files(
file_id serial not null primary key,
file_name varchar(30),
file_size int,
create_date date,
record_date date,
modification_date date,
path_id int,
foreign key(path_id) references links (link_id) on delete cascade on update cascade);

insert into links(path_name)
values 
	('./C/users/home/.'),
	('./C/users/system/app/.')
	
insert into files(file_name, file_size, create_date, record_date, modification_date, path_id)
values
	('file1', 12, '2022-01-02', '2022-01-02', '2022-03-12', 1),
	('file2', 203, '2022-02-15', '2022-02-20', '2022-05-01', 2),
	('file3', 156, '2021-09-27', '2021-12-10', null, 2)
	
select * from links;
select * from files;


--add file function
create or replace function add_new_file(fn varchar(100), fpid int, fsize int, fcd date)
returns integer as $$ 
begin 
	if fn is null or fpid is null then return 1; end if;    --
	insert into files(file_name, file_size, create_date, record_date, modification_date, path_id)
	values (fn, fsize, fcd, now()::date, now()::date, fpid);
	return 0;
end;
$$ language plpgsql;

select add_new_file('file4', 1, 45, '2019-10-17');
select add_new_file('file5', null, 45, '2019-10-17');
select * from files;


--delete file function
create or replace function delete_file(fn varchar(100))
returns integer as $$
begin 
	if fn not in (select file_name from files) then return 1; end if;
	delete from files where file_name = fn;
	return 0;
end;
$$ language plpgsql 

select delete_file('my_file');
select delete_file('file4');
select * from files;

--change name function
create or replace function name_update(fn_old varchar(100), fn_new varchar(100))
returns integer as $$ 
begin 
	if fn_old not in (select file_name from files) then return 1; end if;
	update files 
	set file_name = fn_new, modification_date = now()::date
	where file_name = fn_old;
	return 0;
end
$$ language plpgsql 

select * from files;
select name_update('file1', 'my_file');
select name_update('filee', 'file1');
select * from files;


--copy file function 
--1
create or replace function copy_file(fn varchar(100))
returns integer as $$
declare 
fsize int;
fpid int;
begin 
	if fn not in (select file_name from files) and fn is not null then return 1; end if;
	select file_size from files into fsize where file_name = fn;
	select path_id from files into fpid where file_name = fn;
	insert into files(file_name, file_size, create_date, record_date, modification_date, path_id)
	values (concat(fn, '_copy'), fsize, now()::date, now()::date, now()::date, fpid);	
	return 0;
end;
$$ language plpgsql;

select copy_file('file2');

select * from files

--2
create or replace function copy_file_to(fn varchar(100), new_pid int)
returns integer as $$
declare 
fsize int;
fpid int;
begin 
	if fn not in (select file_name from files) or new_pid not in (select link_id from links) then return 1; end if;
	if fn is null or new_pid is null then return 1; end if;
	select file_size from files into fsize where file_name = fn;
	insert into files(file_name, file_size, create_date, record_date, modification_date, path_id)
	values (concat(fn, '_copy'), fsize, now()::date, now()::date, now()::date, new_pid);	
	return 0;
end;
$$ language plpgsql;

select copy_file_to('file2', null);

select copy_file_to('file2', 3);
select copy_file_to('file3', 2)

select * from files	



--move function 
create or replace function move_file(fn varchar(100), new_pid int)
returns integer as $$
declare 
old_pid int;
begin 
	if fn not in (select file_name from files) or fn is null then return 1; end if;
	if new_pid not in (select link_id from links) or new_pid is null then return 2; end if;
	update files set path_id = new_pid where file_name = fn;
	return 0;
end;
$$ language plpgsql ;

select move_file('file3_copy', 1)

select * from files

--file search with mask
create or replace function mask_search(trace varchar(100), depth int)
returns table(file_name varchar(50), file_size int, create_date date, path_id int) as $$
declare
str varchar(30);
counter int;
res varchar(30);
begin 
	counter := 0;
	str := '';
	while counter < depth loop
	str = str || '%/';
	counter:= counter + 1;
	res = '%' || trace|| '%';
	end loop;
	return query select files.file_name, files.file_size, files.create_date, files.path_id from files 
	where files.path_id in (select link_id from links where path_name similar to str);
	if not found then 
	raise exception 'No file found';
	end if;
end;
$$ language plpgsql 


select mask_search('./C/users/home/.', 10)
