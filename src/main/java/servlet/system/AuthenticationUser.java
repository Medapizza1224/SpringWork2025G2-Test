package servlet.system; // パッケージ名はご自身のプロジェクトに合わせてください

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * ログイン認証を確認するためのフィルタ。
 * /reservation/* へのアクセスを監視し、未ログインであればログインページにリダイレクトする。
 */
@WebFilter("/reservation/*") // "/reservation"で始まるすべてのURLリクエストを監視
public class AuthenticationUser implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        // HTTPリクエストとレスポンスにキャスト
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // セッションを取得 (存在しない場合は null が返る)
        HttpSession session = httpRequest.getSession(false);

        // セッションが存在しない、または "loginUser" 属性が存在しない場合 (未ログイン状態)
        if (session == null || session.getAttribute("loginUser") == null) {
            // ログインページにリダイレクトさせる
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/signin");
            return; // 処理を中断
        }
        
        // ログイン済みの場合、本来のリクエスト処理を続行
        chain.doFilter(request, response);
    }

    // init() と destroy() はこの場合、特に実装は不要です
}