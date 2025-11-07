package entity;

import java.time.LocalDate;
import java.time.LocalDateTime; // インポートを追加
import java.time.LocalTime;
import java.util.UUID;

public class Reservation {

    private UUID reservationId;
    private UUID userId;
    private int numberOfPeople;
    private LocalDate reservationDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private String reservationStatus;
    private LocalDateTime createdAt; // ★★★ フィールドを追加 ★★★
    private String seat1;
    private String seat2;
    private String seat3;
    private String seat4;
    private String seat5;
    private String seat6;
    private String seat7;
    private String seat8;
    
    public Reservation() {
    }

    public UUID getReservationId() {
        return reservationId;
    }

    public void setReservationId(UUID reservationId) {
        this.reservationId = reservationId;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public int getNumberOfPeople() {
        return numberOfPeople;
    }

    public void setNumberOfPeople(int numberOfPeople) {
        this.numberOfPeople = numberOfPeople;
    }

    public LocalDate getReservationDate() {
        return reservationDate;
    }

    public void setReservationDate(LocalDate reservationDate) {
        this.reservationDate = reservationDate;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalTime endTime) {
        this.endTime = endTime;
    }

    public String getReservationStatus() {
        return reservationStatus;
    }

    public void setReservationStatus(String reservationStatus) {
        this.reservationStatus = reservationStatus;
    }
    
    // ★★★ 追加したフィールドのゲッターとセッター ★★★
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getSeat1() {
        return seat1;
    }

    public void setSeat1(String seat1) {
        this.seat1 = seat1;
    }

    public String getSeat2() {
        return seat2;
    }

    public void setSeat2(String seat2) {
        this.seat2 = seat2;
    }

    public String getSeat3() {
        return seat3;
    }

    public void setSeat3(String seat3) {
        this.seat3 = seat3;
    }

    public String getSeat4() {
        return seat4;
    }

    public void setSeat4(String seat4) {
        this.seat4 = seat4;
    }

    public String getSeat5() {
        return seat5;
    }

    public void setSeat5(String seat5) {
        this.seat5 = seat5;
    }

    public String getSeat6() {
        return seat6;
    }

    public void setSeat6(String seat6) {
        this.seat6 = seat6;
    }

    public String getSeat7() {
        return seat7;
    }

    public void setSeat7(String seat7) {
        this.seat7 = seat7;
    }

    public String getSeat8() {
        return seat8;
    }

    public void setSeat8(String seat8) {
        this.seat8 = seat8;
    }
}