----------START----------

--Starting sql block(donor comes)--
DECLARE 
fname varchar2(10);
lname varchar2(10);
phone number(12);
age number;
sex varchar2(5);
house_no varchar2(10);
stt varchar2(10);
city varchar2(10);
statei varchar2(10);
blood_typei varchar2(10);
rh_factori varchar2(10);
blood_code varchar2(10);
vol number;
id number;
vid number;
too_much_blood EXCEPTION;
BEGIN
vid:=101;
id:='&Your_donor_id';
fname :='&first_name';
lname:='&last_name';
phone :='&contact';
age:='&age';
sex :='&gender';
house_no :='&house_number';
stt:='&street_name';
city :='&city';
statei :='&state';
blood_typei :='&blood_grp';
rh_factori :='&rh_factor';
vol:='&volume';
if vol>5 then
raise too_much_blood;
end if;
if id is NULL then
id:=vid+1;
vid:=vid+1;

new_reg(id,fname,lname,age,sex,house_no,stt,city,statei,blood_typei,rh_factori,phone,vol);--procedure call for new donor--
dbms_output.put_line('Your id is '||id);
dbms_output.put_line('Current status of blood in blood bank');
display_total_blood;
else
for_already_reg(id,vol);--procedure call for already registered member--
dbms_output.put_line('Current status of blood in blood bank');
display_total_blood;--procedure call for current status of blood--
end if;
dbms_output.put_line('');
EXCEPTION
when too_much_blood then
raise_application_error(-20001,'You cannot donate too much blood at once');
END;

--procedure for already registered member--
create or replace procedure for_already_reg(id in number,vol in number)
is
rowcoun number;
oldvol number;
newvol number;

BEGIN
select count(*) into rowcoun from donor where did=id;
if rowcoun=0 then
dbms_output.put_line('your donor id is not registered with us..kindly go for registration process');
raise_application_error(-20001,'User not validated');
else
dbms_output.put_line('Donor id validated');
select volume into oldvol from donor_blood where did=id;
newvol:=oldvol+vol;
update donor_blood set volume=newvol where did=id;
dbms_output.put_line('Thank you for donating blood');
end if;
end;

--procedure for new donor--
create or replace procedure new_reg(
id number,
fname varchar2,
lname varchar2,
age number,
sex varchar2,
house_no varchar2,
stt varchar2,
city varchar2,
statei varchar2,
blood_typei varchar2,
rh_factori varchar2,
phone number,
vol number
)
is
blood_code varchar2(10);
rowcount number;
oldvol number;
newvol number;
BEGIN

Select code into blood_code from blood where blood_type=blood_typei and rh_factor=rh_factori;

insert into donor values(id,fname,lname,age,sex,house_no,stt,city,statei,blood_code);

insert into D_P values(phone,id);

select count(*) into rowcount from donor_blood where did=id;
if rowcount=0 then
insert into donor_blood values(id,vol,blood_code);
else
select volume into oldvol from donor_blood where did=id;
newvol:=oldvol+vol;
update donor_blood set volume=newvol where did=id;
end if;
dbms_output.put_line('THANK YOU FOR DONATING BLOOD');
end new_reg;

--Trigger for age check of donor (age of donor should be greater than 18)--
CREATE OR REPLACE TRIGGER check_age
BEFORE INSERT ON donor 
FOR EACH ROW 

BEGIN
if :new.age<18 THEN
dbms_output.put_line('age is less than 18');
raise_application_error(-20001,'You are not eligible to donate blood');
end if;
end;

--procedure to calculate total blood for each blood group present in blood bank currently--
create or replace procedure display_total_blood
as
total number;
bcode varchar2(10);
btype varchar2(5);
rh varchar2(5);
ctotal number:=0;
cursor c1 is select sum(volume),blood_code from donor_blood group by  blood_code;
BEGIN
OPEN c1;
dbms_output.put_line('BLOOD_GRP___________VOLUME AT PRESENT');
LOOP
fetch c1 into total, bcode;

select blood_type,rh_factor into btype,rh from blood where code=bcode;
exit when c1%notfound;
dbms_output.put_line('______'||btype||rh||'_____________________'||total||'_______');
ctotal:=ctotal+total;
end loop;
close c1;
dbms_output.put_line('Total volume of blood irrespective of blood group = '||ctotal);
end;


-------------------- entry in blood_bank--------------

set verify off;
declare
name varchar2(10) := '&name';
i number(10) := &id;
name_is_must exception;
begin
if name is null
then
raise name_is_must;
end if;
insert into blood_bank values(i,name);
bbp(i);
exception
when name_is_must
then
 raise_application_error (-20005,' blood name is not null');
 end;
/*input in blood_bank
*/

------------------------- entry in bank code-------------

create or replace procedure bbp(i in number)
 as
 a blood.code%type;
 cursor cdd is select code from blood;
begin
open cdd;
loop
fetch cdd into a;
insert into b_bb values(a,i);
exit when cdd%notfound;
end loop;
end;
/* for input the value in b_bb 
*/

-----------hospital---------------
declare
name varchar2(20) := '&name';
street varchar2(40) := '&street';
city varchar2(20) := '&city';
id varchar2(20) := '&id';
a number(15) := &number1;
b number(15) := &number2;
begin
hp(name,street,city,id,a,b);
end;
/*
input in hospital
*/
create or replace procedure hp(x in varchar2,y in varchar2,z in varchar2, i in varchar2, n in number, n1 in number)
as
begin
insert into hospital values(x,y,z,i);
insert into h_p values(n,i);
insert into h_p values(n1,i);
end;
/*
procedure for hospital
*/


------------employee------------
declare
 
name varchar2(20) := '&name';
hno number(5):= &house_no ;
s number(5) := &salary ;
street varchar2(40) := '&street';
city varchar2(20) := '&city';
id varchar2(10) := '&id';
bb number(10):='&blood_bank_id';
a number(15) := &number1;
b number(15) := &number2;
e exception;
begin
if bb is null 
then
raise e;
end if;
insert into employee values(name,s,hno,street,city,bb,id);
insert into e_p values(a,id);
insert into e_p values(b,id);
exception
when e
then
dbms_output.put_line('every employee must be associated with one blood bank.');
end;
/* employee entry
*/

---------- reception----------

declare 
name varchar2(20) := '&working_days';
n varchar2(3) := '&Nightshift_with_caps_YES_or_NO';
s varchar2(10) := '&employee_id';
begin
insert into receptionist values(name,n,s);
end;
/* RECETION INPUT*/


-------RELAtion b/w donar and reception---------
declare 
name number(10) := '&donar_id';
n varchar2(10) := '&receptionin_id';
begin
insert into r_d values(name,n);
end;
/*input*/


------relation b/w hospital and bank----------
declare 
name varchar2(10) := '&hospital_id';
n number(10) := '&blood_bank_id';
begin
insert into bank_hospital values(name,n);
end;
/*input*/

------------ END--------------




