package control.checkin;

import java.util.UUID;
import dao.DaoException;
import dao.SeatManagementDao;
import entity.Reservation;
import modelUtil.Failure;

public class Checkin {

    public void execute(UUID reservationId) throws Failure {
        try {
            SeatManagementDao reservationDao = new SeatManagementDao();
            
            // 予約IDで正しく検索するメソッドを呼び出すように修正
            Reservation reservation = reservationDao.getOneByReservationId(reservationId);
            
            if (reservation == null) {
                // 仮予約のデータが見つからない場合のエラー
                // 原因：createOneメソッドのコミット漏れ、または予期せぬIDが渡された
                throw new Failure("確定対象の予約データが見つかりません。ID: " + reservationId);
            }
            
            // ステータスを更新する
            reservationDao.updateStatus(reservationId, "チェックイン済み");
            
        } catch (DaoException daoException) {
          throw new Failure("予約の確定処理中にデータベースエラーが発生しました。", daoException);
        } catch (Exception e) {
          // 予期せぬその他のエラー
          e.printStackTrace(); // ログに詳細を出力
          throw new Failure("予約の確定処理中に予期せぬエラーが発生しました。", e);
        }
    }
}