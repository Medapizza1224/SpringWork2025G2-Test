package servlet.system;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;


/**
 * ログアウト処理を行うサーブレット
 */
@WebServlet("/admin-logout")
public class AdminLogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 現在のセッションを取得する (存在しない場合は新規作成しない)
        HttpSession session = request.getSession(false);

        if (session != null) {
            // 2. セッションを無効化する
            session.invalidate(); //
        }

        // 3. ログインページにリダイレクトする
        //    リダイレクト先のURLは実際のログインページのパスに合わせて変更してください。
        response.sendRedirect(request.getContextPath() + "/admin-signin"); 
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}