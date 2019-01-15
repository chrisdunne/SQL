BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    SELECT 
	session_Id AS [Spid],
	ecid,
	DB_NAME(sp.[dbid]) AS [Database], 
	nt_username AS [User],
	er.[status] AS [Status],
	wait_type AS [Wait],
	SUBSTRING(qt.[text], 
              er.statement_start_offset/2,
			  (CASE 
			       WHEN er.statement_end_offset = -1 
						THEN LEN(CONVERT(NVARCHAR(MAX), qt.[text])) * 2
						ELSE er.statement_end_offset 
				   END 
			   - er.statement_start_offset)/2) AS [Individual Query],
	qt.[text] AS [Parent Query], 
	program_name AS [Program],
	Hostname,
	nt_domain,
	start_time
    FROM sys.dm_exec_requests er
    INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
    CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
    WHERE session_Id > 50 -- <= 50 = sys pids
    AND session_Id NOT IN (@@SPID)
    ORDER BY 1, 2
END