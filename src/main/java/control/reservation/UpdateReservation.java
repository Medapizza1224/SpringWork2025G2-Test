package control.reservation;

import dao.DaoException;
import dao.SeatManagementDao;
import entity.Reservation;
import modelUtil.Failure;

/**
 * 既存の予約情報を更新するビジネスロジックを担うクラス。
 */
public class UpdateReservation {

    /**
     * 渡された予約情報オブジェクトの内容でデータベースを更新する。
     *
     * @param reservation 更新する予約情報（予約IDを含む）
     * @throws Failure 更新処理中にエラーが発生した場合
     */
    public void execute(Reservation reservation) throws Failure {

        // 予約IDがnullの場合は更新対象が特定できないためエラーとする
        if (reservation.getReservationId() == null) {
            throw new Failure("予約IDが指定されていないため、更新できません。", null);
        }

        try {
            SeatManagementDao reservationDao = new SeatManagementDao();
            // DAOを呼び出してデータベースの更新処理を実行する
            reservationDao.updateReservation(reservation);

        } catch (DaoException daoException) {
            // DAO層で発生した例外をラップして上位にスローする
            throw new Failure("予約情報の更新中にデータベースエラーが発生しました。", daoException);
        }
    }
}