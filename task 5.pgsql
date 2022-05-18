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
	insert into player(player_id, player_name, player_points) values (11, 'Ghost', 70);
	savepoint save_point;
	update player 
	set player_points = player_points - 2
	where player_id = 7;
	rollback to savepoint save_point;
commit;

select * from player;

--exercise 5.2.3  --рекурсия 
drop table if exists web_game;

create table web_game(
id serial not null primary key,
parrent_id int,
spot_name varchar(22)
);

insert into web_game(parrent_id, spot_name)
values
	(null, 'Central'), -- 1
	(1, 'Europe Server'), -- 2
	(1, 'Central Asia Server'), -- 3
	(1,'USA Server'), -- 4
	(2, 'Russia Server'), -- 5
	(2, 'Germany Server'), -- 6
	(2, 'England Server'), -- 7
	(5, 'Moscow'), -- 8
	(5, 'Kazan'), -- 9
	(5, 'Novosibirsk'), -- 10
	(8, 'Emperior'), -- 11
	(10, 'Black Force'), -- 12
	(10, 'Little Pony'), -- 13
	(12, 'BigKing'), -- 14
	(12, 'Lord7'), -- 15
	(12, 'Ckraken'); -- 16

select * from web_game; 

drop function if exists func7();

create or replace function func7(spot_id int, spar_id int) returns table(sp_id int, sp_name varchar) as $$
declare 
p_id int;
par_id int;
begin
	p_id:= spot_id ;
	par_id:= spar_id;
	if par_id is not null then
	return query (select * from 
							(
								(select id, spot_name from web_game where id = p_id) 
								union 
								select * from func7(par_id, (select parrent_id from web_game where id = par_id))
							)fee 
						order by id desc);
	else 
	return query (select id, spot_name from web_game where id = p_id);
	end if;
end;
$$ language plpgsql; 

select * from func7(14, 12); --срабатывает функция

select * from web_game;


with recursive rec_function as (
	select id, parrent_id, spot_name 
	from web_game
	where parrent_id = 2
	union
	select web_game.id, web_game.parrent_id , web_game.spot_name 
	from web_game
		join rec_function
			on web_game.parrent_id = rec_function.id
)


create or replace function recursive (s_id int, s_par int)
returns table (counter int, sname varchar)
language plpgsql
as $$
begin
    return query select id, spot_name from web_game where id = s_id;
    if s_par is null then 
        return query select * from recursive( select id, parrent_id from web_game where id = s_par);
    end if;
end $$;

select *  from recursive (1, 1);

select * from player

--5.2.2 -- бескончный цикл -- нужно функцию сделать!! рекурсивный запрос

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
	('iPad7', '2022-01-01'),
	('iPhone6', '2022-01-01'),
	('iPhone6', '2022-01-01'),
	('iPhone6', '2022-01-01'),
	('Xiaomi', '2021-12-29'),
	('Xiaomi', '2021-12-29'),
	('Xiaomi', '2021-12-29'),
	('iPhone6', '2022-01-01'),
	('iPhone6', '2022-01-01'),
	('iPhone6', '2022-01-01'),
	('MacAir', '2022-02-03'),
	('MacAir', '2022-02-03'),
	('iPhone8', '2022-02-28'),
	('MacAir', '2022-02-03'),
	('MacAir', '2022-02-03'),
	('MacAir', '2022-02-03'),
	('RedMi 6', '2022-04-12'),
	('MacPro', '2022-03-07'),
	('MacPro', '2022-03-07'),
	('MacPro', '2022-03-07'),
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
	return query select distinct sale_date --добавляем в результирующее множество
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
create or replace function mask_search(mask varchar(30), folder_id int, depth int)
returns table(file_name varchar(50), file_size int, create_date date, path_id int) as $$
declare
str varchar(30);
counter int;
res varchar(30);
begin 
	str := concat('%',mask,'%');
	if folder_id != depth then
	return query select files.file_name, files.file_size, files.create_date, files.path_id from files 
	where files.file_name like str;  --широкий поиск
	else 
	return query select files.file_name, files.file_size, files.create_date, files.path_id from files
	where files.path_id = folder_id and files.file_name like str; --локальный поиск
	end if;-- files.path_id in (select link_id from links where path_name like str);
	if not found then 
	raise exception 'No file found';
	end if;
