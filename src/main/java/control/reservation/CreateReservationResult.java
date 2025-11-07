package control.reservation;

import entity.Reservation;

public record CreateReservationResult(Reservation reservation, String message) {
}