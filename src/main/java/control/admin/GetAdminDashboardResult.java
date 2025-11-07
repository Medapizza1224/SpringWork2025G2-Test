package control.admin;

import java.util.List;
import entity.Admin;
import entity.User;

public record GetAdminDashboardResult(
    List<User> userList,
    List<Admin> adminList,
    List<ReservationDTO> reservationDtoList,
    String message
) {}