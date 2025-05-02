CREATE TABLE IF NOT EXISTS TEST ( 
    id int not null auto_increment primary key,
    name varchar(255) not null,
    created_at timestamp default current_timestamp
);