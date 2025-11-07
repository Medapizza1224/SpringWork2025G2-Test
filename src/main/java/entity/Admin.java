package entity;

import java.util.UUID;

// Failureクラスをインポートします。パッケージ名は環境に合わせて修正してください。
import modelUtil.Failure;

public class Admin {

    private UUID adminId;
    private String adminName;
    private String adminPassword;
    private String adminStatus;

    public Admin(UUID adminId, String adminName, String adminPassword, String adminStatus) throws Failure {
        // コンストラクタで各フィールドの値を検証
        checkAdminId(adminId);
        checkAdminName(adminName);
        checkAdminPassword(adminPassword);

        this.adminId = adminId;
        this.adminName = adminName;
        this.adminPassword = adminPassword;
        this.adminStatus = adminStatus;
    }

    public UUID getAdminId() {
        return adminId;
    }

    public void setAdminId(UUID adminId) throws Failure {
        checkAdminId(adminId);
        this.adminId = adminId;
    }

    public String getAdminName() {
        return adminName;
    }

    public void setAdminName(String adminName) throws Failure {
        checkAdminName(adminName);
        this.adminName = adminName;
    }

    public String getAdminPassword() {
        return adminPassword;
    }

    public void setAdminPassword(String adminPassword) throws Failure {
        checkAdminPassword(adminPassword);
        this.adminPassword = adminPassword;
    }

    public String getAdminStatus() {
        return adminStatus;
    }

    public void setAdminStatus(String adminStatus) {
        this.adminStatus = adminStatus;
    }

    /**
     * 管理者IDを検証します。
     * @param adminId 検証する管理者ID
     * @throws Failure IDがnullの場合
     */
    private void checkAdminId(UUID adminId) throws Failure {
        if (adminId == null) {
            throw new Failure("管理者IDはnullであってはいけません。");
        }
    }

    /**
     * 管理者名を検証します。
     * 文字数: 8文字以上64文字以下
     * 使用可能文字: 英数の大文字・小文字、日本語
     * @param adminName 検証する管理者名
     * @throws Failure 検証に失敗した場合
     */
    private void checkAdminName(String adminName) throws Failure {
        if (adminName == null || adminName.length() < 8 || adminName.length() > 64) {
            throw new Failure("管理者名は8文字以上64文字以下で入力してください。");
        }
        if (!adminName.matches("^[a-zA-Z0-9一-龠ぁ-んァ-ヶ々ー]+$")) {
            throw new Failure("管理者名には英数の大文字・小文字・日本語のみ使用できます。");
        }
    }

    /**
     * 管理者パスワードを検証します。
     * 文字数: 8文字以上32文字以下
     * 使用可能文字: 英数の大文字・小文字、日本語
     * @param adminPassword 検証する管理者パスワード
     * @throws Failure 検証に失敗した場合
     */
    private void checkAdminPassword(String adminPassword) throws Failure {
        if (adminPassword == null || adminPassword.length() < 8 || adminPassword.length() > 32) {
            throw new Failure("パスワードは8文字以上32文字以下で入力してください。");
        }
        if (!adminPassword.matches("^[a-zA-Z0-9一-龠ぁ-んァ-ヶ々ー]+$")) {
            throw new Failure("パスワードには英数の大文字・小文字・日本語のみ使用できます。");
        }
    }
}