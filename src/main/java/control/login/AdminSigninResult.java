package control.login;

import java.util.Optional;

import entity.Reservation;
import entity.User;

public record AdminSigninResult(
        User user,
        Optional<Reservation> activeReservation) {
}
