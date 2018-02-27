/*	SAS Solution --- NYT Assignment - Question 1 */

/****************************************************************************************************/
/*	Question 1a: Write a query to select the name of each customer and his or her latest order date */
/****************************************************************************************************/

options nonumber nodate;

data customers;
input customer_id name :$20.;
datalines;
1 COMPANY_A
2 COMPANY_B
3 COMPANY_C
;

data orders;  
input order_id quantity order_date yymmdd10. customer_id;
datalines;
1002 12 2015-01-01 2
1003 10 2015-01-02 2
1004 17 2015-01-02 2
1003 0 2015-01-03 2
1003 32 2015-01-01 1
1003 9 2015-01-03 1
1003 62 2015-01-02 3
;
run; 

/*Merge customers and orders*/
proc sort data = customers;
	by customer_id;
run;

proc sort data = orders;
	by customer_id;
run; 

data customers_orders;
	merge customers (in = a)
	      orders (in = b);
	by customer_id;
run; 

/* Calculate final order date */
proc sort data = customers_orders;
	by customer_id order_date;
run; 

data final_order_date (rename = (order_date = final_order_date) );
	set customers_orders;
	by customer_id order_date;
	if last.customer_id;
run; 

proc print data = final_order_date;
	var name final_order_date;
	format final_order_date yymmdd10.;
	title "Last order date of each customer";
run; 
title;

/************************************************************/
/* Question 1b: Calculate change in quantity between orders */
/************************************************************/
/*
Find which customers have changed their behaviour the most from one order to the next
Calculate the largest absolute change in quantity (positive or negative) between orders.
Caveats:
a) If two orders for a customer occur on the same day, consider them one order with the sum as the quantity
b) Days when a customer has not ordered anything should not be considered at all, as opposed to considering them 0 quantity
c) Ignore the theoretical increase between the time they were not a customer and their first order, as well as customers that may only have one order
*/

data change;
	set customers_orders;
	by customer_id order_date;

	/* To remove customers that have only one order */
	if first.customer_id and last.customer_id then delete;

	/* To calculate total_daily_order of each customer */
	if first.order_date then total_daily_order = 0;
	total_daily_order + quantity;
	if last.order_date;

	/* To remove rows with quantity = 0 */
	if quantity ne 0; 
run;

/* To calculate difference */
data change_final;
	set change;
	by customer_id order_date;
	lag_ = lag(quantity);
	if first.customer_id then lag_ = .;
	else diff = total_daily_order - lag_;
	if diff ne .;
run;

proc print data = change_final;
	var name order_date diff;
	format order_date yymmdd10.;
	title "Change in quantity between orders";
run; 
title;

