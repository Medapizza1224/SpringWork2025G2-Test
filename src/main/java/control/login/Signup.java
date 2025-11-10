package control.login;

import java.util.UUID;

import dao.DaoException;
import dao.UserDao;
import entity.User;
import modelUtil.Failure;

public class Signup {

    public SignupResult execute(String userName, String password) throws Failure {

        if (userName == null || userName.isBlank() || password == null || password.isBlank()) {
            throw new Failure("ID、パスワードは必須項目です。");
        }

        checkUserName(userName);
        checkPassword(password);

        try {
            UserDao userDao = new UserDao();

            // IDの重複チェック
            if (userDao.getOneByUserName(userName) != null) {
                throw new Failure("このIDは既に使用されています。");
            }

            UUID userId = UUID.randomUUID();

            // Userオブジェクトの生成
            String secretQuestion = "";
            String secretQuestionAnswer = "";
            String userStatus = "Guest";

            User newUser = new User(userId, userName, password, secretQuestion, secretQuestionAnswer, userStatus);

            userDao.createOne(newUser);

            SignupResult result = new SignupResult(newUser);
            return result;
        

        } catch (DaoException daoException) {
            throw new Failure("データベース処理中にエラーが発生しました。", daoException);
        }
    }

    private void checkUserName(String userName) throws Failure {
        // 文字数チェック (8文字以上64文字以下)
        if (userName.length() < 8 || userName.length() > 64) {
            throw new Failure("パスワードは8文字以上64文字以下で入力してください。");
        }
        
        // ▼▼▼【変更点】使用可能文字のチェック（半角英数字のみか）▼▼▼
        // 文字列全体が半角の英字(a-z, A-Z)と数字(0-9)のみで構成されているかを確認
        if (!userName.matches("^[a-zA-Z0-9]+$")) {
            throw new Failure("パスワードには、半角の英字と数字のみ使用できます。");
        }
    }

    /**
     * パスワードのバリデーションを行います。
     * - 文字数: 8文字以上64文字以下
     * - 文字種: 英大文字、英小文字、数字をそれぞれ1文字以上含む
     * - 使用可能文字: 半角英数記号
     * @param password 検証するパスワード
     * @throws Failure 検証に失敗した場合
     */
    private void checkPassword(String password) throws Failure {
        // 文字数チェック (8文字以上64文字以下)
        if (password.length() < 8 || password.length() > 64) {
            throw new Failure("パスワードは8文字以上64文字以下で入力してください。");
        }
        
        // ▼▼▼【変更点】使用可能文字のチェック（半角英数字のみか）▼▼▼
        // 文字列全体が半角の英字(a-z, A-Z)と数字(0-9)のみで構成されているかを確認
        if (!password.matches("^[a-zA-Z0-9]+$")) {
            throw new Failure("パスワードには、半角の英字と数字のみ使用できます。");
        }
    }
}