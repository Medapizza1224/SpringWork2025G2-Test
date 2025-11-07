package control.reservation;

import dao.DaoException;
import dao.DataSourceHolder;
import dao.SeatManagementDao;
import entity.Reservation;
import modelUtil.Failure;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.UUID;

/**
 * 予約の振り替え（新規作成＋旧予約キャンセル）をトランザクション内で実行する。
 * このクラスがトランザクションの開始(setAutoCommit(false))、コミット、ロールバックの責務を持つ。
 */
public class ChangeReservation {

    private final DataSource dataSource;

    public ChangeReservation() {
        this.dataSource = new DataSourceHolder().dataSource;
    }

    /**
     * 新しい予約を作成し、成功した場合にのみ古い予約をキャンセルする。
     * @param newReservation 画面から入力された情報で作成された新しい予約情報
     * @param oldReservationId キャンセル対象となる、元の予約ID
     * @throws Failure 処理中にデータベースエラーが発生した場合
     */
    public void execute(Reservation newReservation, UUID oldReservationId) throws Failure {
        Connection connection = null;
        SeatManagementDao reservationDao = new SeatManagementDao();

        try {
            // 1. データベース接続を取得
            connection = this.dataSource.getConnection();
            // 2. トランザクションを開始
            connection.setAutoCommit(false);
            // 3. 新しい予約をデータベースに登録する (Connectionを渡す)
            reservationDao.createOne(newReservation, connection);
            // 4. 古い予約のステータスを「キャンセル」に更新する (Connectionを渡す)
            reservationDao.updateStatus(oldReservationId, "キャンセル", connection);
            // 5. 全ての処理が成功したので、トランザクションをコミット
            connection.commit();

        } catch (SQLException | DaoException e) {
            // 6. エラーが発生した場合は、全ての変更をロールバック（取り消し）
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw new Failure("予約の変更処理中にデータベースエラーが発生しました。", e);

        } finally {
            // 7. 最後に必ずデータベース接続を閉じる
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}