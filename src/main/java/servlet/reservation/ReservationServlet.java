package servlet.reservation;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import control.reservation.ChangeReservation;
import control.reservation.ConfirmReservation;
import control.reservation.CreateReservation;
import control.reservation.CreateReservationResult;
import control.reservation.GetReservedSeats;
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

@WebServlet("/reservation")
public class ReservationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String mode = request.getParameter("mode");
        String reservationIdToChangeStr = request.getParameter("reservationId");

        // ▼▼▼ 変更点 ▼▼▼
        // "変更モード"でアクセスされた場合の処理
        if ("change".equals(mode) && reservationIdToChangeStr != null) {
            session.setAttribute("isChangeMode", true);
            session.setAttribute("reservationIdToChange", reservationIdToChangeStr);
            // 以前の予約情報が残っている可能性があるのでクリアする
            session.removeAttribute("provisionalReservationId");
            session.removeAttribute("numberPeople");
            session.removeAttribute("startTime");
            session.removeAttribute("endTime");
            session.setAttribute("selectedSeats", ""); // 座席選択画面でエラーが出ないように空文字をセット
            session.removeAttribute("reservationDate");
        } else {
            // 通常の新規予約の場合
            initializeNewReservation(session);
        }
        
        request.setAttribute("step", "main");
        forwardToMainJsp(request, response);
    }
    
    private void initializeNewReservation(HttpSession session) {
        // ▼▼▼ 変更点 ▼▼▼
        // セッションをクリアする際に、変更モードのフラグもクリアする
        session.removeAttribute("isChangeMode");
        session.removeAttribute("reservationIdToChange");
        session.removeAttribute("provisionalReservationId");
        session.removeAttribute("numberPeople");
        session.removeAttribute("startTime");
        session.removeAttribute("endTime");
        session.removeAttribute("selectedSeats");
        session.removeAttribute("reservationDate");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        String step = request.getParameter("step");
        if (step == null || step.isEmpty()) {
            step = "main";
        }

        try {
            switch (step) {
                case "time":
                    handleTimeStep(request, response, session);
                    break;
                case "seat":
                    handleSeatStep(request, response, session);
                    break;
                case "provisional":
                    handleProvisionalReservation(request, response, session);
                    break;
                case "confirm":
                    handleConfirmReservation(request, response, session);
                    break;
                default:
                    request.setAttribute("step", "main");
                    forwardToMainJsp(request, response);
            }
        } catch (Failure f) {
            f.printStackTrace();
            request.setAttribute("errorMessage", "エラーが発生しました: " + f.getMessage());
            request.setAttribute("step", "main");
            forwardToMainJsp(request, response);
        } 
        catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "予期せぬエラーが発生しました。");
            request.setAttribute("step", "main");
            forwardToMainJsp(request, response);
        }
    }
    
    private void handleTimeStep(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
        String numberPeople = request.getParameter("numberPeople");
        session.setAttribute("numberPeople", numberPeople);
        request.setAttribute("step", "time");
        forwardToMainJsp(request, response);
    }
    
    private void handleSeatStep(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException, Failure {
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        
        ZoneId tokyoZone = ZoneId.of("Asia/Tokyo");
        String reservationDateStr = LocalDate.now(tokyoZone).toString();
        
        session.setAttribute("reservationDate", reservationDateStr);
        session.setAttribute("startTime", startTimeStr);
        session.setAttribute("endTime", endTimeStr);
        
        GetReservedSeats getReservedSeatsControl = new GetReservedSeats();
        List<String> reservedSeats = getReservedSeatsControl.execute(
                LocalDate.parse(reservationDateStr),
                LocalTime.parse(startTimeStr),
                LocalTime.parse(endTimeStr)
        );
        request.setAttribute("reservedSeats", reservedSeats);
        request.setAttribute("step", "seat");
        forwardToMainJsp(request, response);
    }
    
    private void handleProvisionalReservation(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException, Failure {
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/signin");
            return;
        }

        session.setAttribute("numberPeople", request.getParameter("numberPeople"));
        session.setAttribute("startTime", request.getParameter("startTime"));
        session.setAttribute("endTime", request.getParameter("endTime"));
        session.setAttribute("selectedSeats", request.getParameter("selectedSeats"));

        Boolean isChangeMode = (Boolean) session.getAttribute("isChangeMode");

        // ▼▼▼ 変更点 ▼▼▼
        // 「変更モード」ではない、通常の新規予約の場合のみ仮予約をDBに作成する
        if (!Boolean.TRUE.equals(isChangeMode)) {
            String numberPeopleStr = request.getParameter("numberPeople");
            String startTimeStr = request.getParameter("startTime");
            String endTimeStr = request.getParameter("endTime");
            String selectedSeatsStr = request.getParameter("selectedSeats");
            String reservationDateStr = (String) session.getAttribute("reservationDate");
            
            int numberPeople = Integer.parseInt(numberPeopleStr);
            LocalDate reservationDate = LocalDate.parse(reservationDateStr);
            LocalTime startTime = LocalTime.parse(startTimeStr);
            LocalTime endTime = LocalTime.parse(endTimeStr);
            List<String> selectedSeatsList = Arrays.asList(selectedSeatsStr.split(","));
            UUID userId = loginUser.getUserId();
            
            CreateReservation createReservation = new CreateReservation();
            CreateReservationResult result = createReservation.execute(userId, numberPeople, selectedSeatsList, reservationDate, startTime, endTime);
            Reservation reservation = result.reservation();

            session.setAttribute("provisionalReservationId", reservation.getReservationId());
        }
        
        request.setAttribute("showConfirm", true); 
        request.setAttribute("step", "main"); 
        forwardToMainJsp(request, response);
    }
    
    private void handleConfirmReservation(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException, Failure {
        Boolean isChangeMode = (Boolean) session.getAttribute("isChangeMode");
        User loginUser = (User) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/signin");
            return;
        }

        // ▼▼▼ 変更点 ▼▼▼
        if (Boolean.TRUE.equals(isChangeMode)) {
            // --- 予約変更フロー ---
            String oldReservationIdStr = (String) session.getAttribute("reservationIdToChange");
            if (oldReservationIdStr == null) throw new IllegalStateException("変更対象の予約IDが見つかりません。");
            
            UUID oldReservationId = UUID.fromString(oldReservationIdStr);
            
            // セッションから新しい予約情報を組み立てる
            Reservation newReservation = new Reservation();
            newReservation.setReservationId(UUID.randomUUID());
            newReservation.setUserId(loginUser.getUserId());
            newReservation.setNumberOfPeople(Integer.parseInt((String) session.getAttribute("numberPeople")));
            newReservation.setReservationDate(LocalDate.parse((String) session.getAttribute("reservationDate")));
            newReservation.setStartTime(LocalTime.parse((String) session.getAttribute("startTime")));
            newReservation.setEndTime(LocalTime.parse((String) session.getAttribute("endTime")));
            newReservation.setReservationStatus("予約済み");
            
            List<String> selectedSeats = Arrays.asList(((String) session.getAttribute("selectedSeats")).split(","));
            setSeatsOnReservation(newReservation, selectedSeats);
            
            // トランザクション内で「新規作成」と「旧予約キャンセル」を実行
            ChangeReservation changeControl = new ChangeReservation();
            changeControl.execute(newReservation, oldReservationId);

            // 完了後、新しい予約IDでQRコードを生成し、確認画面へ
            String qrCodeBase64 = generateQrCode(newReservation.getReservationId().toString());
            session.setAttribute("qrCodeBase64", qrCodeBase64);
            session.setAttribute("reservationId", newReservation.getReservationId().toString());

            // 変更モード関連のセッション情報をクリーンアップ
            session.removeAttribute("isChangeMode");
            session.removeAttribute("reservationIdToChange");
            
            response.sendRedirect(request.getContextPath() + "/reservation-confirmed");

        } else {
            // --- 通常の新規予約フロー ---
            UUID finalReservationId = (UUID) session.getAttribute("provisionalReservationId");
            if (finalReservationId == null) throw new IllegalStateException("仮予約情報が見つかりません。");
            
            ConfirmReservation confirmReservationControl = new ConfirmReservation();
            confirmReservationControl.execute(finalReservationId);
            
            String qrCodeBase64 = generateQrCode(finalReservationId.toString());
            session.setAttribute("qrCodeBase64", qrCodeBase64);
            session.setAttribute("reservationId", finalReservationId.toString());
            response.sendRedirect(request.getContextPath() + "/reservation-confirmed");
        }
    }

    private String generateQrCode(String data) {
        try {
            Map<EncodeHintType, Object> hints = new EnumMap<>(EncodeHintType.class);
            hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M);
            hints.put(EncodeHintType.MARGIN, 2);
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(data, BarcodeFormat.QR_CODE, 250, 250, hints);
            ByteArrayOutputStream pngOutputStream = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(bitMatrix, "PNG", pngOutputStream);
            byte[] pngData = pngOutputStream.toByteArray();
            return Base64.getEncoder().encodeToString(pngData);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private void forwardToMainJsp(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        request.setAttribute("formAction", "/reservation"); 
        request.getRequestDispatcher("/WEB-INF/reservation/SeatReservation.jsp").forward(request, response);
    }

    // ▼▼▼ 追加: 予約オブジェクトに座席をセットするヘルパーメソッド ▼▼▼
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