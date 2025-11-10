package entity;

import java.util.UUID;

import modelUtil.Failure;

public class User {

    private UUID userId;
    private String userName;
    private String userPassword;
    private String secretQuestion;
    private String secretQuestionAnswer;
    private String userStatus;

    public User(UUID userId, String userName, String userPassword, String secretQuestion, String secretQuestionAnswer, String userStatus) throws Failure {
        // すべてのフィールドに対してチェックを実行
        checkUserId(userId);
        checkUserName(userName);
        checkPassword(userPassword);
        checkSecretQuestion(secretQuestion);
        checkSecretQuestionAnswer(secretQuestionAnswer);

        this.userId = userId;
        this.userName = userName;
        this.userPassword = userPassword;
        this.secretQuestion = secretQuestion;
        this.secretQuestionAnswer = secretQuestionAnswer;
        this.userStatus = userStatus;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) throws Failure {
        checkUserId(userId);
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) throws Failure {
        checkUserName(userName);
        this.userName = userName;
    }

    public String getUserPassword() {
        return userPassword;
    }

    public void setUserPassword(String userPassword) throws Failure {
        checkPassword(userPassword);
        this.userPassword = userPassword;
    }

    public String getSecretQuestion() {
        return secretQuestion;
    }

    public void setSecretQuestion(String secretQuestion) throws Failure {
        checkSecretQuestion(secretQuestion);
        this.secretQuestion = secretQuestion;
    }

    public String getSecretQuestionAnswer() {
        return secretQuestionAnswer;
    }

    public void setSecretQuestionAnswer(String secretQuestionAnswer) throws Failure {
        checkSecretQuestionAnswer(secretQuestionAnswer);
        this.secretQuestionAnswer = secretQuestionAnswer;
    }

    public String getUserStatus() {
        return userStatus;
    }

    public void setUserStatus(String userStatus) {
        this.userStatus = userStatus;
    }

    /**
     * ユーザーIDを検証します。
     * @param userId 検証するユーザーID
     * @throws Failure 検証に失敗した場合
     */
    private void checkUserId(UUID userId) throws Failure {
        if (userId == null) {
            throw new Failure("ユーザーIDはnullであってはいけません。");
        }
    }

    /**
     * ユーザー名を検証します。
     * 文字数: 1文字以上64文字以下 (8文字から緩和)
     * 使用可能文字: 英数の大文字・小文字、日本語、全角数字
     * @param userName 検証するユーザー名
     * @throws Failure 検証に失敗した場合
     */
    private void checkUserName(String userName) throws Failure {
        // 文字数チェック (8文字以上64文字以下)
        if (userName.length() < 8 || userName.length() > 64) {
            throw new Failure("ユーザー名は8文字以上64文字以下で入力してください。");
        }
        
        // ▼▼▼【変更点】使用可能文字のチェック（半角英数字のみか）▼▼▼
        // 文字列全体が半角の英字(a-z, A-Z)と数字(0-9)のみで構成されているかを確認
        if (!userName.matches("^[a-zA-Z0-9]+$")) {
            throw new Failure("ユーザー名には、半角の英字と数字のみ使用できます。");
        }
    }

    /**
     * パスワードを検証します。
     * (DBから読み込む際はハッシュ化されているため、null/空チェックのみで変更なし)
     * @param password 検証するパスワード
     * @throws Failure 検証に失敗した場合
     */
    private void checkPassword(String password) throws Failure {
        if (password == null || password.isEmpty()) {
            throw new Failure("パスワードは必須項目です。");
        }
    }

    /**
     * 秘密の質問を検証します。
     * 文字数: 1文字以上64文字以下 (8文字から緩和)
     * 使用可能文字: 英数の大文字・小文字、日本語、記号「？」を許容
     * @param secretQuestion 検証する秘密の質問
     * @throws Failure 検証に失敗した場合
     */
    private void checkSecretQuestion(String secretQuestion) throws Failure {
        // 質問が空の場合はチェックしない（変更なし）
        if (secretQuestion == null || secretQuestion.isEmpty()) {
            return;
        }
        // ▼▼▼ 変更点3: 文字数の下限を8から1に変更 ▼▼▼
        if (secretQuestion.length() < 1 || secretQuestion.length() > 64) {
            throw new Failure("秘密の質問は1文字以上64文字以下で入力してください。");
        }
        // ▼▼▼ 変更点4: 半角・全角の「？」を許容するように正規表現を修正 ▼▼▼
        if (!secretQuestion.matches("^[a-zA-Z0-9一-龠ぁ-んァ-ヶ々ー?？]+$")) {
            throw new Failure("秘密の質問に使用できない文字が含まれています。");
        }
    }

    /**
     * 秘密の質問の回答を検証します。
     * 文字数: 1文字以上64文字以下 (8文字から緩和)
     * 使用可能文字: 英数の大文字・小文字、日本語
     * @param answer 検証する秘密の質問の回答
     * @throws Failure 検証に失敗した場合
     */
    private void checkSecretQuestionAnswer(String answer) throws Failure {
        // 質問自体が設定されていなければ、回答のチェックも不要
        if (this.secretQuestion == null || this.secretQuestion.isEmpty()) {
            return;
        }
        // ▼▼▼ 変更点5: 文字数の下限を8から1に変更 ▼▼▼
        if (answer == null || answer.length() < 1 || answer.length() > 64) {
            throw new Failure("秘密の質問の回答は1文字以上64文字以下で入力してください。");
        }
        if (!answer.matches("^[a-zA-Z0-9一-龠ぁ-んァ-ヶ々ー]+$")) {
            throw new Failure("秘密の質問の回答には英数の大文字・小文字・日本語のみ使用できます。");
        }
    }
}