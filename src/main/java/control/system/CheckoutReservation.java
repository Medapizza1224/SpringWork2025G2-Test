package control.system;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import dao.DaoException;
import dao.SeatManagementDao;

public class CheckoutReservation {

    public void execute() {
        try {
            SeatManagementDao reservationDao = new SeatManagementDao();
            
            // サーバーの時刻設定に関わらず、常に日本時間で現在時刻を取得
            ZonedDateTime nowInJst = ZonedDateTime.now(ZoneId.of("Asia/Tokyo"));
            LocalDate today = nowInJst.toLocalDate();
            LocalTime now = nowInJst.toLocalTime();

            int updatedCount = reservationDao.checkoutExpiredReservations(today, now);
            if (updatedCount > 0) {
                // 処理件数をログに出力
                System.out.println(now + ": " + updatedCount + "件の予約を「チェックアウト」に更新しました。");
            }

        } catch (DaoException e) {
            System.err.println("予約の自動チェックアウト処理中にデータベースエラーが発生しました。");
            e.printStackTrace();
            // 定期実行タスクがエラーで停止しないよう、ここでは例外をスローしない
        } catch (Exception e) {
            System.err.println("予約の自動チェックアウト処理中に予期せぬエラーが発生しました。");
            e.printStackTrace();
        }
    }
}