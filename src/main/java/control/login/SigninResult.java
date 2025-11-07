package control.login;

import java.util.Optional;

import entity.Reservation;
import entity.User;

public record SigninResult(
        User user,
        Optional<Reservation> activeReservation) {
}
