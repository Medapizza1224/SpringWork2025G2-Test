package control.reservation;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

import dao.DaoException;
import dao.SeatManagementDao;
import entity.Reservation;
import modelUtil.Failure;

public class CreateReservation {

    public CreateReservationResult execute(
            UUID userId,
            int numberOfPeople, 
            List<String> seatNames, 
            LocalDate reservationDate, 
            LocalTime startTime, 
            LocalTime endTime) throws Failure {
        
        try {
            UUID reservationId = UUID.randomUUID(); 
            
            Reservation reservation = new Reservation();
            reservation.setReservationId(reservationId);
            reservation.setUserId(userId);
            reservation.setNumberOfPeople(numberOfPeople);
            reservation.setReservationDate(reservationDate);
            reservation.setStartTime(startTime);
            reservation.setEndTime(endTime);
            reservation.setReservationStatus("仮予約");

            String[] seats = new String[8];
            for (int i = 0; i < 8; i++) {
                if (i < seatNames.size()) {
                    seats[i] = seatNames.get(i);
                } else {
                    seats[i] = null;
                }
            }
            reservation.setSeat1(seats[0]);
            reservation.setSeat2(seats[1]);
            reservation.setSeat3(seats[2]);
            reservation.setSeat4(seats[3]);
            reservation.setSeat5(seats[4]);
            reservation.setSeat6(seats[5]);
            reservation.setSeat7(seats[6]);
            reservation.setSeat8(seats[7]);

            SeatManagementDao reservationDao = new  SeatManagementDao();
            reservationDao.createOne(reservation);
            
            return new CreateReservationResult(reservation, "予約の登録に成功しました");
            
        } catch (DaoException daoException) {
          throw new Failure("予約の登録中にデータベースエラーが発生しました。", daoException);
        } catch (Exception e) {
          throw new Failure("予約の登録処理中に予期せぬエラーが発生しました。", e);
        }
    }
}