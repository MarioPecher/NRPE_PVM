CONNECT TO OWSH900;
SELECT SCUSER AS USER, JDEDATECONV(SCUPMJ) AS LastChange, JDEDATECONV(SCUPMJ) + 365 DAYS AS ExpireDate, JDEDATECONV(JDEDateNow()) AS DateNow, 
CASE WHEN 
((JDEDATECONV(SCUPMJ) + 365 DAYS)< (JDEDATECONV(JDEDateNow()) + 7 DAYS)) THEN 'CRIT'
ELSE
	'WARN'
END AS State 
,
((JDEDATECONV(SCUPMJ) + 365 DAYS) - JDEDATECONV(JDEDateNow())) AS ExpireInDays
FROM sy900.f98owsec 
WHERE 
EXISTS (SELECT 
F0092.ULUSER as USERNAME
FROM    SY900.F0092 F0092
WHERE  
F0092.ULUSER not in ('SECOFR','CNCADMIN','SYSADMIN','DEVELOPER')
and F0092.ULUSER NOT IN ( select RLTOROLE from sy900.F95921 where RLFRROLE='USRDISABLE' )
AND F0092.ULUSER = SCUSER
GROUP BY     F0092.ULUSER , F0092.ULAN8
ORDER BY      F0092.ULUSER ASC)
AND 
JDEDATECONV(SCUPMJ) + 365 days < JDEDATECONV(JDEDateNow()) + 10 DAYS
and scmuse='SSOADMIN';
TERMINATE;
