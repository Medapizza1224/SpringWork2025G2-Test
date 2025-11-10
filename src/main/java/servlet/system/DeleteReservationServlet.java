package servlet.system;

import java.time.Duration;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import control.system.CheckoutReservation; // ★★★ インポートを追加 ★★★
import control.system.DeleteReservations;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import modelUtil.Failure;

@WebListener
public class DeleteReservationServlet implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // スケジューラを初期化 (単一スレッドで十分ですが、必要に応じてスレッドプールも利用可)
        scheduler = Executors.newSingleThreadScheduledExecutor();

        // --- タスク1: 古い予約の削除 (毎日定時実行) ---
        scheduleDailyReservationDeletion();

        // --- タスク2: 終了した予約の自動チェックアウト (定期実行) ---
        scheduleAutoCheckout();
    }

    /**
     * 古い予約を毎日定時に削除するタスクをスケジュールします。
     */
    private void scheduleDailyReservationDeletion() {
        Runnable deleteTask = () -> {
            try {
                System.out.println("古い予約データの削除処理を開始します。");
                new DeleteReservations().execute();
            } catch (Failure e) {
                e.printStackTrace();
            }
        };

        final int EXECUTION_HOUR = 20;
        final int EXECUTION_MINUTE = 31;
        final int EXECUTION_SECOND = 0;

        ZoneId zoneId = ZoneId.of("Asia/Tokyo");
        ZonedDateTime now = ZonedDateTime.now(zoneId);

        ZonedDateTime nextRun = now
            .withHour(EXECUTION_HOUR)
            .withMinute(EXECUTION_MINUTE)
            .withSecond(EXECUTION_SECOND);

        if (now.isAfter(nextRun)) {
            nextRun = nextRun.plusDays(1);
        }

        long initialDelay = Duration.between(now, nextRun).toMillis();
        long period = TimeUnit.DAYS.toMillis(1);
        scheduler.scheduleAtFixedRate(deleteTask, initialDelay, period, TimeUnit.MILLISECONDS);
        
        System.out.println("予約削除スケジューラが初期化されました。初回実行は " + nextRun + " です。");
    }

    /**
     * 終了時刻を過ぎた予約を自動でチェックアウトするタスクをスケジュールします。
     */
    private void scheduleAutoCheckout() {
        Runnable checkoutTask = () -> new CheckoutReservation().execute();

        // サーバー起動後、最初の実行までの待機時間（秒）
        final long INITIAL_DELAY_SECONDS = 10;
        // 実行間隔（分）
        final long PERIOD_MINUTES = 10;

        // scheduleAtFixedRateの最後の引数(TimeUnit)は、initialDelayとperiodの両方に適用されるため注意
        // ここでは分単位でスケジュールするため、初期遅延も分に変換するか、
        // もしくは全体を秒単位で管理するのが明確です。
        
        // --- Option A: 全てを秒で管理する ---
        long periodSeconds = TimeUnit.MINUTES.toSeconds(PERIOD_MINUTES);
        scheduler.scheduleAtFixedRate(checkoutTask, INITIAL_DELAY_SECONDS, periodSeconds, TimeUnit.SECONDS);
        System.out.println("予約の自動チェックアウトスケジューラが初期化されました。" + PERIOD_MINUTES + "分ごとに実行されます。");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
            System.out.println("バックグラウンド処理スケジューラがシャットダウンされました。");
        }
    }
}