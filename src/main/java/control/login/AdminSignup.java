package control.login;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;

import dao.DaoException;
import dao.UserDao;
import entity.User;
import modelUtil.Failure;

public class AdminSignup {

    private static final String CORRECT_SECURITY_CODE_HASH = "2fc288f5416272a37967dd26ddb8779b221d28c0d7e10c51e42bf32e247502e3";

    public AdminSignupResult execute(String userName, String password, String securityCode) throws Failure {

        if (userName == null || userName.isBlank() || password == null || password.isBlank()) {
            throw new Failure("ID、パスワードは必須項目です。");
        }

        if (securityCode == null || securityCode.isBlank()) {
            throw new Failure("セキュリティコードが正しくありません。");
        }

        String trimmedSecurityCode = securityCode.trim(); // 空白を除去したものを変数に入れる
        String inputSecurityCodeHash = toSha256(trimmedSecurityCode);

        System.out.println("入力されたコード(トリム後): [" + trimmedSecurityCode + "]");
        System.out.println("生成されたハッシュ: " + inputSecurityCodeHash);
        System.out.println("期待されるハッシュ: " + CORRECT_SECURITY_CODE_HASH);
        
        
        if (!CORRECT_SECURITY_CODE_HASH.equals(inputSecurityCodeHash)) {
            throw new Failure("セキュリティコードが正しくありません。");
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
            String userStatus = "Admin";

            User newUser;
            try {
                newUser = new User(userId, userName, password, secretQuestion, secretQuestionAnswer, userStatus);
            } catch (Failure e) {
                // エンティティのバリデーションエラーをFailureとしてスロー
                throw new Failure("入力値が不正です: " + e.getMessage(), e);
            }

            userDao.createOne(newUser);

            AdminSignupResult result = new AdminSignupResult(newUser);
            return result;
        

        } catch (DaoException | Failure daoException) {
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

    /**
     * 文字列をSHA-256ハッシュ値（16進数文字列）に変換します。
     * @param text ハッシュ化する文字列
     * @return ハッシュ化された文字列
     */
    private String toSha256(String text) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(text.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            // SHA-256はJavaの標準アルゴリズムのため、通常この例外は発生しません。
            throw new RuntimeException("SHA-256 algorithm not found.", e);
        }
    }
}