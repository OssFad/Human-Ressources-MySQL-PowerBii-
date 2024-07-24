select* from hr;
		   #change column name:
alter table hr
change column ï»¿id empid varchar(40) null;
           #show coulumn type
describe hr ;
SET SQL_SAFE_UPDATES = 0;

            #Change birthdate values to date
update hr 
set birthdate= case
when birthdate like "%/%" then date_format(STR_TO_DATE(birthdate,"%m/%d/%Y"),"%Y-%m-%d")
when birthdate like "%-%" then date_format(STR_TO_DATE(birthdate,"%m-%d-%Y"),"%Y-%m-%d")
else NULL
end;

				# change data type of birthdate column 
alter table hr
modify column birthdate date;	
#################
describe hr ;					
			    #convert hire_date to date format
SET SQL_SAFE_UPDATES = 0;
################
UPDATE hr
SET hire_date = CASE
  WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
  WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%y'), '%Y-%m-%d')
  ELSE NULL
END;
select * from hr;
						
alter table hr
modify column hire_date date;
################
describe hr;

 
						#convert termdate to date
UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

                            # add new column 'age':
alter table hr
add column age int;

select* from hr;

SET SQL_SAFE_UPDATES = 0;

update hr 
set age = timestampdiff(year,birthdate,curdate());

                        # Maximum and Minimum age: 
select min(age),max(age)
from hr;

					   # Numbers of rows with age less than 18
select count(*)
from hr 
where age<18;

                      #Check termdate column:
SELECT COUNT(*)
FROM hr
WHERE termdate > CURDATE();

SET sql_mode = 'ALLOW_INVALID_DATES';
select count(*) from hr
where termdate = '0000-00-00';

                            ## QUESTIONS:
	select* from hr ;	
    
  # 1-What is the gender breakdown of employees in the company?
set sql_mode='allow_invalid_dates';
select gender,count(*) as count from hr
where age >= 18 and termdate ='0000-00-00'
group by gender;

 # 2- What is the race/ethnicity breakdown of employees in the company?
 select race, count(*) as count from hr
 where age >= 18 and termdate = '0000-00-00'
 group by race
 order by count desc;
 
  # 3-  What is the age distribution of employees in the company?
select case 
when age between 18 and 30 then '20-30'
when age between 31 and 40 then '31-40'
when age between 41 and 50 then '41-50'
when age between 51 and 60 then '51-60'
else '+65'
end as age_group ,gender,
count(*) as count from hr 
where age >=18 and termdate ='0000-00-00'
group by age_group, gender
order by age_group,gender;

 # 4- How many employees work at headquarters versus remote locations? #
select* from hr;

 select distinct location from hr;
 
 select location, gender, count(*)as count, sum(count(*)) over (partition by location) as total_gender_by_location, 
 count(*)/sum(count(*)) over (partition by location) as average_gender_by_location 
 from hr
 where age >= 18 and termdate='0000-00-00'
 group by location,gender 
 order by location,average_gender_by_location desc;
 
 # 5- What is the average length of employment for employees who have been terminated?
 
 SET sql_mode = 'ALLOW_INVALID_DATES';
 
 select  round(avg(datediff(termdate,hire_date))/365,0) as average_lenght_of_employment
 from hr
 where age >=18 and termdate <> '0000-00-00' and termdate<= curdate();
 
  # 6- How does the gender distribution vary across departments?
  
 select department,gender,count(*) as count
 from hr
 where age >=18 and termdate='0000-00-00'
 group by department,gender
 order by department,count(*)desc;
 
  # 7- What is the distribution of job titles across the company?
select * from hr;
select jobtitle, count(*) as count 
from hr
where age >=18 and termdate = '0000-00-00'
group by jobtitle
order by count desc;

   # 8- Which department has the highest turnover rate?
   
#"Turnover rate" typically refers to the rate at which employees leave a company or department and need to be replaced. 
#It can be calculated as the number of employees who leave over a given time period divided by the average number of employees in 
#the company or department over that same time period. 

select department,count(*) as count,
sum(case when termdate <= curdate() and termdate <> '0000-00-00' then 1 else 0 end ) as terminated_count,
sum(case when termdate ='0000-00-00' then 1 else 0 end) as active_count,
(sum(case when termdate<= curdate() and termdate <> '0000-00-00' then 1 else 0 end)/count(*)) as termination_rate
from hr
where age>=18 and  termdate <= curdate()
group by department
order by termination_rate desc;

# 9-What is the distribution of employees across locations by state?

select location_state,count(*) as count
from hr
where age>=18 and termdate ='0000-00-00'
group by location_state
order by count desc;

 # 10- How has the company's employee count changed over time based on hire and term dates?
 
 select  
 year,hires,
 terminations,
 (hires-terminations ) as net_change,
 round(((hires-terminations)/ hires*100)) as net_change_percent
 from(
 select  year(hire_date) as year,
 count(*) as hires,
sum(case when termdate<>'0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminations
from hr 
where age >=18 and termdate <= curdate() 
group by year(hire_date)
      )subquery
order by year;

 # 11- How long do employees work in each department before they leave or are made to leave?
 
select * from hr;
select department, 
round(avg(datediff(curdate(),termdate) /365),0) as avg_tenure
from hr
where age >=18 and termdate<>'0000-00-00' and termdate<= curdate() 
group by department
order by avg_tenure;


