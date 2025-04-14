#if UNITY_EDITOR_WIN && !UNITY_ANDROID && !UNITY_IPHONE

using UnityEngine;
using UnityEditor;
using System.Collections;
using System; 

using System.Data; 
using System.Data.Odbc; 
using System.Data.OleDb;
using System.IO;
using System.Text;

using Excel;

public class MyDataSet
{
    public DataSet dtSet = null;
    public int count = 0;
    public MyDataSet(DataSet tableSet)
    {
        dtSet = tableSet;
        count = tableSet.Tables.Count;
    }
    public MyDataSet() { }

    public DataTable GetDataTable(string tableName)
    {
        foreach (DataTable dt in dtSet.Tables)
        {
            if (dt.TableName.Equals(tableName))
            {
                return dt;
            }
        }
        return null;
    }
    public void LogTable(string tableName)
    {
        foreach (DataTable dTable in dtSet.Tables)
        {
            if (tableName.Equals(dTable.TableName))
            {
                for (int i = 0; i < dTable.Columns.Count; i++ )
                {
                    Debug.Log("row ele:" + dTable.Rows[2][i].ToString());
                }
                /*
                    foreach (DataColumn dc in dTable.Columns)
                    {
                        //Debug.Log("col : " + dc.ColumnName);

                        foreach (DataRow dr in dTable.Rows)
                        {
                            Debug.Log("ele : " + dr[dc].ToString());
                        }
                    }
                 * */
            }
        }
    }
    public bool GetTable(string tableName)
    {
        return dtSet.Tables.Contains(tableName);
    }
    public bool GetTable(string tableName , out DataTable dTabel)
    {
        bool result = dtSet.Tables.Contains(tableName);
        if (result)
            dTabel = dtSet.Tables[tableName];
        else
            dTabel = null;
        return result;
    }
    public string[] GetColumnData(string tableName, string columeName , int headrow = 0)
    {
        DataTable dTable  = dtSet.Tables[tableName];
        int rowIndex = 0;
        string[]  result = null;
        if(dTable == null)
        {
            
            Debug.LogError(string.Format("there is not Table:{0} in excel file :{1}" , tableName ,"1"));
            return null;
        }

        if (headrow < dTable.Rows.Count)
        {
            rowIndex = headrow;
            DataRow rowForColumn = dTable.Rows[rowIndex++];
            result = new string[dTable.Rows.Count - rowIndex];

            for (int icol = 0; icol < dTable.Columns.Count; ++icol)
            {
                if(columeName.Equals( rowForColumn[icol].ToString()))
                {
                    DataColumn dColumn = dTable.Columns[icol];
                    for(int irow = rowIndex ; irow < dTable.Rows.Count ; ++irow)
                    {
                        result[irow - rowIndex] = dTable.Rows[irow][icol].ToString();
                    }
                }
            }
        }
        else
        {

        }
        return result;
    }
}
public class MyDataTable : DataTable
{

	public MyDataTable(string _str) : base(_str)
	{

	}
    
	public string GetStr(int row, int column)
	{
		if (row < Rows.Count && column < Columns.Count)
			return Rows[row][column].ToString();
		else
		{
			return string.Empty;
		}
	}
	
	public int GetInt(int row, int column)
	{
		string result = GetStr(row, column);
		if (result != string.Empty)
		{
			return int.Parse(result);
		}
		else
		{
			return 0;
		}
	}
	
	public short GetShort(int row, int column)
	{
		string result = GetStr(row, column);
		if (result != string.Empty)
		{
			return short.Parse(result);
		}
		else
		{
			return 0;
		}
	}
	
	public byte GetByte(int row, int column)
	{
		string result = GetStr(row, column);
		if (result != string.Empty)
		{
			return byte.Parse(result);
		}
		else
		{
			return 0;
		}
	}
	
	public float GetFloat(int row, int column)
	{
		string result = GetStr(row, column);
		if (result != string.Empty)
		{
			return float.Parse(result);
		}
		else
		{
			return 0;
		}
	}
    
	public string[] GetColumnHeader()
	{
		string[] result = new string[Columns.Count - 1];
		for (int i = 0; i < Columns.Count - 1; i++) 
		{
			result[i] = Columns[i + 1].ColumnName;
		}
		return result;
	}
	
	public string[] GetRowHeader()
	{
		string[] result = new string[Rows.Count];
		for (int i = 0; i < Rows.Count; i++) 
		{
			result[i] = Rows[i][0].ToString();
		}
		return result;
	}
	
	public string[] GetColumnData(string columnName)
	{
		int columnIndex = 1;
		for (int i=0; i<Columns.Count; i++)
		{
			if (columnName.Equals(Columns[i].ColumnName))
			{
				columnIndex = i;
				break;
			}
		}
		
		string[] result = new string[Rows.Count];
		for (int i = 0; i < Rows.Count; i++) 
		{
			result[i] = Rows[i][columnIndex].ToString();
		}
		return result;
	}
}

