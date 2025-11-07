package control.checkin;

import entity.Reservation;

public record CheckinCreateReservationResult(Reservation reservation, String message) {
}