end;
$$ language plpgsql 

select * from files;

select add_new_file('abc', 1, 45, '2019-10-17');

select mask_search('abc', 1, 2);

select mask_search('file', 1, 1);

--exercise 5.5

select * from users

drop table if exists task;

create table task(
id bigserial not null primary key,
project_id bigint not null,
title varchar(30) not null,
priority bigint not null,
description varchar(100),
status varchar(30) check(status in ('Новое','Переоткрыта','Выполняется','Закрыта')),
evaluation decimal(8,2) not null,
task_cost interval hour not null,
date_start date not null,
date_finish date,
creator_id bigint not null,
producer_id bigint,
foreign key (creator_id) references users (id) on delete cascade,
foreign key (project_id) references project (id) on delete cascade,
foreign key (producer_id) references users (id) on delete set null
)

insert into task(project_id, title, priority, description, status, evaluation, task_cost, date_start, date_finish, creator_id, producer_id )
values 
	(3,'Newage rocket', 10, 'To dominate in Universe we ...', 'Выполняется', 1000.00,  '70','2016-01-02', null, 1, 7),
	(6, 'Experience', 7, 'Have fun with Airbnb.', 'Новое', 570.00, '30','2022-01-01', null,  3, null),
	(2, 'Salary', 2, 'Reestimate employees salaries', 'Переоткрыта', 321.50, '40','2022-02-12', null,  3, 2),
	(5,'Открытое окно', 57, null, 'Переоткрыта', 37000.00, '140','2016-01-03', '2017-03-02' , 1, 6),
	(4, 'Чат-бот', 70, 'Нужен для улучшения взаимодействия клиента с приложением', 'Выполняется', 57000.00, '240','2021-11-21', null,  3, 5),
	(3, 'Кабель', 51, 'На чиле', 'Закрыта', 321.50, '40', '2016-01-01', '2016-03-01', 1, 7),
	(2,'C1', 57, null, 'Новое', 300.00, '140', '2022-02-12', null, 2, 7),
	(4, 'Кряк', 70, 'Хайп', 'Выполняется', 57.00, '240', '2021-07-07', '2023-06-27', 3, 5),
	(3, 'Чат-бот тесты', 51, 'Тестировка', 'Новое', 321.50, '40', '2022-01-02', '2022-03-02', 5, 8),
	(4, 'Бух.учет', 70, null, 'Закрыта', 57.00, '240', '2021-07-07', '2021-07-27', 4, 2),
	(3, 'Налоговая Декларация', 51, 'Экспорт товара', 'Новое', 321.50, '40', '2022-02-02', '2022-03-02', 6, 2)
	
select * from task

select * from project

create table history(
id serial not null primary key,
task_id int,
task_in_status varchar(20),
modification_date date,
project_id bigint not null,
title varchar(30) not null,
priority bigint not null,
description varchar(100),
status varchar(30) check(status in ('Новое','Переоткрыта','Выполняется','Закрыта')),
evaluation decimal(8,2) not null,
task_cost interval hour not null,
date_start date not null,
date_finish date,
creator_id bigint not null,
producer_id bigint,
foreign key (creator_id) references users (id) on delete cascade,
foreign key (project_id) references project (id) on delete cascade,
foreign key (producer_id) references users (id) on delete set null
)