public class ExcelReader 
{
	private static string sheetName = "sheet1";
	public static MyDataTable dtData;
	public static bool success;
    public static MyDataSet dtDataSet;

	public static void ReadXLSInResource(string _excelFile, string _sheetName)
	{
		success = false;
		sheetName = _sheetName;
		ReadXLS(_excelFile + ".xls");
	}
	public static void ReadXLSInResource(string _excelFile)
    {
        success = false;
        ReadXLS(_excelFile + ".xls");
    }
    public static void ReadXLSXInResource(string _excelFile)
    {
        success = false;
        ReadXLSXFile(_excelFile + ".xlsx");
    }
    static void ReadXLSXFile(string filetoread)
    {
        
        FileStream stream = File.Open(filetoread, FileMode.Open, FileAccess.Read);
        //Choose one of either 1 or 2
        //1. Reading from a binary Excel file ('97-2003 format; *.xls)
        //IExcelDataReader excelReader = ExcelReaderFactory.CreateBinaryReader(stream);

        //2. Reading from a OpenXml Excel file (2007 format; *.xlsx)
        IExcelDataReader excelReader = ExcelReaderFactory.CreateOpenXmlReader(stream);

        //Choose one of either 3, 4, or 5
        //3. DataSet - The result of each spreadsheet will be created in the result.Tables
        DataSet result = excelReader.AsDataSet();
        //result.Tables;
        //4. DataSet - Create column names from first row
        //excelReader.IsFirstRowAsColumnNames = true;
        //DataSet result = excelReader.AsDataSet();
        //5. Data Reader methods
        //while (excelReader.Read())
        //{
        //    excelReader.GetInt32(0);
        //    Debug.Log("ele : " + excelReader.GetInt32(0));
        // }

        //6. Free resources (IExcelDataReader is IDisposable)
        excelReader.Close();
        stream = null;

        //excel file read test log 
        /*
        DataTable dtable_chapter = result.Tables["Chapters"];
        Debug.Log("table name :" + dtable_chapter.TableName + "and coluim num :" + dtable_chapter.Columns.Count + "and rows num : " + dtable_chapter.Rows.Count);
        //foreach(DataColumn dcolum in dtable_chapter.Columns)
        for (int j = 0; j < dtable_chapter.Columns.Count; ++j)
        {
            DataColumn dcol = dtable_chapter.Columns[j];
            for (int i = 0; i < dtable_chapter.Rows.Count; ++i)
            {
                DataRow drow = dtable_chapter.Rows[i];
                Debug.Log("row : " + i + "col : " + j);
                Debug.Log("ele1 : " + drow[dcol].ToString());
                //Debug.Log("ele2 : " + drow[j].ToString());
                //Debug.Log("ele3 : " + drow[dcol.ColumnName].ToString());
                Debug.Log("type : " + drow[dcol].GetType().ToString());
                Debug.Log("isNull : " + drow.IsNull(dcol));
                Debug.Log("length : " + drow[dcol].ToString().Length);
            }
        }
        */
        
        dtDataSet = new MyDataSet(result);
        success = true;
        
    }
    static void ReadXLS(string filetoread)
    {
        /*
        try
        {

            
			// Must be saved as excel 2003 workbook, not 2007, mono issue really
			string con = "Driver={Microsoft Excel Driver (*.xls)}; DriverId=790; Dbq="+filetoread+";";
			Debug.Log(con);
			string dataQuery = "SELECT * FROM ["+sheetName+"$]"; 
			// odbc connector 
			oCon = new OdbcConnection(con); 
			// command object 
			OdbcCommand oCmd = new OdbcCommand(dataQuery, oCon);
			// table to hold the data 
			dtData = new MyDataTable("Data"); 
			// open the connection 
			oCon.Open(); 
			// datareader to fill that table
			rData = oCmd.ExecuteReader(); 
			// load data 
			dtData.Load(rData); 

			if(dtData.Rows.Count > 0) 
			{ 
				Debug.Log("row count is "+dtData.Rows.Count+" column count is "+dtData.Columns.Count);
				// do something with the data here 
				for (int i = 0; i < dtData.Rows.Count; i++) 
				{ 
					// for giggles, lets see the column name then the data for that column! 
					Debug.Log(dtData.Rows[i][0].ToString() + " : " + dtData.Rows[i][dtData.Columns[1].ColumnName]); 
				} 
			} 
            
			success = true;
		}
		catch (OdbcException exception)
		{
			Debug.Log(exception.Message);
			success = false;
			if(EditorUtility.DisplayDialog("Read text excel file error!",
			                               "Could not find "+filetoread+ "\nor the file is in use,\nplease close the file or locate the correct file's position.",
			                               "OK"))
			{
				//ReadXLS(filetoread);
			}
		}
		finally
		{
            
			// close that reader
			if (rData != null)
				rData.Close(); 
			// close connection
			if (oCon != null)
				oCon.Close(); 
             
		}
             * */

    } 
}

#endif