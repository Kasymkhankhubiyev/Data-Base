--task2

--exercise 2.1

select name, round(avg(task.priority)) as Средний_Приоритет
from users inner join task on users.id = task.producer_id 
group by name
order by Средний_Приоритет desc 
limit 3

--exercise 2.2
select concat_ws('-',  count(project_id), extract (month from date_start), creator_id)
from task
where date_start between '2015-01-01' and '2015-12-31'
group by creator_id, date_start

select count(project_id), extract (month from date_start), creator_id
from task
where date_start between '2015-01-01' and '2015-12-31'
group by creator_id, date_start

insert into task(project_id, title, priority, description, status, evaluation, task_cost, date_start, date_finish, creator_id, producer_id )
values
	(2,'Music_hub', 100, 'Cats','Выполняется', 300000.00, '10190', '2015-02-12', null, 1, null),
	(5, 'Bliz game', 75, 'Cocacola', 'Новое', 573.00, '27000', '2015-07-07',null, 5, null),
	(3, 'GreenGo', 61, null, 'Новое', 321.50, '42323', '2015-01-02', '2022-03-02', 5, null)

--exercise 2.3 -- как разница времени и затрат
	--select id, ((затраты - стоимость) + abs(затраты - стоимость))/2 as "+", ((затраты - стоимость) - abs(затраты - стоимость))/2 as "-"
	--from task
	--group by id
	
	
	select producer_id as id_executor, 
	sum(case  
 		when date_finish is not null 
 			then ((to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int) +
 				abs(to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int))/2
 		else ((to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int) +
 			abs(to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int))
 		end) as "+",
 	sum(case  
 		when date_finish is not null 
 			then ((to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int) -
 				abs(to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int))/2
 		else ((to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int) -
 			abs(to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int))
 		end) as "-"
	from task
	where producer_id is not null
	group by producer_id 
	
	
	select users.name, "+", "-"   
    from 
	users
	inner join (select users.name  as Исполнитель, 
			sum(case  
 				when date_finish is not null 
 					then ((to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int) +
 						abs(to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int))/2
 				else ((to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int) +
 					abs(to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int))
 				end) as "+" --все в срок
			from 
			task 
			inner join users on producer_id = users.id 
		group by Исполнитель, producer_id)positive
	on users.name = positive."Исполнитель"
	inner join
	(select users.name  as Исполнитель, 
				sum(case  
 					when date_finish is not null 
 						then ((to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int) -
 							abs(to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int))/2
 					else ((to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int) -
 						abs(to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int))
 					end) as "-" --все не в срок
				from 
				task 
				inner join users on producer_id = users.id 
				group by users.name)negative
	on users.name = negative."Исполнитель"
group by users.name, "+", "-"
	
--exercise 2.4
	select users.login as Постановщик, foo.login as Исполнитель 
	from task 
	inner join users on task.creator_id = users.id 
	inner join 
		(select creator_id, login
		from 
			task 
			inner join users on task.producer_id = users.id
			where producer_id is not null
			group by creator_id, producer_id, login)foo
	on task.creator_id = foo.creator_id 
	group by Постановщик, Исполнитель
	having concat(users.login, foo.login) not in (select concat(foo.login, users.login)
							from task
							inner join users on task.creator_id = users.id
							inner join
								(select creator_id, login
								from 
								task 
								inner join users on task.producer_id = users.id
								where producer_id is not null
								group by creator_id, producer_id, login)foo
								on task.creator_id = foo.creator_id)	
	order by Постановщик
	
	
	
--exercise 2.5	
	
	select login, char_length(login) as Кол_букв
	from users
	where char_length(login) in (select max(char_length(login)) from users)
	
	
--exercise 2.6  --
	
	create table book(
	id bigserial not null primary key,
	author varchar(30) not null,
	name char(30) not null
	)
	
	insert into book(author, name)
	values
		('Привет', 'Привет')
	
	-- (Latin)латинские буквы однобайтовые, кирилица - двухбайтовая
	delete from book
		
	select * from book
	
	select author, octet_length(author) as Кол_varchar, name, octet_length(name) as Кол_char
	from book
		
	--exercise 2.7
	
	select users."name", max_priority  --это для постановщиков
	from users inner join (
		select creator_id, max(priority) as max_priority
		from task group by creator_id)foo
	on users.id = foo.creator_id
	
	select users.name, max_priority --это для исполнителей
	from users inner join (
		select producer_id, max(priority) as max_priority 
		from task 
		group by producer_id 
		having not producer_id is null)foo 
	on users.id = foo.producer_id 
	
	
--exercise 2.8
	
select producer_id, sum(evaluation)
from task
where evaluation >= (select sum(evaluation)/count(project_id) from task)
group by producer_id 
having producer_id is not null


--exercise 2.9

select * from task

