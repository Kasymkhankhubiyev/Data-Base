create table project (
id bigserial not null primary key,
name varchar(30) not null,
description varchar(100),
start_date date not null,
finish_date date
);

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

create table users(
id bigserial not null primary key,
name varchar(30) not null,
login varchar(30) unique check(login != ''),
email varchar(30) not null, --unique check((email != '') and (email = '%@%')),
department varchar(30) check(department in ('Производство', 'Бухгалтерия', 'Администрация', 'Поддержка пользователей'))
);

insert into users(name, login, email, department)
values ('Сидорова Мария', 'm.sidorova', 'm.sidorova@mail.com', 'Поддержка пользователей')

--exercise 1-3
--вывести всю информацию о задачах(несколько способов)
select * from task;

select id, project_id, title, priority, description, status, evaluation, task_cost, date_start, date_finish creator_id, project_id  from task;

--вывести все пары сотрудник-отдел, в котором он работает
select name, department from users;

--вывести все login, email всех пользователей
select login, email from users;

--вывести все задачи, у которых приоритет больше 50
select title, priority from task
where priority > 50

--вывести всех пользователей, на которых имеются назначенные задачи
select name, department, title
from 
	task inner join users 
	on task.producer_id = users.id

--вывести все идентификаторы пользователей из таблицы задачи без повторений
select users.id
from users inner join task on (users.id = task.creator_id or users.id = task.producer_id)
group by users.id
order by users.id

--вывести все задачи, которые заведены не Петровым и при этом назначены на Иванова, Сидорова и Беркут
select title from task
where producer_id in (4, 5, 8) and not creator_id = 2


--exercise 1-4
--Вывести все задачи, созданные Касаткиным 1, 2, 3 января 2016 г.
select task.title, task.date_start, users.name
from task inner join users on task.creator_id = users.id
where task.creator_id = 1 and task.date_start between '2016-01-01' and '2016-01-03'
order by task.date_start

--exercise 1-5
select task.title, users.name as Исполнитель
from task inner join users on task.producer_id = users.id 
where task.producer_id = 2 and task.creator_id in
	(select users.id from users where department in ('Администрация', 'Бухгалтерия', 'Производство'))
	
--exercise 1-6
--как с помощью NULL можно обыграть... Если поле ябазательное - ставим NOT NULL, если допускается пустое значние - не ставим ограничений.
--1)
insert into task(project_id, title, priority, description, status, evaluation, task_cost, date_start, date_finish, creator_id, producer_id )
values
	(4,'Автопилот', 57, 'Computer Vision','Выполняется', 300000.00, '780', '2021-02-12', null, 1, null),
	(6, 'Веб-сайт', 70, 'Отладка', 'Новое', 573.00, '270', '2022-07-07',null, 5, null),
	(3, 'Финансовый отчет', 51, null, 'Новое', 321.50, '40', '2022-01-02', '2022-03-02', 5, null)
	
--2)
select title from task
where producer_id is null

--3)
update task
set producer_id = 2
where title in ('Автопилот', 'Веб-сайт', 'Финансовый отчет');

select title from task where producer_id = 2

--exercise 1-7
create table task2 as select * from task;
select * from task;
select * from task2;

--exercise 1-8
select name, login from users
where name not like '_%а _%а' and login like 'p%r%'

insert into users(name, login, email, department)
values 
	('Ефремов Петр', 'p.efremov', 'p.efremov@mail.com', 'Производство'),
	('Румянцев Павел', 'p.rumianzev', 'p.rumianzev@mail.com', 'Производство'),
	('Ларская Полина', 'p.larskaya', 'p.larskaya@mail.com', 'Бухгалтерия')
