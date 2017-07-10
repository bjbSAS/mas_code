%macro chkrc;
            if rc then do;
                logr.log('E', 'Error: Python publishing failed.');
                return;
            end;
%mend;

proc ds2;
    ds2_options sas;
    package pytestpkg /overwrite=yes;
        dcl package logger logr('App.tk.MAS');
        dcl package pymas py();

        method pytestpub( in_out int rc, in_out int revision );
            dcl varchar(87654321) character set utf8 pypgm;
            
            rc = py.appendSrcLine( 'from sklearn.externals.joblib import load' ); 
            %chkrc
           rc = py.appendSrcLine( 'import numpy as np' ); 
            %chkrc
            rc = py.appendSrcLine( 'def xyz( ins1, ins2 ):' ); 
            %chkrc
            rc = py.appendSrcLine('   ''''''Output: outs1''''''');
            %chkrc
            rc = py.appendSrcLine('   npa = np.array([[1,2,3],[4,5,6]])');
            %chkrc
            rc = py.appendSrcLine('   print(npa[1][2])' );
            %chkrc
            rc = py.appendSrcLine('   return ins1 + '' from xyz''' );
            %chkrc
            pypgm = py.getSource();
            logr.log( 'i', 'pypgm = $s', pypgm );

            revision = py.publish(pypgm, 'xyz_module_name');
            if (revision < 1) then do;
                logr.log('E', 'Error: Python publishing failed.');
                return;
            end;
            
            /* Specify method to execute */
            rc = py.useMethod('xyz');
            if ( rc or ^revision ) then
                logr.log('E', 'Error: Python function xyz not found.');
        end;

        method pytestexec( nvarchar(87654321) inStr,
                           in_out int rc, in_out nvarchar outStr );
            py.setString('ins1', inStr);
            py.setString('ins2', 'Second string not consumed.' );
            rc = py.execute();
            if rc then
                logr.log( 'E', 'Error: Execution failed.' );
            else
                outStr = py.getString( 'outs1' );
        end;

    endpackage;

    data _null_;
        dcl package logger logr( 'App.tk.MAS' );
        dcl package pytestpkg t();
        dcl int rc revision;
        dcl nvarchar(87654321) myOutStr;

        method init();
            t.pytestpub( rc, revision );
            if rc then
                logr.log( 'E', 'Error: Method pytestpub failed.' );
        end;

        method run();
            t.pytestexec( n'Audi éàêA€A', rc, myOutStr );
            if rc then
                logr.log( 'E', 'Error: Method pytestexec failed.' );
            else do;
                logr.log( 'I', '##### myOutStr=$s', myOutStr );
            end;
        end;
    enddata;
    run;
quit;