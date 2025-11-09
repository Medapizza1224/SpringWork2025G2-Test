package servlet.system;

import java.time.Instant; // ★★★ インポートを変更 ★★★
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit; // ★★★ インポートを追加 ★★★
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import dao.DaoException;
import dao.SeatManagementDao;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Webアプリケーションの起動時に、古い仮予約を定期的にクリーンアップするタスクを開始し、
 * 終了時にタスクを安全に停止するためのリスナー。
 */
@WebListener
public class TentativeReservationCleanup implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    /**
     * アプリケーション起動時に呼び出されるメソッド。
     * 定期実行タスクをスケジュールする。
     */
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // シングルスレッドのスケジューラを作成
        scheduler = Executors.newSingleThreadScheduledExecutor();

        // タスクを定義（ラムダ式で記述）
        Runnable cleanupTask = () -> {
            try {
                System.out.println("仮予約/予約時間経過クリーンアップタスク実行: " + LocalDateTime.now());
                SeatManagementDao dao = new SeatManagementDao();
                
                // 常にUTCであるInstantを使い、「現在時刻から10分前」の時点を計算します。
                // これにより、サーバーのタイムゾーン設定に依存しなくなります。
                Instant cutoffTime = Instant.now().minus(1, ChronoUnit.MINUTES);
                
                // 修正したDAOメソッドを呼び出します
                int canceledCount = dao.cancelExpiredProvisionalReservations(cutoffTime);                
                                
                if (canceledCount > 0) {
                    System.out.println(canceledCount + "件の期限切れ仮予約/予約をキャンセルしました。");
                }
                
            } catch (DaoException e) {
                // エラーが発生してもスケジューラが止まらないように、ここでキャッチしてログに出力
                System.err.println("仮予約のクリーンアップ中にエラーが発生しました。");
                e.printStackTrace();
            }
        };

        // アプリケーション起動後すぐにタスクを開始し、その後は1分ごとに繰り返し実行
        // 第2引数: 初回実行までの遅延
        // 第3引数: 2回目以降の実行間隔
        // 第4引数: 時間の単位
        scheduler.scheduleAtFixedRate(cleanupTask, 1, 1, TimeUnit.MINUTES);
        
        System.out.println("仮予約の自動キャンセルスケジューラを開始しました。");
    }

    /**
     * アプリケーション終了時に呼び出されるメソッド。
     * スケジューラを安全にシャットダウンする。
     */
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            System.out.println("仮予約の自動キャンセルスケジューラを停止しました。");
        }
    }
}