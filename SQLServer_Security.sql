------------------
--User Databases
------------------
SELECT getdate() 
SELECT name UserDB  
FROM sys.databases  
WHERE database_id > 4  
AND name NOT IN ('ReportServer','ReportServerTempDB','SSISDB','DBA_Tools') 
--------    
SELECT getdate(),count(name) UserDBCount  
FROM sys.databases  
WHERE database_id > 4  
AND name NOT IN ('ReportServer','ReportServerTempDB','SSISDB','DBA_Tools') 

------------------------------------------------------------
--Server Logins with sysadmin or securityadmin Server Role 
------------------------------------------------------------
SELECT getdate() 
SELECT r.name as Server_Level_Role, m.name as Login_Name, m.type_desc as Type_Of_Login 
FROM master.sys.server_role_members rm  
INNER JOIN master.sys.server_principals r ON r.principal_id = rm.role_principal_id and r.type = 'R'  
INNER JOIN master.sys.server_principals m ON m.principal_id = rm.member_principal_id  
WHERE r.name IN ('sysadmin','securityadmin')  
-------- 
SELECT getdate() 
SELECT r.name as Server_Level_Role, count(1) 'Count' 
FROM master.sys.server_role_members rm  
INNER JOIN master.sys.server_principals r ON r.principal_id = rm.role_principal_id AND r.type = 'R'  
INNER JOIN master.sys.server_principals m ON m.principal_id = rm.member_principal_id  
WHERE r.name IN ('sysadmin','securityadmin') 
GROUP BY r.name
 
-----------------------
--Database Principals
-----------------------
DECLARE @SQL nvarchar(MAX); 
SET @SQL = N'';
SELECT @SQL = @SQL + N' UNION ALL 
                SELECT CONCAT_WS('' - '', ''' + name + ''', principal_id) as entitlement_service_identifier, 
                CONCAT_WS('' - '', ''' + name + ''', name) as entitlement_name,
                ''database role'' AS entitlement_type
                FROM ' + QUOTENAME(name) + '.sys.database_principals
                WHERE type = ''R'''
FROM sys.databases where name not in ('ReportServer','ReportServerTempDB');
SET @SQL = STUFF(@SQL, 1, 10, '');
EXEC sp_executesql @SQL;

--------------------------------------
--Database Principals. DB Permissions
--------------------------------------
DECLARE @SQL nvarchar(MAX); 
SET @SQL = N'';
SELECT @SQL = @SQL + N' UNION ALL 
                SELECT ''' + name + ''' Database_Name, dp.name DB_UsersName, rp.name Role, prm.permission_name as Securable, OBJECT_NAME(major_id) as Table_Name
                FROM ' + QUOTENAME(name) + '.sys.database_role_members drm
                inner join ' + QUOTENAME(name) + '.sys.database_principals rp on rp.principal_id = drm.role_principal_id
                inner join ' + QUOTENAME(name) + '.sys.database_principals dp on dp.principal_id = drm.member_principal_id
                inner join ' + QUOTENAME(name) + '.sys.database_permissions prm on prm.grantee_principal_id = dp.principal_id
                inner join ' + QUOTENAME(name) + '.sys.database_principals rol on prm.grantee_principal_id = rol.principal_id'
FROM sys.databases;
SET @SQL = STUFF(@SQL, 1, 10, '');
PRINT @SQL
EXEC sp_executesql @SQL;
  