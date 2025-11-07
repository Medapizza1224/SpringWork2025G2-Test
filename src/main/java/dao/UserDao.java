package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;
import java.util.UUID;
import org.mindrot.jbcrypt.BCrypt;
import modelUtil.Failure;


import javax.sql.DataSource;

import entity.User;

public class UserDao {
  private final DataSource dataSource;
  private final ConnectionCloser connectionCloser;

  public UserDao() {
    this.dataSource = new DataSourceHolder().dataSource;
    this.connectionCloser = new ConnectionCloser();
  }

  //新しいユーザーを登録
  public void createOne(User user) throws DaoException {

    Connection connection = null;
    String sql = "INSERT INTO `UserManagement` (`user_id`, `user_name`, `user_password`, `secret_question`, `secret_question_answer`, `user_status`) VALUES (?, ?, ?, ?, ?, ?)";

    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);

      String hashedPassword = BCrypt.hashpw(user.getUserPassword(), BCrypt.gensalt());

      preparedStatement.setObject(1, user.getUserId().toString()); //setObject：型を自動選択
      preparedStatement.setString(2, user.getUserName());
      preparedStatement.setString(3, hashedPassword);
      preparedStatement.setString(4, user.getSecretQuestion());
      preparedStatement.setString(5, user.getSecretQuestionAnswer());
      preparedStatement.setString(6, user.getUserStatus());

      preparedStatement.executeUpdate();

    } catch (SQLException sqlException) {
      throw new DaoException("アカウントの作成中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  //あるユーザーの情報を取得（パスワード認証用）
  public User getOneByUserName(String userName) throws DaoException {
    
    Connection connection = null;
    String sql = "SELECT * FROM `UserManagement` WHERE `user_name` = ?";

    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setObject(1, userName);
      ResultSet resultSet = preparedStatement.executeQuery();

      if (!resultSet.next()) {
        return null;
      }
      UUID userUUID = UUID.fromString(resultSet.getString("user_id")); //UUID型に変換
      // new User() が Failure 例外をスローする可能性があるため try-catch で囲む
      try {
        return new User( //user型でコントロールに返す
          userUUID,
          resultSet.getString("user_name"),
          resultSet.getString("user_password"),
          resultSet.getString("secret_question"),
          resultSet.getString("secret_question_answer"),
          resultSet.getString("user_status"));
      } catch (Failure failure) {
        // データベース内のデータが不正な場合
        throw new DaoException("データベースから取得したユーザー情報の形式が不正です。", failure);
      }
    } catch (SQLException sqlException) {
      throw new DaoException("パスワード認証中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  //ユーザー一覧を取得
  public List<User> getUserAll() throws DaoException {

    Connection connection = null;
    String sql = "SELECT * FROM `UserManagement`";

    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      ResultSet resultSet = preparedStatement.executeQuery();

      List<User> userList = new LinkedList<>();
      while (resultSet.next()) {
        UUID userUUID = UUID.fromString(resultSet.getString("user_id")); //UUID型に変換
        // new User() が Failure 例外をスローする可能性があるため try-catch で囲む
        try {
          User user = new User(
              userUUID,
              resultSet.getString("user_name"),
              resultSet.getString("user_password"),
              resultSet.getString("secret_question"),
              resultSet.getString("secret_question_answer"),
              resultSet.getString("user_status"));
          userList.add(user);
        } catch (Failure failure) {
          // データベース内のデータが不正な場合
          throw new DaoException("データベースから取得したユーザー情報の形式が不正です。ID: " + userUUID, failure);
        }
      }
      return userList;

    } catch (SQLException sqlException) {
      throw new DaoException("データベースとの通信中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  //管理者の削除
  public void deleteByUserName(String userName) throws DaoException {

    Connection connection = null;
    String sql = "DELETE FROM `UserManagement` WHERE `user_name` = ?";

    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setString(1, userName.toString());
      preparedStatement.executeUpdate();

    } catch (SQLException sqlException) {
      throw new DaoException("削除中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  //管理者情報の更新
  public void updateuser(User user) throws DaoException {
    Connection connection = null;
    String sql = "UPDATE `UserManagement` SET " +
                 "`user_name` = ?, " +
                 "`user_password` = ?, " +
                 "`secret_question` = ?, " +
                 "`secret_question_answer` = ?, " +
                 "`user_status` = ? " +
                 "WHERE `user_id` = ?";
    
    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);

      String hashedPassword = BCrypt.hashpw(user.getUserPassword(), BCrypt.gensalt());

      preparedStatement.setString(1, user.getUserName());
        preparedStatement.setString(2, hashedPassword);
        preparedStatement.setString(3, user.getSecretQuestion());
        preparedStatement.setString(4, user.getSecretQuestionAnswer());
        preparedStatement.setString(5, user.getUserStatus());
        preparedStatement.setString(6, user.getUserId().toString());
      preparedStatement.executeUpdate();

    } catch (SQLException sqlException) {
      throw new DaoException("管理者情報の更新中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }
}