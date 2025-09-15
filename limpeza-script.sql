DROP TABLE IF EXISTS club_member_info;
CREATE TABLE club_member_info (
	full_name varchar(100),
	age int,
	marital_status varchar(255),
	email varchar(150),
	phone varchar(20),
	full_address varchar(150),
	job_title varchar(100),
	membership_date date,
);

COPY club_member_info (
	full_name,
	age,
	marital_status,
	email,
	phone,
	full_address,
	job_title,
	membership_date)
from '...\csv\club_member_info.csv'
delimiter ',' csv header;


--0.Alterando as colunas para compatibilidade com as células do excel
ALTER TABLE club_member_info 
ALTER COLUMN full_address TYPE VARCHAR(255);

ALTER TABLE club_member_info 
ALTER COLUMN job_title TYPE VARCHAR(100);

ALTER TABLE club_member_info 
ALTER COLUMN full_name TYPE VARCHAR(150);

--1.Criando uma coluna de ID
ALTER TABLE club_member_info
ADD COLUMN id SERIAL PRIMARY KEY;


-- 2.Tratando a coluna de nomes, removendo espaços em branco e caracteres especiais
UPDATE club_member_info
SET full_name = REGEXP_REPLACE(full_name, '^\s+|\s+$', '', 'g');

UPDATE club_member_info
SET full_name = REPLACE(full_name, '?', '')
WHERE full_name LIKE '%?%';

UPDATE club_member_info
SET full_name = INITCAP(LOWER(full_name));

--3.Tratando a coluna de endereços, removendo espaços em branco e caracteres especiais
UPDATE club_member_info
SET full_address = REGEXP_REPLACE(TRIM(full_address), '\s+', ' ', 'g');

--2.Atualizando o termo 'separated' para 'divorced', condensando os dois termos que estão redundantes na coluna
UPDATE club_member_info
SET martial_status = REPLACE(martial_status, 'separated', 'divorced')
WHERE martial_status = 'separated';

--3.Retirando os valores >100 da coluna age 
UPDATE club_member_info
SET age = NULL
WHERE age > 100;

--4.Procurando duplicatas na coluna de e-mail

SELECT 
	count(*) AS record_count 
FROM club_member_info cmi ;
Results:
/*
record_count
2010*/


SELECT *
FROM club_member_info
WHERE email IN (
    SELECT email
    FROM club_member_info
    GROUP BY email
    HAVING COUNT(*) > 1
);

/* Results:

new_record_count
2000*/


-- apagando todas as duplicatas
DELETE FROM club_member_info
WHERE id IN (
    291,
    316,
    453,
    551,
    764,
    774,
    953,
    1164,
    1225,
    1300,
    1345,
    1369,
    1480,
    1654,
    1690,
    1761,
    1896,
    1943,
    2001
);

-- 5. Removendo todas as datas antes do ano 2000
DELETE FROM club_member_info
WHERE membership_date < '2000-01-01';

--6.Ajustando a coluna de full_address e criando novas colunas de cidade e estado
ALTER TABLE club_member_info
ADD COLUMN address VARCHAR(255)
ADD COLUMN city VARCHAR(100),
ADD COLUMN state VARCHAR(50);

UPDATE club_member_info
SET 
    address = TRIM(SPLIT_PART(full_address, ',', 1)),
    city    = TRIM(SPLIT_PART(full_address, ',', 2)),
    state   = TRIM(SPLIT_PART(full_address, ',', 3));

-- Removendo a full address
ALTER TABLE club_member_info
DROP COLUMN full_address;


ALTER TABLE club_member_info
RENAME COLUMN martial_status TO marital_status;

-- 7. Convertendo todos os campos vazios para NULL
UPDATE club_member_info
SET 
    full_name      = NULLIF(TRIM(full_name), ''),
    marital_status = NULLIF(TRIM(marital_status), ''),
    email          = NULLIF(TRIM(email), ''),
    phone          = NULLIF(TRIM(phone), ''),
    address   = 	NULLIF(TRIM(address), ''),
    job_title      = NULLIF(TRIM(job_title), ''),
	city = nullif(TRIM(city), ''),
	state = nullif(TRIM(state), '');

