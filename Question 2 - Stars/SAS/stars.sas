options mprint nonumber nodate;

%macro stars (k= ,x1= ,y1= ,z1= ,path= );
	data stars;
		infile "&path" dlm = ',' dsd truncover firstobs = 2;
		input id hip hd hr gl $ bf $ proper :$20. ra dec dist pmra pmdec rv mag absmag spect :$100. ci x  y  z  vx vy vz rarad decrad pmrarad pmdecrad bayer $
		flam con :$100. comp comp_primary base $ lum var $ var_min var_max;
	run; 

	data small (keep = id proper x y z x0 y0 z0 dist);
		set stars ;
		retain x0 y0 z0 0;
		if _n_ = 1 then do;
			%if &x1 ne %then x0 = &x1;
			%else x0 = x;;
			%if &y1 ne %then y0 = &y1;
			%else y0 = y;;
			%if &z1 ne %then z0 = &z1;
			%else z0 = z;;
		end;
		else dist = ((x - x0)**2 + (y - y0)**2 + (z-z0)**2)** 0.5;
	run; 

	proc sort data = small;
		by dist;
	run;

	proc print data = small (obs = %eval(&k + 1));
		title "SAS Output - Co-ordinates of the &k nearest stars from the Sun";
		var id proper x y z dist;
	run;
	title;
%mend stars;

/* Instructions to run the above macro - example to get the co-ordinates of the 5 nearest stars from the Sun:
%stars (k=5 ,x1= ,y1= , z1= , path=enter_path_to_hygdata_v3.csv)
*/

%stars (k=10 ,x1= ,y1= , z1= , path=C:\Documents and Settings\Administrator\Desktop\hygdata_v3.csv)



