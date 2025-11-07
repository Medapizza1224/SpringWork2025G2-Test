package servlet.login;

import java.io.IOException;
import java.util.Map; // Mapのインポートを追加

import control.login.AdminSignin;
import control.login.AdminSigninResult;
import control.login.AdminSignup;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import modelUtil.Failure;

@WebServlet(value = { "/admin-signup" })
public class AdminSignupServlet extends HttpServlet {

  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 新規登録ページを表示
        req.getRequestDispatcher("/WEB-INF/login/admin-signup.jsp").forward(req, resp);
    }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

    req.setCharacterEncoding("UTF-8");

    String id = req.getParameter("id").trim();
    String password = req.getParameter("password");
    String securityCode = req.getParameter("security_code");

    try {
            // 1. 新規登録処理を実行
            AdminSignup signupControl = new AdminSignup();
            // ▼▼▼エラー修正①: 変数名を signupControl に修正▼▼▼
            signupControl.execute(id, password, securityCode);

            // 2. 登録した情報でログイン処理を行い、完全なUserオブジェクトを取得する
            AdminSignin adminSigninControl = new AdminSignin();
            // ▼▼▼エラー修正②: ログインにはsecurityCodeは不要なため、引数から削除▼▼▼
            AdminSigninResult adminSigninResult = adminSigninControl.execute(id, password);
            User loginUser = adminSigninResult.user();

            // 3. セッションを取得
            HttpSession session = req.getSession();

            // 4. Userオブジェクトをセッションに保存する
            session.setAttribute("loginUser", loginUser);

            // 5. リダイレクト後のページで表示したいメッセージをセッションに保存
            session.setAttribute("successMessage", "新規登録が完了しました。");

            // 6. 予約サイトにリダイレクト
            resp.sendRedirect(req.getContextPath() + "/admin");

        } catch (Failure failure) {

            failure.printStackTrace();
            req.setAttribute("error", failure.getMessage());
            
            // ★★★ 改善 ★★★
            // 失敗時にユーザー名が消えないように入力値を画面に戻す
            req.setAttribute("lastInput", Map.of("id", id));

            // 新規登録ページ
            req.getRequestDispatcher("/WEB-INF/login/admin-signup.jsp").forward(req, resp);
        }
  }
}