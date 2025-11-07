package control.checkin;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import dao.DaoException;
import dao.SeatManagementDao;
import modelUtil.Failure;

public class CheckinGetReservedSeats {

    public List<String> execute(
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime) throws Failure {
        
        try {
            SeatManagementDao reservationDao = new SeatManagementDao();

            List<String> reservedSeats = reservationDao.getSearchReservationSeats(date, startTime, endTime);
            return reservedSeats;
            
        } catch (DaoException daoException) {
          throw new Failure("予約の確定処理中にデータベースエラーが発生しました。", daoException);
        } catch (Exception e) {
          throw new Failure("予約の確定処理中に予期せぬエラーが発生しました。", e);
        }
    }
}