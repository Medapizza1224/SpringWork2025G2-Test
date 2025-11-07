package control.reservation;

import dao.DaoException;
import dao.SeatManagementDao;
import modelUtil.Failure;
import java.util.UUID;

public class CancelReservation {
    public void execute(UUID reservationId) throws Failure {
        if (reservationId == null) {
            throw new Failure("予約IDが指定されていません。キャンセルできません。", null);
        }
        try {
            SeatManagementDao reservationDao = new SeatManagementDao();
            // 予約ステータスを「キャンセル」に更新する
            reservationDao.updateStatus(reservationId, "キャンセル");
        } catch (DaoException daoException) {
            throw new Failure("予約のキャンセル処理中にデータベースエラーが発生しました。", daoException);
        }
    }
}