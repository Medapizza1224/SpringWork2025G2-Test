package control.admin;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.time.ZoneId;
import java.util.Date;
import entity.Reservation;

public class ReservationDTO {

    // ... (既存のプロパティは変更なし)
    private final UUID reservationId;
    private final UUID userId;
    private final int numberOfPeople;
    private final LocalDate reservationDate;
    private final LocalTime startTime;
    private final LocalTime endTime;
    private final String reservationStatus;
    private final String seatsAsString;


    // ... (コンストラクタは変更なし)
    public ReservationDTO(UUID reservationId, UUID userId, int numberOfPeople, LocalDate reservationDate,
            LocalTime startTime, LocalTime endTime, String reservationStatus, String seatsAsString) {
        this.reservationId = reservationId;
        this.userId = userId;
        this.numberOfPeople = numberOfPeople;
        this.reservationDate = reservationDate;
        this.startTime = startTime;
        this.endTime = endTime;
        this.reservationStatus = reservationStatus;
        this.seatsAsString = seatsAsString;
    }

    // --- 既存のゲッター (変更なし) ---
    public UUID getReservationId() { return reservationId; }
    public UUID getUserId() { return userId; }
    public int getNumberOfPeople() { return numberOfPeople; }
    public LocalDate getReservationDate() { return reservationDate; }
    public LocalTime getStartTime() { return startTime; }
    public LocalTime getEndTime() { return endTime; }
    public String getReservationStatus() { return reservationStatus; }
    public String getSeatsAsString() { return seatsAsString; }

    // --- 前回追加したメソッド (変更なし) ---
    public Date getReservationDateAsDate() {
        if (this.reservationDate == null) {
            return null;
        }
        return Date.from(this.reservationDate.atStartOfDay(ZoneId.systemDefault()).toInstant());
    }

    // ★★★ ここから追加：LocalTimeをDateに変換するメソッド ★★★
    /**
     * JSPで startTime (LocalTime) をフォーマットするために java.util.Date に変換します。
     * 日付部分はUTCの1970-01-01が使われますが、時刻のフォーマットには影響しません。
     */
    public Date getStartTimeAsDate() {
        if (this.startTime == null) {
            return null;
        }
        // LocalTimeをDateに変換するため、ダミーの日付（LocalDate.now()など）と組み合わせる
        return Date.from(this.startTime.atDate(LocalDate.now()).atZone(ZoneId.systemDefault()).toInstant());
    }

    /**
     * JSPで endTime (LocalTime) をフォーマットするために java.util.Date に変換します。
     */
    public Date getEndTimeAsDate() {
        if (this.endTime == null) {
            return null;
        }
        return Date.from(this.endTime.atDate(LocalDate.now()).atZone(ZoneId.systemDefault()).toInstant());
    }
    // ★★★ ここまで追加 ★★★


    // ... (fromEntityメソッドは変更なし)
    public static ReservationDTO fromEntity(Reservation r) {
        // ...
        String seats = Stream.of(
                            r.getSeat1(), r.getSeat2(), r.getSeat3(), r.getSeat4(),
                            r.getSeat5(), r.getSeat6(), r.getSeat7(), r.getSeat8()
                         )
                         .filter(s -> s != null && !s.isEmpty())
                         .collect(Collectors.joining(", "));

        return new ReservationDTO(
            r.getReservationId(), r.getUserId(), r.getNumberOfPeople(),
            r.getReservationDate(), r.getStartTime(), r.getEndTime(),
            r.getReservationStatus(), seats
        );
    }
}