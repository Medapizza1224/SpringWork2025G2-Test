package servlet.admin;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Collections;
import java.util.Map;

import control.admin.GetAdminDashboard;
import control.admin.GetAdminDashboardResult;
import control.admin.GetSeatStatus;
import entity.User; // ★★★ Userエンティティのインポートを追加 ★★★
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import modelUtil.Failure;

@WebServlet("/admin")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {

            
        
        // --- 門番ロジックを強化 ---
        HttpSession session = request.getSession(false); 
        User loginUser = null;

        // セッションが存在し、"loginUser"属性があればUserオブジェクトとして取得
        if (session != null && session.getAttribute("loginUser") != null) {
            loginUser = (User) session.getAttribute("loginUser");
        }

        // ▼▼▼ここから修正▼▼▼
        // ログインしていない、またはログインしているが管理者(Admin)ではない場合
        if (loginUser == null || !"Admin".equals(loginUser.getUserStatus())) {
            
            // セッションを（なければ）作成して、適切なエラーメッセージを詰める
            HttpSession newSession = request.getSession(true);
            if (loginUser == null) {
                newSession.setAttribute("error", "このページにアクセスするにはログインが必要です。");
            } else {
                newSession.setAttribute("error", "管理者権限がありません。");
            }
            
            // ログインページにリダイレクト
            response.sendRedirect(request.getContextPath() + "/admin-signin");
            return; // 処理を中断
        }
        // ▲▲▲ここまで修正▲▲▲
        
        // --- ログイン済みの管理者だけが以下の処理を実行できる ---
        try {
            // (以降の処理は変更なし)
            GetAdminDashboard adminDashboard = new GetAdminDashboard();
            GetAdminDashboardResult adminDashboardResult = adminDashboard.execute();
            
            request.setAttribute("userList", adminDashboardResult.userList());
            request.setAttribute("adminList", adminDashboardResult.adminList());
            request.setAttribute("reservationDtoList", adminDashboardResult.reservationDtoList());

            String dateStr = request.getParameter("date");
            String timeStr = request.getParameter("time");

            LocalDate date = (dateStr != null && !dateStr.isEmpty()) 
                                ? LocalDate.parse(dateStr) 
                                : LocalDate.now();
            
            Map<String, String> seatStatusMap;

            if (timeStr != null && !timeStr.isEmpty()) {
                LocalTime time = LocalTime.parse(timeStr);
                GetSeatStatus seatStatusControl = new GetSeatStatus();
                seatStatusMap = seatStatusControl.execute(date, time);
                request.setAttribute("selectedTime", timeStr);
            } else {
                seatStatusMap = Collections.emptyMap();
            }

            request.setAttribute("seatStatusMap", seatStatusMap);
            
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            request.setAttribute("currentDate", date.format(formatter));

        } catch (Failure | DateTimeParseException e) {
            request.setAttribute("error", "データの取得中にエラーが発生しました: " + e.getMessage());
            e.printStackTrace();
        }

        request.getRequestDispatcher("/WEB-INF/admin/admin-home.jsp").forward(request, response);
    }
}