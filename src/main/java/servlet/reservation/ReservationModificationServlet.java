package servlet.reservation;

import control.reservation.CancelReservation;
import control.reservation.ChangeReservation;
import control.reservation.GetReservedSeats;
import dao.DaoException;
import dao.SeatManagementDao;
import entity.Reservation;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import modelUtil.Failure;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@WebServlet("/reservation-modify")
public class ReservationModificationServlet extends HttpServlet {

    /**
     * 予約確認・変更画面の初期表示（QRコード表示）
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String reservationIdStr = (String) session.getAttribute("reservationId");

        if (reservationIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        try {
            UUID reservationId = UUID.fromString(reservationIdStr);
            SeatManagementDao dao = new SeatManagementDao();
            Reservation reservation = dao.getOneByReservationId(reservationId);

            if (reservation == null || "キャンセル".equals(reservation.getReservationStatus())) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/");
                return;
            }
            
            setRequestAttributesFromReservation(request, reservation);
            request.setAttribute("view", "qr");
            request.getRequestDispatcher("/WEB-INF/reservation/SeatManagement.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/");
        }
    }

    /**
     * 変更・キャンセルのすべてのPOST操作を処理する
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String step = request.getParameter("step");
        String reservationIdStr = (String) session.getAttribute("reservationId");

        // セッションに元の予約IDがない場合は処理を中断
        if (reservationIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        try {
            UUID oldReservationId = UUID.fromString(reservationIdStr);
            SeatManagementDao dao = new SeatManagementDao();
            Reservation currentReservation = dao.getOneByReservationId(oldReservationId);

            if (currentReservation == null) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/");
                return;
            }

            // stepパラメータに応じて処理を振り分け
            switch (step) {
                // --- 変更フローの各ステップ ---
                case "showChangeView":
                    handleShowChangeView(request, response, session);
                    break;
                case "goToTime":
                    handleGoToTime(request, response, session);
                    break;
                case "goToSeat":
                    handleGoToSeat(request, response, session);
                    break;
                case "provisionalChange":
                    handleProvisionalChange(request, response, session);
                    break;
                case "executeChange":
                    handleExecuteChange(request, response, session, oldReservationId);
                    return; // 完了後はリダイレクトするのでreturn

                // --- キャンセルフロー ---
                case "showCancelConfirm":
                    handleShowCancelConfirm(request, currentReservation);
                    break;
                case "executeCancel":
                    handleExecuteCancel(request, session);
                    request.getRequestDispatcher("/WEB-INF/reservation/cancelComplete.jsp").forward(request, response);
                    return; // 完了後はフォワードするのでreturn
                    
                default:
                    // 不明なステップの場合はQRコード画面に戻す
                    setRequestAttributesFromReservation(request, currentReservation);
                    request.setAttribute("view", "qr");
                    break;
            }

            // executeChange と executeCancel 以外は、最終的にJSPへフォワードする
            request.getRequestDispatcher("/WEB-INF/reservation/SeatManagement.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "予期せぬエラーが発生しました。");
            request.getRequestDispatcher("/WEB-INF/reservation/SeatManagement.jsp").forward(request, response);
        }
    }

    // --- ハンドラメソッド群 ---

    private void handleShowChangeView(HttpServletRequest request, HttpServletResponse response, HttpSession session) {
        // 変更フローで使うセッション属性を初期化
        session.setAttribute("change_numberPeople", "1");
        session.removeAttribute("change_startTime");
        session.removeAttribute("change_endTime");
        session.removeAttribute("change_selectedSeats");
        session.removeAttribute("change_reservationDate");

        request.setAttribute("view", "change"); // 親ビューを「変更」に
        request.setAttribute("changeStep", "main"); // 変更ビュー内のステップを「メイン」に
    }

    private void handleGoToTime(HttpServletRequest request, HttpServletResponse response, HttpSession session) {
        session.setAttribute("change_numberPeople", request.getParameter("numberPeople"));
        request.setAttribute("view", "change");
        request.setAttribute("changeStep", "time");
    }

    private void handleGoToSeat(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws Failure {
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        
        ZoneId tokyoZone = ZoneId.of("Asia/Tokyo");
        String reservationDateStr = LocalDate.now(tokyoZone).toString();
        
        session.setAttribute("change_reservationDate", reservationDateStr);
        session.setAttribute("change_startTime", startTimeStr);
        session.setAttribute("change_endTime", endTimeStr);
        
        GetReservedSeats getReservedSeatsControl = new GetReservedSeats();
        List<String> reservedSeats = getReservedSeatsControl.execute(
                LocalDate.parse(reservationDateStr),
                LocalTime.parse(startTimeStr),
                LocalTime.parse(endTimeStr)
        );
        request.setAttribute("reservedSeats", reservedSeats);
        request.setAttribute("view", "change");
        request.setAttribute("changeStep", "seat");
    }

    private void handleProvisionalChange(HttpServletRequest request, HttpServletResponse response, HttpSession session) {
        // 座席情報をセッションに保存
        session.setAttribute("change_selectedSeats", request.getParameter("selectedSeats"));
        
        request.setAttribute("view", "change");
        request.setAttribute("changeStep", "confirm"); // 確認ステップへ
        request.setAttribute("showConfirmChange", true);
    }

    private void handleExecuteChange(HttpServletRequest request, HttpServletResponse response, HttpSession session, UUID oldReservationId) throws Failure, IOException {
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/signin");
            return;
        }

        // セッションから新しい予約情報を取得してReservationオブジェクトを生成
        Reservation newReservation = new Reservation();
        newReservation.setReservationId(UUID.randomUUID()); // 新しいIDを採番
        newReservation.setUserId(loginUser.getUserId());
        newReservation.setNumberOfPeople(Integer.parseInt((String) session.getAttribute("change_numberPeople")));
        newReservation.setReservationDate(LocalDate.parse((String) session.getAttribute("change_reservationDate")));
        newReservation.setStartTime(LocalTime.parse((String) session.getAttribute("change_startTime")));
        newReservation.setEndTime(LocalTime.parse((String) session.getAttribute("change_endTime")));
        newReservation.setReservationStatus("予約済み");
        
        List<String> selectedSeats = Arrays.asList(((String) session.getAttribute("change_selectedSeats")).split(","));
        setSeatsOnReservation(newReservation, selectedSeats);
        
        // トランザクション内で「新規作成」と「旧予約キャンセル」を実行
        ChangeReservation changeControl = new ChangeReservation();
        changeControl.execute(newReservation, oldReservationId);

        // 変更フロー用のセッション属性をクリーンアップ
        session.removeAttribute("change_numberPeople");
        session.removeAttribute("change_startTime");
        session.removeAttribute("change_endTime");
        session.removeAttribute("change_selectedSeats");
        session.removeAttribute("change_reservationDate");

        // メインの予約IDを新しいものに更新し、確認ページへリダイレクト
        session.setAttribute("reservationId", newReservation.getReservationId().toString());
        response.sendRedirect(request.getContextPath() + "/reservation-confirmed");
    }

    private void handleShowCancelConfirm(HttpServletRequest request, Reservation reservation) {
        setRequestAttributesFromReservation(request, reservation);
        request.setAttribute("view", "cancelConfirm");
    }

    private void handleExecuteCancel(HttpServletRequest request, HttpSession session) throws Failure {
        UUID reservationId = UUID.fromString((String) session.getAttribute("reservationId"));
        CancelReservation cancelControl = new CancelReservation();
        cancelControl.execute(reservationId);
        session.invalidate(); // キャンセル後はセッションを無効化
    }

    // --- ヘルパーメソッド ---
    private void setRequestAttributesFromReservation(HttpServletRequest request, Reservation r) {
        request.setAttribute("reservationId", r.getReservationId().toString());
        request.setAttribute("numberPeople", r.getNumberOfPeople());
        request.setAttribute("startTime", r.getStartTime().toString());
        request.setAttribute("endTime", r.getEndTime().toString());
        request.setAttribute("selectedSeats", String.join(", ", getSeatsFromReservation(r)));
    }

    private List<String> getSeatsFromReservation(Reservation r) {
        List<String> seats = new ArrayList<>();
        if (r.getSeat1() != null && !r.getSeat1().isEmpty()) seats.add(r.getSeat1());
        if (r.getSeat2() != null && !r.getSeat2().isEmpty()) seats.add(r.getSeat2());
        if (r.getSeat3() != null && !r.getSeat3().isEmpty()) seats.add(r.getSeat3());
        if (r.getSeat4() != null && !r.getSeat4().isEmpty()) seats.add(r.getSeat4());
        if (r.getSeat5() != null && !r.getSeat5().isEmpty()) seats.add(r.getSeat5());
        if (r.getSeat6() != null && !r.getSeat6().isEmpty()) seats.add(r.getSeat6());
        if (r.getSeat7() != null && !r.getSeat7().isEmpty()) seats.add(r.getSeat7());
        if (r.getSeat8() != null && !r.getSeat8().isEmpty()) seats.add(r.getSeat8());
        return seats;
    }

    private void setSeatsOnReservation(Reservation r, List<String> seats) {
        r.setSeat1(null); r.setSeat2(null); r.setSeat3(null); r.setSeat4(null);
        r.setSeat5(null); r.setSeat6(null); r.setSeat7(null); r.setSeat8(null);
        if (seats.size() > 0) r.setSeat1(seats.get(0));
        if (seats.size() > 1) r.setSeat2(seats.get(1));
        if (seats.size() > 2) r.setSeat3(seats.get(2));
        if (seats.size() > 3) r.setSeat4(seats.get(3));
        if (seats.size() > 4) r.setSeat5(seats.get(4));
        if (seats.size() > 5) r.setSeat6(seats.get(5));
        if (seats.size() > 6) r.setSeat7(seats.get(6));
        if (seats.size() > 7) r.setSeat8(seats.get(7));
    }
}