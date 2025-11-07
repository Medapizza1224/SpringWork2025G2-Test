package servlet.checkin;

// (import文は変更なし)
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collections;
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

import control.checkin.CheckinConfirmReservation;
import control.checkin.CheckinCreateReservation;
import control.checkin.CheckinCreateReservationResult;
import control.checkin.CheckinGetReservedSeats;
import dao.DaoException;
import dao.SeatManagementDao;
import entity.Reservation;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import modelUtil.Failure;


@WebServlet("/checkin-nonreserved")
public class CheckinNonreservationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        request.getSession().invalidate();
        request.setAttribute("step", "main");
        forwardToMainJsp(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        String step = request.getParameter("step");
        if (step == null) {
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
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "予期せぬエラーが発生しました: " + e.getMessage());
            request.setAttribute("step", "main");
            forwardToMainJsp(request, response);
        }
    }
    
    // (各ハンドラメソッドは変更なし、forward呼び出しのみ修正)
    private void handleTimeStep(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
        String numberPeople = request.getParameter("numberPeople");
        session.setAttribute("numberPeople", numberPeople);
        request.setAttribute("step", "time");
        forwardToMainJsp(request, response);
    }

    private void handleSeatStep(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException, Failure {
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        String numberPeople = request.getParameter("numberPeople");

        session.setAttribute("reservationDate", LocalDate.now().toString());
        String reservationDateStr = (String) session.getAttribute("reservationDate");
        
        session.setAttribute("startTime", startTimeStr);
        session.setAttribute("endTime", endTimeStr);
        session.setAttribute("numberPeople", numberPeople);
        
        CheckinGetReservedSeats getReservedSeatsControl = new CheckinGetReservedSeats();
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
        String numberPeopleStr = request.getParameter("numberPeople");
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        String selectedSeatsStr = request.getParameter("selectedSeats");
        String reservationDateStr = (String) session.getAttribute("reservationDate");
        
        if (numberPeopleStr == null || numberPeopleStr.isEmpty() ||
            startTimeStr == null || startTimeStr.isEmpty() ||
            endTimeStr == null || endTimeStr.isEmpty() ||
            selectedSeatsStr == null || selectedSeatsStr.isEmpty() ||
            reservationDateStr == null || reservationDateStr.isEmpty()) {
            
            request.setAttribute("errorMessage", "予約情報が不足しています。もう一度最初からやり直してください。");
            request.setAttribute("step", "main");
            forwardToMainJsp(request, response);
            return;
        }
        
        int numberPeople = Integer.parseInt(numberPeopleStr);
        LocalDate reservationDate = LocalDate.parse(reservationDateStr);
        LocalTime startTime = LocalTime.parse(startTimeStr);
        LocalTime endTime = LocalTime.parse(endTimeStr);
        List<String> selectedSeatsList = Arrays.asList(selectedSeatsStr.split(","));
        UUID userId = UUID.randomUUID();
        
        CheckinCreateReservation createReservation = new CheckinCreateReservation();
        CheckinCreateReservationResult result = createReservation.execute(userId, numberPeople, selectedSeatsList, reservationDate, startTime, endTime);
        Reservation reservation = result.reservation();

        session.setAttribute("provisionalReservationId", reservation.getReservationId());
        session.setAttribute("numberPeople", numberPeopleStr);
        session.setAttribute("startTime", startTimeStr);
        session.setAttribute("endTime", endTimeStr);
        session.setAttribute("selectedSeats", selectedSeatsStr);
        
        request.setAttribute("numberPeople", numberPeopleStr);
        request.setAttribute("startTime", startTimeStr);
        request.setAttribute("endTime", endTimeStr);
        request.setAttribute("selectedSeats", selectedSeatsStr);
        request.setAttribute("showConfirm", true);
        
        forwardToMainJsp(request, response);
    }

    private void handleConfirmReservation(HttpServletRequest request, HttpServletResponse response, HttpSession session) 
            throws ServletException, IOException, Failure {
        UUID reservationId = (UUID) session.getAttribute("provisionalReservationId");
        
        if (reservationId == null) {
            request.setAttribute("errorMessage", "予約セッションが無効です。最初からやり直してください。");
            request.setAttribute("step", "main");
            forwardToMainJsp(request, response);
            return;
        }

        try {
            CheckinConfirmReservation confirmReservationControl = new CheckinConfirmReservation();
            confirmReservationControl.execute(reservationId);
            
            SeatManagementDao dao = new SeatManagementDao();
            Reservation confirmedReservation = dao.getOneByReservationId(reservationId);

            String qrCodeBase64 = generateQrCode(reservationId.toString());
            
            request.setAttribute("successMessage", "予約が完了しました。");
            request.setAttribute("reservation", confirmedReservation);
            request.setAttribute("qrCodeBase64", qrCodeBase64);
            
            request.getRequestDispatcher("/WEB-INF/checkin/checkin-result-nonreserved.jsp").forward(request, response);

        } catch (DaoException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "データベース処理中にエラーが発生しました。");
            request.setAttribute("step", "main");
            forwardToMainJsp(request, response);
        }
    }

    private String generateQrCode(String data) {
        // (変更なし)
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

    /**
     * ▼▼▼ 修正点 ▼▼▼
     * JSPへフォワードする共通メソッド。
     * JSPに対して、フォームの送信先が自分自身であることを伝える。
     */
    private void forwardToMainJsp(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        // JSPにフォームの送信先URLを教える
        request.setAttribute("formAction", "/checkin-nonreserved");
        // JSPファイル名が異なる場合はこちらを修正してください
        request.getRequestDispatcher("/WEB-INF/checkin/checkin-nonreserved.jsp").forward(request, response);
    }
}