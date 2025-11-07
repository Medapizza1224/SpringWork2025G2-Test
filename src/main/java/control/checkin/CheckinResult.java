package control.checkin;

import entity.Reservation;

public record CheckinResult(Reservation reservation, String message) {
}