---сохраниение при изменении или добавлении
create or replace function save_changes() returns trigger as $$
declare --надо вытащить все значения из task
tid int;
help_str varchar;
prid int;
ttitle varchar(30);
tpriority int;
tdesc varchar(30);
tstat varchar(30);
teval decimal(8,2);
tcost interval hour;
tsd date;
tdf date;
tcid int;
tpid int;
begin 
	select task.id from task into tid where task.id = old.id;
	select task.project_id from task into prid where task.id = old.id;
	select task.title from task into ttitle where task.id = old.id;
	select task.priority from task into tpriority where task.id = old.id;
	select task.description from task into tdesc where task.id = old.id;
	select task.status from task into tstat where task.id = old.id;
	select task.evaluation from task into teval where task.id = old.id;
	select task.task_cost from task into tcost where task.id = old.id;
	select task.date_start from task into tsd where task.id = old.id;
	select task.date_finish from task into tdf where task.id = old.id;
	select task.creator_id from task into tcid where task.id = old.id;
	select task.producer_id from task into tpid where task.id = old.id;
	insert into history(task_id, task_in_status, modification_date, project_id, title, priority, description, status, evaluation, task_cost, date_start, date_finish, creator_id, producer_id)
	values (tid, 'Сохранено', now()::date, prid, ttitle, tpriority, tdesc, tstat, teval, tcost, tsd, tdf, tcid, tpid);
	return new;
end;
$$ language plpgsql 


drop trigger if exists trigger_save on task;

create trigger trigger_save
	before insert or update
	on task 
	for each row
execute procedure save_changes();

update task set priority = priority + 2 where id = 7; --срабатывает триггер

select * from task where id = 7;

select * from history 

--удаление задачи и сохранение в историю
create or replace function delete_and_save() returns trigger as $$
declare --надо вытащить все значения из task
tid int;
help_str varchar;
prid int;
ttitle varchar(30);
tpriority int;
tdesc varchar(30);
tstat varchar(30);
teval decimal(8,2);
tcost interval hour;
tsd date;
tdf date;
tcid int;
tpid int;
begin 
	select task.id from task into tid where task.id = old.id;
	select task.project_id from task into prid where task.id = old.id;
	select task.title from task into ttitle where task.id = old.id;
	select task.priority from task into tpriority where task.id = old.id;
	select task.description from task into tdesc where task.id = old.id;
	select task.status from task into tstat where task.id = old.id;
	select task.evaluation from task into teval where task.id = old.id;
	select task.task_cost from task into tcost where task.id = old.id;
	select task.date_start from task into tsd where task.id = old.id;
	select task.date_finish from task into tdf where task.id = old.id;
	select task.creator_id from task into tcid where task.id = old.id;
	select task.producer_id from task into tpid where task.id = old.id;
	--delete from task where id = old.id;
	insert into history(task_id, task_in_status, modification_date, project_id, title, priority, description, status, evaluation, task_cost, date_start, date_finish, creator_id, producer_id)
	values (tid, 'Удалено', now()::date, prid, ttitle, tpriority, tdesc, tstat, teval, tcost, tsd, tdf, tcid, tpid);
	return new;
end;
$$ language plpgsql 


drop trigger if exists trigger_delete on task;

create trigger trigger_delete
	before delete
	on task 
	for each row
execute procedure delete_and_save();

delete from task where id = 2; --срабатывает триггер

select * from task where id = 2;

select * from history 

--просмотр удаленных задач

create or replace function deleted_tasks_list()
returns table(task_id int, task_in_status varchar(20), modification_date date) as $$
begin 
	return query select history.task_id, history.task_in_status, history.modification_date from history
	where history.task_in_status = 'Удалено';
	if not found then 
	raise exception 'No file found';
	end if;
end;
$$ language plpgsql 

select deleted_tasks_list()

--восстановление удаленной задачи
create or replace function back_to_life() returns trigger as $$
begin 
	return query select history.task_id, history.task_in_status, history.modification_date from history
	where history.task_in_status = 'Удалено';
	if not found then 
	raise exception 'No file found';
	end if;
end;
$$ language plpgsql

select back_to_life()
