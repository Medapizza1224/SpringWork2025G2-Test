package control.system;

import java.time.LocalDate;

import dao.DaoException;
import dao.SeatManagementDao;
import modelUtil.Failure;

public class DeleteReservations {

    public void execute() throws Failure {
        try {
            SeatManagementDao reservationDao = new SeatManagementDao();
            // 本日より前の日付の予約をすべて削除する
            LocalDate today = LocalDate.now();
            reservationDao.deleteReservations(today);
            System.out.println("古い予約データのクリーンアップ処理が正常に完了しました。");

        } catch (DaoException daoException) {
            // エラーログは出力するが、定期実行タスクなので上位にはスローしないことも検討
            System.err.println("予約データの削除中にデータベースエラーが発生しました。");
            daoException.printStackTrace();
            throw new Failure("予約データの削除中にデータベースエラーが発生しました。", daoException);
        } catch (Exception e) {
            System.err.println("予約データの削除処理中に予期せぬエラーが発生しました。");
            e.printStackTrace();
            throw new Failure("予約データの削除処理中に予期せぬエラーが発生しました。", e);
        }
    }
}