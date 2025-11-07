package control.reservation;

import dao.DaoException;
import dao.SeatManagementDao;
import entity.Reservation;
import modelUtil.Failure;

public class Checkout {

    public void execute(Reservation reservation) throws Failure {

        if (reservation.getReservationId() == null) {
            throw new Failure("予約IDが指定されていません。更新できません。", null);
        }

        try {
            SeatManagementDao reservationDao = new SeatManagementDao();
            reservationDao.updateReservation(reservation);

        } catch (DaoException daoException) {
            throw new Failure("予約情報の更新中にデータベースエラーが発生しました。", daoException);
        }
    }
}