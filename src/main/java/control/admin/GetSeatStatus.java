package control.admin;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Map;
import dao.DaoException;
import dao.SeatManagementDao;
import modelUtil.Failure;

public class GetSeatStatus {
    public Map<String, String> execute(LocalDate date, LocalTime time) throws Failure {
        try {
            SeatManagementDao dao = new SeatManagementDao();
            return dao.getSeatStatuses(date, time);
        } catch (DaoException e) {
            throw new Failure("座席状況の取得中にデータベースエラーが発生しました。", e);
        }
    }
}