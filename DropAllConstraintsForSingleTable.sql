


CREATE TABLE #TableConstraints ( TCID INT IDENTITY(1,1), DropStatement VARCHAR(295) )

INSERT #TableConstraints ( DropStatement )
SELECT 
    'ALTER TABLE [' +  OBJECT_SCHEMA_NAME(parent_object_id) +
    '].[' + OBJECT_NAME(parent_object_id) + 
    '] DROP CONSTRAINT [' + name + ']'
FROM sys.foreign_keys
WHERE referenced_object_id = object_id('Document')

DECLARE @ID INT = 1

WHILE EXISTS (
  SELECT 1
  FROM #TableConstraints dc
  WHERE dc.TCID = @ID
)
BEGIN

  DECLARE @ExecString VARCHAR(295)
  SELECT @ExecString = dc.DropStatement
  FROM #TableConstraints dc
  WHERE dc.TCID = @ID

  EXEC(@ExecString)
  
  SELECT @ID = @ID + 1

END