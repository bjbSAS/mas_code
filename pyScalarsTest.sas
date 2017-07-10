%macro chkrc;
	if rc then put rc=;
%mend;

%macro addln(line);
	rc=py.appendSrcLine(&line);
	%chkrc;
%mend;

/* Input data for the test.*/
data tstinput;
	a=8;
	b=4;
	output;
	a=10;
	b=2;
	output;
run;

proc ds2 ;
	ds2_options sas;
	ds2_options trace;
	package testpkg /overwrite=yes;
	dcl package pymas py();
	dcl package logger logr('App.tk.MAS');
	dcl varchar(67108864) character set utf8 pycode;
	dcl int rc revision;
	method testpkg(varchar(256) modulename, varchar(256) pyfuncname);
		%addln('# The first Python function:') %addln('def domath1(a, b):') 
			%addln(' "Output: c, d"') %addln(' c = a * b') %addln(' d = a / b') 
			%addln(' return c, d') %addln('') %addln('# Here is the second function:') 
			%addln('def domath2(a, b):') %addln(' "Output: c, d"') 
			%addln(' c,d = domath1( a, b )') 
			if rc then
				logr.log('E', 'py.appendSrcLine() failed.');
		rc=py.appendSrcLine(' return c, d');
		pycode=py.getSource();
		revision=py.publish(pycode, modulename);

		if revision lt 1 then
			logr.log('E', 'py.publish() failed.');
		rc=py.useMethod(pyfuncname);

		if rc then
			logr.log('E', 'py.useMethod() failed.');
	end;
	method usefunc(varchar(256) pyfuncname);
		rc=py.useMethod(pyfuncname);

		if rc then
			logr.log('E', 'py.useMethod() failed.');
	end;
	method exec(double a, double b, in_out int rc, in_out double c, in_out double 
			d);
		rc=py.setDouble('a', a);

		if rc then
			return;
		rc=py.setDouble('b', b);

		if rc then
			return;
		rc=py.execute();

		if rc then
			return;
		c=py.getDouble('c');
		d=py.getDouble('d');
	end;
	endpackage;
	data _null_;
		dcl package logger logr('App.tk.MAS');
		dcl package testpkg t('my Py Module Ctxt name', 'domath1');
		dcl int rc;
		dcl double a b c d;
		method run();
			a=b=c=d=0.0;
			set tstinput;
			t.exec(a, b, rc, c, d);
			logr.log('I', '##### Results: a=$s b=$s c=$s d=$s', a, b, c, d);
		end;
		method term();
			t.usefunc('domath2');
			a=6;
			b=3;
			t.exec(a, b, rc, c, d);
			logr.log('I', '##### Results: a=$s b=$s c=$s d=$s', a, b, c, d);
		end;
	enddata;
	run;
quit;