--пушка
select users.name, "+", "-"   
from 
	users
	left join (select users.name  as Исполнитель, count(project_id) as "+" --все в срок
		from 
			task 
			left join users on producer_id = users.id 
		where to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int > 0 or date_finish is null
		group by Исполнитель, producer_id
		having producer_id is not null)positive
	on users.name = positive."Исполнитель"
	left join
	(select users.name  as Исполнитель, count(project_id) as "-" --все в срок
	from 
		task 
		inner join users on producer_id = users.id 
	where to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int < 0 --просрочил, но выполнил
		or to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int < 0  -- просрочил, но все еще не выполнил
	group by users.name)negative
	on users.name = negative."Исполнитель"
group by users.name, "+", "-"
having "+" is not null or "-" is not null

--первый view 2.9.1
create view statistics1 as
select users.name, "+", "-", "Открыто", "Закрыто", "Выполняется", "Суммарная переработка", "Суммарная недоработка", "Суммарное время",
"Cуммарное кол-во проектов", "Суммарное кол-во заказчиков", "Средний приоритет по задачам"   
from 
	users
	join (select users.name  as Исполнитель, count(title) as "-" --все не в срок
				from 
					task 
					inner join users on producer_id = users.id 
				where to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int < 0 --просрочил, но выполнил
				or to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int < 0  -- просрочил, но все еще не выполнил
				group by users.name)negative
	on users.name = negative."Исполнитель"
	left join (select users.name  as Исполнитель, count(title) as "+" --все в срок
				from 
					task 
					left join users on producer_id = users.id 
				where to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int > 0 or date_finish is null
				group by Исполнитель, producer_id
				having producer_id is not null)positive	
	on users.name = positive."Исполнитель"
	left join (select users.name as names, count(title) as "Открыто" 
		from task
			inner join users on producer_id = users.id 
		group by users.name)oppen
	on users.name = oppen.names 
	left join (select users.name as names, count(title) as "Закрыто" 
		from task
			inner join users on producer_id = users.id 
		where status = 'Закрыта'
		group by users.name)closee
	on users.name = closee.names 
	left join (select users.name as names, count(title) as "Выполняется" 
		from task
			inner join users on producer_id = users.id 
		where status = 'Выполняется'
		group by users.name)process
	on users.name = process.names
	inner join (select users.name  as Исполнитель, 
				sum(case  
 						when date_finish is not null 
 							then ((to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int) +
 								abs(to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int))/2
 						else ((to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int) +
 							abs(to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int))
 					end) as "Суммарная переработка" --все в срок
		from 
			task 
			inner join users on producer_id = users.id 
		group by Исполнитель, producer_id)overdone
	on users.name = overdone."Исполнитель"
	inner join
	(select users.name  as Исполнитель, 
				sum(case  
 						when date_finish is not null 
 							then ((to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int) -
 								abs(to_char(task_cost, 'HH24')::int - (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int))/2
 						else ((to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int) -
 							abs(to_char(task_cost, 'HH24')::int - (date_part('day', now()::timestamp - date_start::timestamp)*8)::int))
 					end) as "Суммарная недоработка" --все не в срок
	from 
		task 
		inner join users on producer_id = users.id 
	group by users.name)underdone
	on users.name = underdone."Исполнитель"
	join (select producer_id, 
 				sum(case  
 						when date_finish is not null then (date_part('day', date_finish::timestamp - date_start::timestamp)*8)::int
 						else (date_part('day', now()::timestamp - date_start::timestamp)*8)::int
 					end) as "Суммарное время"
 				from task
 				where producer_id is not null
 				group by producer_id)summtime
 	on users.id =summtime.producer_id
 	join (select producer_id, count(title) as "Cуммарное кол-во проектов"
				from task
				group by producer_id)tasks
	on users.id = tasks.producer_id 
	join (select producer_id, count(distinct(project_id)) as "Суммарное кол-во заказчиков"
				from task
				where producer_id is not null 
				group by producer_id)customer
	on users.id = customer.producer_id 	
	join (select producer_id, round(avg(priority)) as "Средний приоритет по задачам"
			from task
			where producer_id is not null
			group by producer_id)priority
	on users.id = priority.producer_id
group by users.name, "+", "-", "Открыто", "Закрыто", "Выполняется", "Суммарная переработка", "Суммарная недоработка", "Суммарное время",
"Cуммарное кол-во проектов", "Суммарное кол-во заказчиков", "Средний приоритет по задачам"


select * from statistics1 

drop view statistics1 


--exercise 2.10

--1 - simple JOIN
select name, login, email, department 
from users
inner join task
on users.id = task.producer_id
group by users.id, task.id;  

--2 - вложенный подзапрос
select * 
from
	(select id, name, login, email, department from users) as fee
	join (select producer_id as id from task where producer_id is not null)foo
	on fee.id = foo.id;

--3 - соотнесенынй подзапрос
select name, login, email, department
from users as fee
where id in (select producer_id 
				from task as foo
				where fee.id = foo.producer_id);
