package control.reservation;

import entity.Reservation;

public record ConfirmReservationResult(Reservation reservation, String message) {
}