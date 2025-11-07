package servlet.checkin;

import java.io.IOException;
import java.util.UUID; // UUIDクラスをインポート

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import control.checkin.Checkin; // Checkinクラスをインポート
import dao.DaoException; // DaoExceptionをインポート
import dao.SeatManagementDao; // SeatManagementDaoをインポート
import entity.Reservation; // Reservationクラスをインポート
import modelUtil.Failure; // Failureクラスをインポート

@WebServlet("/checkin-nonreservation-confirmed")
public class CheckinNonreservationConfirmedServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/checkin/checkin-result-nonreserved.jsp").forward(request, response);
    }

    /**
     * POSTリクエストを処理します。
     * QRコードまたは手動入力で受け取った予約IDを元に、ステータスを「チェックイン済み」に更新します。
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        String qrData = request.getParameter("qrData");
        String manualData = request.getParameter("manualData");
        String inputData;

        // QRデータまたは手動入力データのどちらかを取得
        if (qrData != null && !qrData.isEmpty()) {
            inputData = qrData;
        } else if (manualData != null && !manualData.isEmpty()) {
            inputData = manualData;
        } else {
            // データがどちらも空の場合
            request.setAttribute("errorMessage", "予約IDが入力されていません。");
            request.getRequestDispatcher("/WEB-INF/checkin/checkin-result-nonreserved.jsp").forward(request, response);
            return;
        }

        System.out.println("受け取ったデータ: " + inputData);

        try {
            // 受け取った文字列をUUIDオブジェクトに変換
            UUID reservationId = UUID.fromString(inputData.trim());
            
            // チェックイン処理のビジネスロジックを呼び出し
            Checkin checkin = new Checkin();
            checkin.execute(reservationId);
            
            // 成功した場合、更新後の予約情報を取得してリクエスト属性に設定
            SeatManagementDao dao = new SeatManagementDao();
            Reservation updatedReservation = dao.getOneByReservationId(reservationId);
            
            request.setAttribute("successMessage", "チェックインが完了しました。");
            request.setAttribute("reservation", updatedReservation);

        } catch (IllegalArgumentException e) {
            // UUIDの形式が不正だった場合
            System.err.println("無効な予約ID形式です: " + inputData);
            request.setAttribute("errorMessage", "無効な予約IDです。QRコードを確認するか、正しい予約番号を入力してください。");
        } catch (Failure e) {
            // Checkinロジック内でエラーが発生した場合
            System.err.println("チェックイン処理に失敗しました: " + e.getMessage());
            request.setAttribute("errorMessage", e.getMessage()); // Failureオブジェクトからのメッセージを表示
        } catch (DaoException e) {
            // データベースアクセスでエラーが発生した場合
            System.err.println("データベースエラー: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "データベース処理中にエラーが発生しました。");
        } catch (Exception e) {
            // その他の予期せぬエラー
             System.err.println("予期せぬエラーが発生しました: " + e.getMessage());
             e.printStackTrace();
             request.setAttribute("errorMessage", "システムエラーが発生しました。管理者に連絡してください。");
        }

        // 結果表示用のJSPにフォワード
        request.getRequestDispatcher("/WEB-INF/checkin/checkin-result-nonreserved.jsp").forward(request, response);
    }
}