using System.Data;
using MySql.Data.MySqlClient;
using UnityEngine;

public class MysqlMethod {
    MySqlConnection OpenMysql() {
        string strMysql = "server=" + GameConfig.serverId
            + "; user id = " + GameConfig.userId +
            "; password = " + GameConfig.password +
            "; database = " + GameConfig.database;
        MySqlConnection msqlConnection = new MySqlConnection(strMysql);
        msqlConnection.Open();
        return msqlConnection;
    }

    void CloseMysql(MySqlConnection mysqlConnection) {
        if (mysqlConnection.State == System.Data.ConnectionState.Open) {
            mysqlConnection.Close();
        }
    }

    public void CreateAccountPlayer(string accountId) {
        MySqlConnection mysqlConnection = OpenMysql();

        MySqlCommand msqlCommand = new MySqlCommand("select * from server_info where `name` = 'dbid'", mysqlConnection);
        MySqlDataReader msqlReader = msqlCommand.ExecuteReader();
        int dbid = 0;
        while (msqlReader.Read()) {
            int.TryParse(msqlReader.GetString(msqlReader.GetOrdinal("value")), out dbid);
            break;
        }
        if (dbid == 0) {
            return;
        }
        msqlReader.Close();
        MySqlCommand cmd;
        cmd = mysqlConnection.CreateCommand();
        cmd.CommandText = "INSERT INTO players(id, accountId, name, recordInfo) VALUES(@id, @accountId, @name, @recordInfo)";
        cmd.Parameters.AddWithValue("@id", dbid);
        cmd.Parameters.AddWithValue("@accountId", accountId);
        cmd.Parameters.AddWithValue("@name", accountId);
        cmd.Parameters.AddWithValue("@recordInfo", "");
        cmd.ExecuteNonQuery();

        dbid += 1;
        string strDbid = dbid.ToString();
        MySqlCommand update;
        update = mysqlConnection.CreateCommand();
        update.CommandText = "UPDATE server_info SET `value` = '" + strDbid + "' WHERE `name` = 'dbid'; ";
        update.ExecuteNonQuery();

        CloseMysql(mysqlConnection);
        GameData.Instance.InitDataInfo(dbid, accountId, accountId, 1, 1, "");
        Debug.Log("create account success");
    }

    public void GetAccountPlayer(string accountId) {
        MySqlConnection mysqlConnection = OpenMysql();
        MySqlCommand msqlCommand = new MySqlCommand("select * from players where `accountId` = '" + accountId + "'", mysqlConnection);
        
        
        MySqlDataReader msqlReader = msqlCommand.ExecuteReader();
        int id = 0;
        string name = "";
        int sex = 1;
        int level = 1;
        string recordInfo = "";
        while (msqlReader.Read()) {
            id = msqlReader.GetInt32(msqlReader.GetOrdinal("id"));
            accountId = msqlReader.GetString(msqlReader.GetOrdinal("accountId"));
            name = msqlReader.GetString(msqlReader.GetOrdinal("name"));
            sex = msqlReader.GetInt32(msqlReader.GetOrdinal("sex"));
            level = msqlReader.GetInt32(msqlReader.GetOrdinal("level"));
            recordInfo = msqlReader.GetString(msqlReader.GetOrdinal("recordInfo"));
            break;
        }
        
        CloseMysql(mysqlConnection);
        if (id == 0) {
            Debug.Log("create account");
            CreateAccountPlayer(accountId);
        } else {
            GameData.Instance.InitDataInfo(id, accountId, name, sex, level, recordInfo);
            Debug.Log("login account");
        }
    }

    public void SaveAccountPlayer(string accountId) {
        MySqlConnection mysqlConnection = OpenMysql();

        MySqlCommand update;
        update = mysqlConnection.CreateCommand();
        update.CommandText = "UPDATE server_info SET `recordInfo` = '" + GameData.Instance.GetRecordInfo() + "' WHERE `accountId` = '" + accountId + "'";
        update.ExecuteNonQuery();
        
        CloseMysql(mysqlConnection);
        Debug.Log("save account success");
    }

}