--drops and recreates a basic version of a table (or, creates a rough clone of your table)
--not all things are considered, just data types and nullability
DECLARE @SourceTableName NVARCHAR(128) = 'test'

--replace @SourceTableName here if you want to clone a table rather than delete and recreate
DECLARE @TargetTableName NVARCHAR(128) = @SourceTableName

DECLARE @DynDocCreate NVARCHAR(MAX)

SELECT @DynDocCreate = 'CREATE TABLE ' + @TargetTableName + '(' + 
          STUFF( (
            SELECT ',' + c2.name + ' ' + 
             CASE WHEN ty2.name IN ('varchar','nvarchar','varbinary')
              THEN ty2.name + '(' + 
                CASE WHEN c2.max_length = -1
                THEN 'MAX'
                ELSE CONVERT(VARCHAR(MAX),c2.max_length)
              END + ')'
              ELSE ty2.name
             END +
             CASE WHEN c2.is_nullable = 1 
              THEN ' NULL'
              ELSE ' NOT NULL'
             END
            FROM sys.tables t2
              INNER JOIN sys.columns c2 ON t2.object_id = c2.object_id
              INNER JOIN sys.types ty2 ON c2.system_type_id = ty2.system_type_id
                AND c2.user_type_id = ty2.user_type_id
            WHERE c2.object_id = c.object_id
            ORDER BY c2.column_id
            FOR XML PATH ('')
           ) ,1,1,'' ) + ')'
FROM sys.tables t
  INNER JOIN sys.columns c ON t.object_id = c.object_id
  INNER JOIN sys.types ty ON c.system_type_id = ty.system_type_id
    AND c.user_type_id = ty.user_type_id
WHERE t.name = @SourceTableName
GROUP BY c.object_id

IF @SourceTableName = @TargetTableName
BEGIN
  DECLARE @DropTable NVARCHAR(MAX)
  SET @DropTable = 'DROP TABLE ' + @SourceTableName
  EXEC sp_executesql @DropTable
END

EXEC sp_executesql @DynDocCreate

