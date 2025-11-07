package control.reservation;

import dao.SeatManagementDao;
import dao.DaoException;
import modelUtil.Failure;

import java.util.UUID;

public class DeleteReservationsByUserId {
    public void execute(UUID userId) throws Failure {
        try {
            SeatManagementDao reservationDao = new SeatManagementDao();
            reservationDao.deleteByUserId(userId);

        } catch (DaoException daoException) {
            throw new Failure("ユーザーID (" + userId.toString() + ") の予約削除中にエラーが発生しました。", daoException);
        }
    }
}