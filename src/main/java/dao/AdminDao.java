package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;
import java.util.UUID;

import javax.sql.DataSource;

import entity.Admin;
import modelUtil.Failure;

public class AdminDao {
  private final DataSource dataSource;
  private final ConnectionCloser connectionCloser;

  public AdminDao() {
    this.dataSource = new DataSourceHolder().dataSource;
    this.connectionCloser = new ConnectionCloser();
  }

  //新しい管理者を登録
  public void createOne(Admin admin) throws DaoException {

    Connection connection = null;
    String sql = "INSERT INTO `AdminManagement` (`admin_id`, `admin_name`, `admin_password`, `admin_status`) VALUES (?, ?, ?, ?)";

    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);

      preparedStatement.setObject(1, admin.getAdminId()); //setObject：型を自動選択
      preparedStatement.setObject(2, admin.getAdminName());
      preparedStatement.setString(3, admin.getAdminPassword());
      preparedStatement.setString(4, admin.getAdminStatus());

      preparedStatement.executeUpdate();

    } catch (SQLException sqlException) {
      throw new DaoException("管理者の追加中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  //ある管理者の情報を取得（パスワード認証用）
  public Admin getOneByAdminId(String adminId) throws DaoException {
    
    Connection connection = null;
    String sql = "SELECT * FROM `AdminManagement` WHERE `admin_id` = ?";

    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setObject(1, adminId);
      ResultSet resultSet = preparedStatement.executeQuery();
      
      if (!resultSet.next()) {
        return null;
      }
      
      UUID adminUUID = UUID.fromString(resultSet.getString("admin_id")); //UUID型に変換

      // ★★★ 修正箇所 ★★★
      // new Admin() が Failure 例外をスローする可能性があるため try-catch で囲む
      try {
        return new Admin( //admin型でコントロールに返す
          adminUUID,
          resultSet.getString("admin_name"),
          resultSet.getString("admin_password"),
          resultSet.getString("admin_status"));
      } catch (Failure failure) {
        throw new DaoException("データベースから取得した管理者情報の形式が不正です。", failure);
      }
    } catch (SQLException sqlException) {
      throw new DaoException("パスワード認証中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  //管理者一覧を取得
  public List<Admin> getAdminAll() throws DaoException {

    Connection connection = null;
    String sql = "SELECT * FROM `AdminManagement`";

    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      ResultSet resultSet = preparedStatement.executeQuery();

      List<Admin> adminList = new LinkedList<>();
      while (resultSet.next()) {
        UUID adminUUID = UUID.fromString(resultSet.getString("admin_id")); //UUID型に変換
        // new Admin() が Failure 例外をスローする可能性があるため try-catch で囲む
        try {
          Admin admin = new Admin(
              adminUUID,
              resultSet.getString("admin_name"),
              resultSet.getString("admin_password"),
              resultSet.getString("admin_status"));
          adminList.add(admin);
        } catch (Failure failure) {
          throw new DaoException("データベースから取得した管理者情報の形式が不正です。ID: " + adminUUID, failure);
        }
      }
      return adminList;

    } catch (SQLException sqlException) {
      throw new DaoException("データベースとの通信中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  //管理者の削除
  public void deleteByAdminName(String adminName) throws DaoException {

    Connection connection = null;
    String sql = "DELETE FROM `AdminManagement` WHERE `admin_name` = ?";

    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setString(1, adminName.toString());
      preparedStatement.executeUpdate();

    } catch (SQLException sqlException) {
      throw new DaoException("削除中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  //管理者情報の更新
  public void updateAdmin(Admin admin) throws DaoException {
    Connection connection = null;
    String sql = "UPDATE `AdminManagement` SET " +
                 "`admin_id` = ?, " +
                 "`admin_name` = ?, " +
                 "`admin_password` = ?, " +
                 "`admin_status` = ?, ";
    
    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);

      preparedStatement.setObject(1, admin.getAdminId());
      preparedStatement.setString(2, admin.getAdminName());
      preparedStatement.setString(3, admin.getAdminPassword());
      preparedStatement.setString(4, admin.getAdminStatus()); 
      preparedStatement.executeUpdate();

    } catch (SQLException sqlException) {
      throw new DaoException("管理者情報の更新中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }
}