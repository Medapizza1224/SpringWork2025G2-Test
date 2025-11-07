package control.checkin;

import entity.Reservation;

public record CheckinConfirmReservationResult(Reservation reservation, String message) {
}