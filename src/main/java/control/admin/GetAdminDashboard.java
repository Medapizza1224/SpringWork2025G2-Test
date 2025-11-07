package control.admin;

import java.util.List;
import java.util.stream.Collectors;
import dao.AdminDao;
import dao.DaoException;
import dao.SeatManagementDao;
import dao.UserDao;
import entity.Admin;
import entity.Reservation;
import entity.User;
import modelUtil.Failure;

public class GetAdminDashboard {
    public GetAdminDashboardResult execute() throws Failure {
        try {
            UserDao userDao = new UserDao();
            AdminDao adminDao = new AdminDao();
            SeatManagementDao reservationDao = new SeatManagementDao();

            List<User> userList = userDao.getUserAll();
            List<Admin> adminList = adminDao.getAdminAll();
            List<Reservation> reservationList = reservationDao.getAllReservations();
            
            List<ReservationDTO> reservationDtoList = reservationList.stream()
                                                                     .map(ReservationDTO::fromEntity)
                                                                     .collect(Collectors.toList());

            return new GetAdminDashboardResult(userList, adminList, reservationDtoList, "管理者データの取得に成功しました。");
        } catch (DaoException e) {
            throw new Failure("管理者データの取得中にデータベースエラーが発生しました。", e);
        } catch (Exception e) {
            throw new Failure("管理者データの取得中に予期せぬエラーが発生しました。", e);
        }
    }
}