
--exercise 4

--exercise 4.1
create table authors(
	author_id serial not null primary key,
	author_name varchar(20) unique
)

create table books(
book_id serial not null primary key,
title varchar(30),
author_id int,
foreign key (author_id) references authors(author_id) 
)


insert into authors(author_name)
values
	('Пушкин'),
	('Достоевский'),
	('Булгаков'),
	('Хемингуэй'),
	('Ричард Бах'),
	('Толстой'),
	('Сафарли')
	
insert into books(title, author_id)
values 
	('Идиот', 2),
	('Братья Карамазовы', 2),
	('Мастер и Маргарита', 3),
	('Белая Гвардия', 3),
	('По ком звонит колокол', 4),
	('Прощай оружие', 4),
	('Старик и море', 4),
	('Чайка по имени Джоннатан', 5),
	('Мост через вечность', 5),
	('Семейное счастье', 6),
	('Война и мир', 6),
	('Мне тебя обещали', 7),
	('Я хочу домой', 7)
	
insert into books(title)
values ('Над пропастью во ржи')
	
select * from books
	
---1. A\B or B\A
select author_name, title 
from 
	authors full outer join books 
	on authors.author_id = books.author_id
where author_name is null or title is null

---2. FULL OUTER JOIN (A or B)\(A & B)
select author_name, title 
from 
	authors full outer join books 
	on authors.author_id = books.author_id
	
---3. A & B 
select author_name, title 
from 
	authors join books 
	on authors.author_id = books.author_id
	
---4. (A & B) or A/B
select author_name, title 
from 
	authors left join books 
	on authors.author_id = books.author_id
	
---5. A\B
select author_name, title 
from 
	authors left join books 
	on authors.author_id = books.author_id
where title is null

---6. (A & B) or B/A 
select author_name, title 
from 
	authors right join books 
	on authors.author_id = books.author_id
	
---7. B/A
select author_name, title 
from 
	authors right join books 
	on authors.author_id = books.author_id
where author_name is null

---CROSS join 
select *, max(fee.author_id)
from authors as fee, authors foo
where fee.author_name = foo.author_name
group by fee.author_id, foo.author_id 
having max(fee.author_id) = foo.author_id 

--exercise 4.2

select out.task_id, out.task_title 
from tasks as out 
where priority = (select max(priority)
					from tasks as int
					where int.author = out.author) --для каждого автора, получается, находим задачу с максимальным приоритетом
					
-->
select inr.task_id, inr.task_title 
from task as outt, task as inr --cross join
where outt.task_author = inr.task_author
group by inr.task_id, inr.task_id
having inr.priority = max(outt.priority)

drop table if exists task

create table task(
task_id serial not null primary key,
task_title varchar(20),
task_author varchar(20),
priority int)

insert into task(task_title, task_author, priority)
values
	('math1', 'John', 7),
	('math2', 'John', 8),
	('math3', 'John', 2),
	('phys1', 'Mike', 10),
	('phys2', 'Mike', 1),
	('phys3', 'Mike', 9),
	('chem1', 'Ann', 3),
	('chem2', 'Ann', 5),
	('chem3', 'Ann', 4)


--exercise 4.3

select author_name
from authors
where author_id in (select author_id from books where title like '% %')

select distinct author_name
from authors join books on authors.author_id = books.author_id 
where title like '% %'
--group by author_name 

select distinct author_name, title
from authors, books
where authors.author_id =books.author_id and title like '% %'


--exercise 4.4
drop table if exists task

create table task(
task_id serial not null primary key,
creator varchar(15),
executor varchar(15)
)

insert into task(creator, executor)
values 
	('John', 'Mike'),
	('Nike', 'Ann'),
	('Ann', 'Tom'),
	('Mike', 'John'),
	('Ann', 'Kate'),
	('Kate', 'Ann')
	
select creator, executor 
from task where creator > executor
union
select creator, executor 
from task where creator < executor 
union select creator, executor 
from task where creator=executor 

--должны иметь одинаковое кол-во столбцов и типы соответсвующих столбцов

--exercise 4.5
select p.Название, t.Название from Задачи as t, Проект as p

select p.Название, t.Название
from 
	Задачи as t
	CROSS join 
	Проект as p
