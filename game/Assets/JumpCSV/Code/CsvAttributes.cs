using System;

namespace JumpCSV {
	public class CsvColumnTypeAttributes : Attribute {
		public Type    mColumnType; 
		public string  mTypeName;
		public CsvColumnTypeAttributes(Type columnType, string typeName) {
			mColumnType  = columnType;
			mTypeName    = typeName;
		}
	}
}
