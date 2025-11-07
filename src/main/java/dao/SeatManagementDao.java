package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import javax.sql.DataSource;
import entity.Reservation;

public class SeatManagementDao {
  private final DataSource dataSource;
  private final ConnectionCloser connectionCloser;

  public SeatManagementDao() {
    this.dataSource = new DataSourceHolder().dataSource;
    this.connectionCloser = new ConnectionCloser();
  }

  // ★★★ 追加: トランザクション管理下で実行されるためのメソッド ★★★
  /**
   * 新しい予約を1件登録する (Connection外部管理版)。
   * このメソッドはトランザクションの開始・終了を行わない。
   * @param reservation 登録する予約情報
   * @param connection 外部で管理されているDB接続
   * @throws DaoException データベースアクセスエラーが発生した場合
   */
  public void createOne(Reservation reservation, Connection connection) throws DaoException {
    String sql = "INSERT INTO `SeatManagement` (`reservation_id`, `user_id`, `number_of_people`, `reservation_date`, `start_time`, `end_time`, `reservation_status`, `seat_1`, `seat_2`, `seat_3`, `seat_4`, `seat_5`, `seat_6`, `seat_7`, `seat_8`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
        preparedStatement.setString(1, reservation.getReservationId().toString());
        preparedStatement.setString(2, reservation.getUserId().toString());
        preparedStatement.setInt(3, reservation.getNumberOfPeople());
        preparedStatement.setDate(4, Date.valueOf(reservation.getReservationDate()));
        preparedStatement.setTime(5, Time.valueOf(reservation.getStartTime()));
        preparedStatement.setTime(6, Time.valueOf(reservation.getEndTime()));
        preparedStatement.setString(7, reservation.getReservationStatus());
        preparedStatement.setString(8, reservation.getSeat1());
        preparedStatement.setString(9, reservation.getSeat2());
        preparedStatement.setString(10, reservation.getSeat3());
        preparedStatement.setString(11, reservation.getSeat4());
        preparedStatement.setString(12, reservation.getSeat5());
        preparedStatement.setString(13, reservation.getSeat6());
        preparedStatement.setString(14, reservation.getSeat7());
        preparedStatement.setString(15, reservation.getSeat8());
        preparedStatement.executeUpdate();
    } catch (SQLException sqlException) {
        throw new DaoException("データベースへの予約情報挿入中にエラーが発生しました。", sqlException);
    }
  }
  
  // ★★★ 修正: 既存メソッドを、上記メソッドを呼び出す形に変更 ★★★
  /**
   * 新しい予約を1件データベースに登録する。
   * created_atはデータベースのデフォルト値(CURRENT_TIMESTAMP)により自動で設定される。
   * @param reservation 登録する予約情報
   * @throws DaoException データベースアクセスエラーが発生した場合
   */
  public void createOne(Reservation reservation) throws DaoException {
    Connection connection = null;
    try {
        connection = this.dataSource.getConnection();
        connection.setAutoCommit(false);

        // Connectionを渡して実行
        createOne(reservation, connection);

        connection.commit();

    } catch (SQLException | DaoException e) {
        if (connection != null) {
            try {
                connection.rollback();
            } catch (SQLException ex) {
                throw new DaoException("ロールバックに失敗しました。", ex);
            }
        }
        throw new DaoException("データベースへの予約情報挿入中にエラーが発生しました。", e);
    } finally {
        this.connectionCloser.closeConnection(connection);
    }
  }
  
  /**
   * 予約IDをキーに、予約情報を1件取得する。
   * @param reservationId 検索する予約ID
   * @return 見つかった予約情報。見つからない場合はnull。
   * @throws DaoException データベースアクセスエラーが発生した場合
   */
  public Reservation getOneByReservationId(UUID reservationId) throws DaoException {
    Connection connection = null;
    String sql = "SELECT * FROM `SeatManagement` WHERE `reservation_id` = ?";
    try {
        connection = this.dataSource.getConnection();
        PreparedStatement preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setString(1, reservationId.toString());
        ResultSet resultSet = preparedStatement.executeQuery();

        if (resultSet.next()) {
            Reservation reservation = new Reservation();
            reservation.setReservationId(UUID.fromString(resultSet.getString("reservation_id")));
            reservation.setUserId(UUID.fromString(resultSet.getString("user_id")));
            reservation.setNumberOfPeople(resultSet.getInt("number_of_people"));
            reservation.setReservationDate(resultSet.getDate("reservation_date").toLocalDate());
            reservation.setStartTime(resultSet.getTime("start_time").toLocalTime());
            reservation.setEndTime(resultSet.getTime("end_time").toLocalTime());
            reservation.setReservationStatus(resultSet.getString("reservation_status"));
            reservation.setCreatedAt(resultSet.getTimestamp("created_at").toLocalDateTime());
            reservation.setSeat1(resultSet.getString("seat_1"));
            reservation.setSeat2(resultSet.getString("seat_2"));
            reservation.setSeat3(resultSet.getString("seat_3"));
            reservation.setSeat4(resultSet.getString("seat_4"));
            reservation.setSeat5(resultSet.getString("seat_5"));
            reservation.setSeat6(resultSet.getString("seat_6"));
            reservation.setSeat7(resultSet.getString("seat_7"));
            reservation.setSeat8(resultSet.getString("seat_8"));
            return reservation;
        }
        return null;
    } catch (SQLException e) {
        throw new DaoException("予約IDによる予約データの取得中にエラーが発生しました。", e);
    } finally {
        this.connectionCloser.closeConnection(connection);
    }
  }

  // (getOneByUserId, getActiveReservationByUserId は変更なしのため省略しません)
  
  public Reservation getOneByUserId(UUID userId) throws DaoException {
    Connection connection = null;
    String sql = "SELECT * FROM `SeatManagement` WHERE `user_id` = ? AND reservation_status IN ('予約済み', '仮予約', 'チェックイン済み')";
    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setString(1, userId.toString());
      ResultSet resultSet = preparedStatement.executeQuery();
      if (resultSet.next()) {
        Reservation reservation = new Reservation();
        reservation.setReservationId(UUID.fromString(resultSet.getString("reservation_id")));
        reservation.setUserId(UUID.fromString(resultSet.getString("user_id")));
        reservation.setNumberOfPeople(resultSet.getInt("number_of_people"));
        reservation.setReservationDate(resultSet.getDate("reservation_date").toLocalDate());
        reservation.setStartTime(resultSet.getTime("start_time").toLocalTime());
        reservation.setEndTime(resultSet.getTime("end_time").toLocalTime());
        reservation.setReservationStatus(resultSet.getString("reservation_status"));
        reservation.setCreatedAt(resultSet.getTimestamp("created_at").toLocalDateTime());
        reservation.setSeat1(resultSet.getString("seat_1"));
        reservation.setSeat2(resultSet.getString("seat_2"));
        reservation.setSeat3(resultSet.getString("seat_3"));
        reservation.setSeat4(resultSet.getString("seat_4"));
        reservation.setSeat5(resultSet.getString("seat_5"));
        reservation.setSeat6(resultSet.getString("seat_6"));
        reservation.setSeat7(resultSet.getString("seat_7"));
        reservation.setSeat8(resultSet.getString("seat_8"));
        return reservation;
      }
      return null;
    } catch (SQLException e) {
      throw new DaoException("ユーザーIDによる予約データの取得中にエラーが発生しました。", e);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  public Reservation getActiveReservationByUserId(UUID userId) throws DaoException {
    Connection connection = null;
    String sql = "SELECT * FROM `SeatManagement` WHERE `user_id` = ? AND reservation_status IN ('予約済み', 'チェックイン済み') ORDER BY reservation_date DESC, start_time DESC LIMIT 1";
    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setString(1, userId.toString());
      ResultSet resultSet = preparedStatement.executeQuery();
      if (resultSet.next()) {
        Reservation reservation = new Reservation();
        reservation.setReservationId(UUID.fromString(resultSet.getString("reservation_id")));
        reservation.setUserId(UUID.fromString(resultSet.getString("user_id")));
        reservation.setNumberOfPeople(resultSet.getInt("number_of_people"));
        reservation.setReservationDate(resultSet.getDate("reservation_date").toLocalDate());
        reservation.setStartTime(resultSet.getTime("start_time").toLocalTime());
        reservation.setEndTime(resultSet.getTime("end_time").toLocalTime());
        reservation.setReservationStatus(resultSet.getString("reservation_status"));
        reservation.setCreatedAt(resultSet.getTimestamp("created_at").toLocalDateTime());
        reservation.setSeat1(resultSet.getString("seat_1"));
        reservation.setSeat2(resultSet.getString("seat_2"));
        reservation.setSeat3(resultSet.getString("seat_3"));
        reservation.setSeat4(resultSet.getString("seat_4"));
        reservation.setSeat5(resultSet.getString("seat_5"));
        reservation.setSeat6(resultSet.getString("seat_6"));
        reservation.setSeat7(resultSet.getString("seat_7"));
        reservation.setSeat8(resultSet.getString("seat_8"));
        return reservation;
      }
      return null;
    } catch (SQLException e) {
      throw new DaoException("ユーザーIDによる有効な予約データの取得中にエラーが発生しました。", e);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  // ★★★ 追加: トランザクション管理下で実行されるためのメソッド ★★★
  /**
   * 指定された予約IDのステータスを更新する (Connection外部管理版)。
   * @param reservationId 更新対象の予約ID
   * @param newStatus 新しいステータス文字列
   * @param connection 外部で管理されているDB接続
   * @throws DaoException
   */
  public void updateStatus(UUID reservationId, String newStatus, Connection connection) throws DaoException {
      String sql = "UPDATE `SeatManagement` SET `reservation_status` = ? WHERE `reservation_id` = ?";
      try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
          preparedStatement.setString(1, newStatus);
          preparedStatement.setString(2, reservationId.toString());
          preparedStatement.executeUpdate();
      } catch (SQLException e) {
          throw new DaoException("予約ステータスの更新中にエラーが発生しました。", e);
      }
  }
  
  // ★★★ 修正: 既存メソッドを、上記メソッドを呼び出す形に変更 ★★★
  /**
   * 指定された予約IDのステータスを更新する。
   * @param reservationId 更新対象の予約ID
   * @param newStatus 新しいステータス文字列
   * @throws DaoException データベースアクセスエラーが発生した場合
   */
  public void updateStatus(UUID reservationId, String newStatus) throws DaoException {
      Connection connection = null;
      try {
          connection = this.dataSource.getConnection();
          connection.setAutoCommit(false);
          
          // Connectionを渡して実行
          updateStatus(reservationId, newStatus, connection);
          
          connection.commit();
      } catch (SQLException | DaoException e) {
          if (connection != null) {
              try {
                  connection.rollback();
              } catch (SQLException ex) {
                  throw new DaoException("ロールバックに失敗しました。", ex);
              }
          }
          throw new DaoException("予約ステータスの更新中にエラーが発生しました。", e);
      } finally {
          this.connectionCloser.closeConnection(connection);
      }
  }
  
  // (以降のメソッドは変更なしのため、そのまま全文掲載します)

  public int cancelExpiredProvisionalReservations(Instant cutoffInstant) throws DaoException {
    Connection connection = null;
    String sql = "UPDATE `SeatManagement` SET `reservation_status` = 'キャンセル' " +
                 "WHERE `reservation_status` = '仮予約' AND `created_at` < ?";
    try {
      connection = this.dataSource.getConnection();
      connection.setAutoCommit(false);
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setTimestamp(1, Timestamp.from(cutoffInstant));
      int updatedRows = preparedStatement.executeUpdate();
      connection.commit();
      return updatedRows;
    } catch (SQLException e) {
      if (connection != null) {
        try { connection.rollback(); } catch (SQLException ex) { throw new DaoException("ロールバックに失敗しました。", ex); }
      }
      throw new DaoException("期限切れの仮予約の更新中にエラーが発生しました。", e);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  public List<String> getSearchReservationSeats(LocalDate date, LocalTime startTime, LocalTime endTime) throws DaoException {
    Connection connection = null;
    List<String> searchReservationSeats = new ArrayList<>();
    String sql = "SELECT `seat_1`, `seat_2`, `seat_3`, `seat_4`, `seat_5`, `seat_6`, `seat_7`, `seat_8` FROM `SeatManagement` WHERE " +
                 "`reservation_date` = ? AND `start_time` < ? AND `end_time` > ? AND reservation_status IN ('予約済み', '仮予約', 'チェックイン済み')"; 
    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setDate(1, Date.valueOf(date));
      preparedStatement.setTime(2, Time.valueOf(endTime));
      preparedStatement.setTime(3, Time.valueOf(startTime));
      ResultSet resultSet = preparedStatement.executeQuery();
      while (resultSet.next()) {
        for (int i = 1; i <= 8; i++) {
          String seatName = resultSet.getString(i);
            if (seatName != null && !seatName.isEmpty()) {
              searchReservationSeats.add(seatName);
          }
        }
      }
      return searchReservationSeats;
    } catch (SQLException e) {
      throw new DaoException("座席情報の取得中にエラーが発生しました。", e);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  public List<String> getReservationSeats(LocalDate date, LocalTime time) throws DaoException {
    Connection connection = null;
    List<String> reservationSeats = new ArrayList<>();
    String sql = "SELECT `seat_1`, `seat_2`, `seat_3`, `seat_4`, `seat_5`, `seat_6`, `seat_7`, `seat_8` FROM `SeatManagement` WHERE " +
                 "`reservation_date` = ? AND `start_time` <= ? AND `end_time` > ? AND reservation_status IN ('予約済み', '仮予約', 'チェックイン済み')";
    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setDate(1, Date.valueOf(date));
      preparedStatement.setTime(2, Time.valueOf(time));
      preparedStatement.setTime(3, Time.valueOf(time));
      ResultSet resultSet = preparedStatement.executeQuery();
      while (resultSet.next()) {
        for (int i = 1; i <= 8; i++) {
          String seatName = resultSet.getString(i);
          if (seatName != null && !seatName.isEmpty()) {
            reservationSeats.add(seatName);
          }
        }
      }
      return reservationSeats;
    } catch (SQLException e) {
      throw new DaoException("座席情報の取得中にエラーが発生しました。", e);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  public void deleteByUserId(UUID userId) throws DaoException {
    Connection connection = null;
    String sql = "DELETE FROM `SeatManagement` WHERE `user_id` = ?";
    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setString(1, userId.toString());
      preparedStatement.executeUpdate();
    } catch (SQLException sqlException) {
      throw new DaoException("ユーザーIDによる予約行の削除中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  public List<Reservation> getAllReservations() throws DaoException {
    Connection connection = null;
    String sql = "SELECT * FROM `SeatManagement` ORDER BY `reservation_date` DESC, `start_time` DESC";
    List<Reservation> reservationList = new ArrayList<>();
    try {
      connection = this.dataSource.getConnection();
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      ResultSet resultSet = preparedStatement.executeQuery();
      while (resultSet.next()) {
        Reservation reservation = new Reservation();
        reservation.setReservationId(UUID.fromString(resultSet.getString("reservation_id")));
        reservation.setUserId(UUID.fromString(resultSet.getString("user_id")));
        reservation.setNumberOfPeople(resultSet.getInt("number_of_people"));
        reservation.setReservationDate(resultSet.getDate("reservation_date").toLocalDate());
        reservation.setStartTime(resultSet.getTime("start_time").toLocalTime());
        reservation.setEndTime(resultSet.getTime("end_time").toLocalTime());
        reservation.setReservationStatus(resultSet.getString("reservation_status"));
        reservation.setCreatedAt(resultSet.getTimestamp("created_at").toLocalDateTime());
        reservation.setSeat1(resultSet.getString("seat_1"));
        reservation.setSeat2(resultSet.getString("seat_2"));
        reservation.setSeat3(resultSet.getString("seat_3"));
        reservation.setSeat4(resultSet.getString("seat_4"));
        reservation.setSeat5(resultSet.getString("seat_5"));
        reservation.setSeat6(resultSet.getString("seat_6"));
        reservation.setSeat7(resultSet.getString("seat_7"));
        reservation.setSeat8(resultSet.getString("seat_8"));
        reservationList.add(reservation);
      }
      return reservationList;
    } catch (SQLException e) {
      throw new DaoException("全予約情報の取得中にエラーが発生しました。", e);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  public Map<String, String> getSeatStatuses(LocalDate date, LocalTime time) throws DaoException {
    Connection connection = null;
    Map<String, String> seatStatusMap = new HashMap<>();
    String sql = "SELECT reservation_status, seat_1, seat_2, seat_3, seat_4, seat_5, seat_6, seat_7, seat_8 " +
                 "FROM SeatManagement " +
                 "WHERE reservation_date = ? AND start_time <= ? AND end_time > ? " +
                 "AND reservation_status IN ('予約済み', '仮予約', 'チェックイン済み')";
    try {
        connection = this.dataSource.getConnection();
        PreparedStatement preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setDate(1, Date.valueOf(date));
        preparedStatement.setTime(2, Time.valueOf(time));
        preparedStatement.setTime(3, Time.valueOf(time));
        ResultSet resultSet = preparedStatement.executeQuery();
        while (resultSet.next()) {
            String status = resultSet.getString("reservation_status");
            for (int i = 2; i <= 9; i++) {
                String seatName = resultSet.getString(i);
                if (seatName != null && !seatName.isEmpty()) {
                    seatStatusMap.put(seatName, status);
                }
            }
        }
        return seatStatusMap;
    } catch (SQLException e) {
        throw new DaoException("特定時刻の座席ステータス取得中にエラーが発生しました。", e);
    } finally {
        this.connectionCloser.closeConnection(connection);
    }
  }

  public Map<String, String> getSeatStatusesForTimeRange(LocalDate date, LocalTime startTime) throws DaoException {
    Connection connection = null;
    Map<String, String> seatStatusMap = new HashMap<>();
    LocalTime endTime = startTime.plusMinutes(10);
    String sql = "SELECT reservation_status, seat_1, seat_2, seat_3, seat_4, seat_5, seat_6, seat_7, seat_8 " +
                 "FROM SeatManagement " +
                 "WHERE reservation_date = ? AND start_time < ? AND end_time > ? " +
                 "AND reservation_status IN ('予約済み', '仮予約', 'チェックイン済み')";
    try {
        connection = this.dataSource.getConnection();
        PreparedStatement preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setDate(1, Date.valueOf(date));
        preparedStatement.setTime(2, Time.valueOf(endTime));
        preparedStatement.setTime(3, Time.valueOf(startTime));
        ResultSet resultSet = preparedStatement.executeQuery();
        while (resultSet.next()) {
            String status = resultSet.getString("reservation_status");
            for (int i = 2; i <= 9; i++) {
                String seatName = resultSet.getString(i);
                if (seatName != null && !seatName.isEmpty()) {
                    seatStatusMap.put(seatName, status);
                }
            }
        }
        return seatStatusMap;
    } catch (SQLException e) {
        throw new DaoException("特定時間範囲の座席ステータス取得中にエラーが発生しました。", e);
    } finally {
        this.connectionCloser.closeConnection(connection);
    }
  }

  public void deleteReservations(LocalDate targetDate) throws DaoException {
    Connection connection = null;
    String sql = "DELETE FROM `SeatManagement` WHERE `reservation_date` < ?";
    try {
      connection = this.dataSource.getConnection();
      connection.setAutoCommit(false);

      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setDate(1, Date.valueOf(targetDate));
      preparedStatement.executeUpdate();

      connection.commit();

    } catch (SQLException sqlException) {
      if (connection != null) {
        try { connection.rollback(); } catch (SQLException e) { throw new DaoException("ロールバックに失敗しました。", e); }
      }
      throw new DaoException("古い予約データの削除中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  public int checkoutExpiredReservations(LocalDate currentDate, LocalTime currentTime) throws DaoException {
    Connection connection = null;
    String sql = "UPDATE `SeatManagement` SET `reservation_status` = 'チェックアウト' " +
                 "WHERE `reservation_status` IN ('予約済み', 'チェックイン済み') " +
                 "AND (`reservation_date` < ? OR (`reservation_date` = ? AND `end_time` <= ?))";
    try {
      connection = this.dataSource.getConnection();
      connection.setAutoCommit(false);

      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setDate(1, Date.valueOf(currentDate));
      preparedStatement.setDate(2, Date.valueOf(currentDate));
      preparedStatement.setTime(3, Time.valueOf(currentTime));

      int updatedRows = preparedStatement.executeUpdate();

      connection.commit();
      return updatedRows;

    } catch (SQLException e) {
      if (connection != null) {
        try { connection.rollback(); } catch (SQLException ex) { throw new DaoException("ロールバックに失敗しました。", ex); }
      }
      throw new DaoException("期限切れ予約のチェックアウト処理中にエラーが発生しました。", e);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

  public void updateReservation(Reservation reservation) throws DaoException {
    Connection connection = null;
    String sql = "UPDATE `SeatManagement` SET " +
                 "`number_of_people` = ?, `start_time` = ?, `end_time` = ?, `reservation_status` = ?, " +
                 "`seat_1` = ?, `seat_2` = ?, `seat_3` = ?, `seat_4` = ?, `seat_5` = ?, `seat_6` = ?, `seat_7` = ?, `seat_8` = ? " +
                 "WHERE `reservation_id` = ?";
    try {
      connection = this.dataSource.getConnection();
      connection.setAutoCommit(false);

      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      
      preparedStatement.setInt(1, reservation.getNumberOfPeople());
      preparedStatement.setTime(2, Time.valueOf(reservation.getStartTime()));
      preparedStatement.setTime(3, Time.valueOf(reservation.getEndTime()));
      preparedStatement.setString(4, reservation.getReservationStatus()); 
      preparedStatement.setString(5, reservation.getSeat1());
      preparedStatement.setString(6, reservation.getSeat2());
      preparedStatement.setString(7, reservation.getSeat3());
      preparedStatement.setString(8, reservation.getSeat4());
      preparedStatement.setString(9, reservation.getSeat5());
      preparedStatement.setString(10, reservation.getSeat6());
      preparedStatement.setString(11, reservation.getSeat7());
      preparedStatement.setString(12, reservation.getSeat8());
      preparedStatement.setString(13, reservation.getReservationId().toString());
      
      preparedStatement.executeUpdate();
      
      connection.commit();

    } catch (SQLException sqlException) {
      if (connection != null) {
          try {
              connection.rollback();
          } catch (SQLException e) {
              throw new DaoException("ロールバックに失敗しました。", e);
          }
      }
      throw new DaoException("予約情報の更新中にエラーが発生しました。", sqlException);
    } finally {
      this.connectionCloser.closeConnection(connection);
    }
  }

}