# Unhandy for Happiness

SNSや動画サイトへの依存に悩む方を支援するWebアプリケーション

[![Ruby](https://img.shields.io/badge/Ruby-3.2.0-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-7.1.5-red.svg)](https://rubyonrails.org/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)
[![Docker](https://img.shields.io/badge/Docker-latest-blue.svg)](https://www.docker.com/)

---

## 📖 目次

- [デモ](#デモ)
- [概要](#概要)
- [ターゲット層](#ターゲット層)
- [主な機能](#主な機能)
- [使用技術](#使用技術)
- [工夫した点](#工夫した点)
- [今後の改善点](#今後の改善点)
- [ローカル環境での起動方法](#ローカル環境での起動方法)
- [デプロイ方法](#デプロイ方法)
- [運用方法](#運用方法)
- [トラブルシューティング](#トラブルシューティング)

---

## 🌐 デモ

**デモURL:** [http://52.68.23.100:3000](http://52.68.23.100:3000)

> **注意:** 現在HTTP接続です。HTTPS化は今後実装予定です。

---

## 📌 概要

**Unhandy for Happiness**は、SNSや動画投稿サイトへの依存に悩むユーザーを支援するWebアプリケーションです。

ユーザーが自ら質問文を作成し、YouTubeやInstagramにアクセスする前に自己内省を促すことで、自己肯定感を保ちながら学習に集中できる環境を提供します。

### 開発目的

- SNSや動画投稿サイトへの依存に悩むユーザーを支援する
- ユーザーが自ら質問文を作ることで、自らを律し、自己肯定感を高めながら学習に取り組めるようにする
- 他人に否定されたり注意されることなく、自己管理能力を育成する

---

## 🎯 ターゲット層

- 勉強したくても、ついついSNSや動画投稿サイトを見て時間を浪費してしまう人
- 発達障害など、生来特性により長時間学習したり集中することが難しい人
- SNSや動画投稿サイトをつい長時間見てしまい、不眠や生活リズムをコントロールできない人
- 学習に集中できる時間や環境をどうすれば確保できるか分からずに悩んでいる人

---

## ✨ 主な機能

### 1. ユーザー認証機能（Devise）
- 新規登録・ログイン・ログアウト
- パスワードリセット機能（メール送信は今後実装予定）

### 2. 質問管理機能
- 最低5つの質問を作成（初期設定）
- 最大20項目まで質問を追加可能
- 質問の編集・削除（5つ未満には減らせない）
- 3種類の質問タイプ：
  - 自由記述
  - はい/いいえ
  - 数値入力

### 3. Chrome拡張機能連携
- YouTubeやInstagramへのアクセスを自動的にリダイレクト
- ユーザーが作成した質問に回答するまでアクセスを制限
- 全ての質問に回答後、10秒後にアクセス可能

### 4. アクセス制御
- ブラウザ拡張機能（unhandy_redirector）により、特定のサイトへのアクセスを管理
- 質問への回答を完了するまで、対象サイトへのアクセスをブロック

---

## 🛠️ 使用技術

### バックエンド
- **Ruby** 3.2.0
- **Ruby on Rails** 7.1.5.2
- **MySQL** 8.0
- **Devise** - ユーザー認証

### フロントエンド
- **Stimulus.js** - JavaScriptフレームワーク
- **Turbo** - SPA風の高速ページ遷移
- **Importmap** - JavaScript管理

### インフラ・デプロイ
- **Docker** - コンテナ化
- **AWS EC2** - Ubuntu 24.04 LTS
- **Puma** - Webサーバー

### ブラウザ拡張機能
- **Chrome Extension Manifest V3**
- **WebNavigation API**

### 開発ツール
- **Git / GitHub** - バージョン管理
- **GitHub Desktop** - Git操作
- **WSL2** - Windows開発環境

---

## 💡 工夫した点

### 1. Dockerによるコンテナ化
- 開発環境と本番環境の差異を最小化
- 環境構築の手間を削減
- 再現性の高いデプロイを実現

### 2. セキュリティの基本を徹底
- APIキーや秘密情報を環境変数化（`.env`ファイルは`.gitignore`で除外）
- データベースのパスワードを環境変数で管理
- `SECRET_KEY_BASE`をコマンドラインで生成・管理

### 3. 自動起動設定
- `docker run --restart always`により、EC2再起動時も自動的にアプリケーションが起動
- 運用の手間を削減

### 4. Chrome拡張機能との連携
- Manifest V3に対応した最新の実装
- WebNavigation APIを使用した確実なリダイレクト処理
- 無限ループを防ぐためのパラメータチェック

### 5. ユーザー体験の向上
- 自己内省を促す質問システム
- 段階的なアクセス許可（5つの質問 → 10秒待機 → アクセス許可）
- 質問のカスタマイズ性（3種類の質問タイプ）

---

## 📚 デプロイで学んだこと

このプロジェクトでは、初めてのAWS EC2へのデプロイに挑戦しました。その過程で多くのエラーに遭遇しましたが、それぞれが貴重な学びとなりました。

### 遭遇した主なエラーと解決

#### 1. SSH接続タイムアウト
**問題**: Wi-Fi変更により自分のIPアドレスが変わり、EC2に接続できなくなった  
**学び**: 動的IPアドレスの理解、AWSセキュリティグループの設定方法

#### 2. ファイル実行権限エラー
**問題**: `bin/docker-entrypoint`に実行権限がなくコンテナが起動しない  
**学び**: Linuxのパーミッション（chmod）、Dockerイメージはビルド時の状態を含む

#### 3. SECRET_KEY_BASE不足
**問題**: 本番環境でRailsの秘密鍵が設定されていない  
**学び**: 開発環境と本番環境の設定の違い、環境変数での機密情報管理

#### 4. データベース認証エラー（最も難解）
**問題**: MySQL 8.0の認証方式とRailsの互換性問題  
**学び**: バージョン間の互換性の重要性、`mysql_native_password`と`caching_sha2_password`の違い

#### 5. パスワードポリシー違反
**問題**: 単純なパスワードがMySQLのセキュリティポリシーで拒否された  
**学び**: 本番環境でのセキュリティ要件、強固なパスワードの必要性

### 習得したスキル

**技術面**
- Dockerの実践的な使用（イメージビルド、コンテナ管理、環境変数）
- Linuxサーバー管理（SSH接続、ファイル権限、systemctl）
- MySQLのユーザー管理と認証方式の理解
- AWS EC2とセキュリティグループの基本操作

**問題解決面**
- **層別思考**: 問題をネットワーク層・コンテナ層・アプリケーション層・DB層に分けて切り分ける
- **ログの活用**: `docker logs`で必ず原因を確認する習慣
- **「なぜ？」を大切にする**: 動いたからOKではなく、なぜ動いたのか理解する
- **ドキュメント化**: エラーと解決方法を記録し、次回に活かす

### 詳細なデプロイストーリー

デプロイの詳細な記録は、`docs/private/DEPLOYMENT_STORY.md`に記載しています。  
面接での技術説明の参考として、以下の内容を含んでいます：

- 各エラーの詳細な原因分析
- 思考プロセスと解決手順
- 学んだ技術的知識
- 今後の改善計画

---

## 🚀 今後の改善点

### セキュリティ
- [ ] HTTPS対応（Let's EncryptでSSL証明書取得）
- [ ] メール送信機能の実装（SendGrid または AWS SES）
- [ ] より強固なパスワードポリシー

### インフラ
- [ ] docker-composeでの管理
- [ ] CI/CDパイプラインの構築（GitHub Actions）
- [ ] 独自ドメインの取得
- [ ] Nginxをリバースプロキシとして導入

### 機能
- [ ] 質問の公開・共有機能（ハッシュタグ検索）
- [ ] 統計情報の表示（アクセス履歴、回答履歴）
- [ ] 複数ブラウザ対応（Firefox、Edge）

### コード品質
- [ ] テストコードの充実（RSpec、Capybara）
- [ ] ER図の作成
- [ ] APIドキュメントの整備

---

## 🖥️ ローカル環境での起動方法

### 前提条件
- Ruby 3.2.0
- MySQL 8.0
- Node.js（Importmap使用のため）

### 手順

1. **リポジトリをクローン**
```bash
git clone https://github.com/your-username/unhandy_for_happiness.git  🔧 [要変更: your-usernameを実際のGitHubユーザー名に変更]
cd unhandy_for_happiness
```

2. **依存関係をインストール**
```bash
bundle install
```

3. **データベースの設定**
```bash
# MySQLにログイン
sudo mysql

# データベースとユーザーを作成
CREATE DATABASE unhandy_for_happiness_development;
CREATE USER 'root'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON unhandy_for_happiness_development.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# マイグレーション実行
bin/rails db:migrate
```

4. **サーバーを起動**
```bash
bin/rails server
```

5. **ブラウザでアクセス**
```
http://localhost:3000
```

---

## 🚢 デプロイ方法

### AWS EC2へのデプロイ手順

デプロイは**6つのPhase**に分けて進めます。各Phaseにチェックリストがあり、確実にデプロイできるようになっています。

詳細なチェックリストは`docs/private/DEPLOYMENT_NOTES.md`を参照してください。

---

### Phase 0: デプロイ前の準備

#### ローカル環境でのコード準備
```bash
# セキュリティチェック（最重要）
cat .gitignore | grep -E "\.env|docs/private|master.key"
# 上記3つが除外されていることを確認

# GitHubにPush
git add .
git commit -m "デプロイ準備完了"
git push origin main
```

#### サーバーの準備確認
- EC2インスタンスが「running」状態
- セキュリティグループでHTTP（ポート3000）とSSH（ポート22）を開放
- 現在のIPアドレスを確認（`curl ifconfig.me`）

#### データベースの準備確認
- MySQLが起動している
- データベース、ユーザー、権限が設定済み
- 認証方式が`mysql_native_password`

---

### Phase 1: サーバーへの接続

```bash
# 現在のIPアドレスを確認
curl ifconfig.me

# 必要に応じてAWSセキュリティグループのSSHルールを更新

# SSH接続
ssh -i ~/.ssh/your-key.pem ubuntu@<EC2-IP>
```

---

### Phase 2: コードの取得と準備

```bash
# アプリディレクトリに移動
cd ~/apps/unhandy_for_happiness

# 最新コードを取得
git pull origin main

# 実行権限を確認・付与
ls -la bin/docker-entrypoint
chmod +x bin/docker-entrypoint
```

---

### Phase 3: Dockerイメージのビルド

```bash
# ディスク容量を確認
df -h

# イメージをビルド
docker build -t unhandy-for-happiness:latest .

# ビルド成功を確認
docker images | grep unhandy-for-happiness
```

---

### Phase 4: コンテナの起動

```bash
# 既存コンテナを削除
docker rm -f unhandy-for-happiness

# 環境変数を準備（SECRETS.mdを参照）
# 新しいコンテナを起動
docker run -d \
  --name unhandy-for-happiness \
  --network host \
  --restart always \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=<SECRETS.mdから> \
  -e UNHANDY_FOR_HAPPINESS_DATABASE_PASSWORD='<SECRETS.mdから>' \
  unhandy-for-happiness:latest
```

---

### Phase 5: 動作確認

```bash
# コンテナが起動しているか確認
docker ps

# ログを確認
docker logs -f unhandy-for-happiness
# "Listening on tcp://0.0.0.0:3000" が表示されればOK
# Ctrl+C で終了

# ブラウザでアクセス
# http://<EC2-IP>:3000
```

---

### Phase 6: トラブルシューティング（5段階）

エラーが発生した場合、以下の順序で確認します：

**Level 1: 接続確認**
- EC2インスタンスの状態
- セキュリティグループの設定
- SSH接続テスト

**Level 2: Docker確認**
- Dockerサービスの状態（`sudo systemctl status docker`）
- コンテナの状態（`docker ps -a`）
- ログの確認（`docker logs`）

**Level 3: アプリケーション確認**
- 環境変数の設定（`docker inspect`）
- ファイル権限（`ls -la bin/`）
- Railsログ（`docker exec ... tail log/production.log`）

**Level 4: データベース確認**
- MySQLの起動状態（`sudo systemctl status mysql`）
- ユーザーと認証方式（`SELECT user, host, plugin FROM mysql.user`）
- 権限の確認（`SHOW GRANTS`）

**Level 5: ネットワーク確認**
- ポートの開放（`netstat -tuln | grep 3000`）
- ファイアウォール設定（`sudo ufw status`）
- `--network host`の確認

詳細は`docs/private/DEPLOYMENT_NOTES.md`を参照してください。

---

### 🔄 デプロイワークフロー

このプロジェクトでは、環境の不整合を防ぐため、以下のワークフローを徹底しています：

```
ローカル環境で修正
    ↓
動作確認
    ↓
GitHub Desktop でPush
    ↓
GitHub経由でデプロイ完了を確認
    ↓
EC2にSSH接続
    ↓
git pull で最新コードを取得
    ↓
Dockerイメージを再ビルド
    ↓
コンテナを起動
    ↓
動作確認
```

**このワークフローを守ることで**：
- すべての変更がGitで管理される
- 本番環境で直接コードを編集しない
- 「ローカルでは動くのに本番で動かない」を防げる
- バージョン管理が徹底される

---

### 従来のデプロイ手順（参考）

#### 1. EC2インスタンスの準備
- Ubuntu 24.04 LTS
- Elastic IPの設定
- セキュリティグループの設定：
  - HTTP: ポート3000（または80）を`0.0.0.0/0`に開放
  - HTTPS: ポート443を`0.0.0.0/0`に開放（今後のため）
  - SSH: ポート22を自分のIPに制限

#### 2. サーバーにSSH接続
```bash
ssh -i ~/.ssh/your-key.pem ubuntu@<EC2-IP>
```

#### 3. 必要なソフトウェアのインストール
```bash
# Dockerのインストール
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# MySQLのインストール
sudo apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

#### 4. リポジトリをクローン
```bash
cd ~
mkdir apps
cd apps
git clone https://github.com/your-username/unhandy_for_happiness.git  🔧 [要変更: your-usernameを実際のGitHubユーザー名に変更]
cd unhandy_for_happiness
```

#### 5. データベースの設定
```bash
sudo mysql

CREATE DATABASE IF NOT EXISTS unhandy_for_happiness_production;
CREATE USER IF NOT EXISTS 'unhandy_for_happiness'@'localhost' IDENTIFIED WITH mysql_native_password BY 'YourSecurePassword123!';
GRANT ALL PRIVILEGES ON unhandy_for_happiness_production.* TO 'unhandy_for_happiness'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### 6. Dockerイメージをビルド
```bash
# 実行権限を確認
chmod +x bin/docker-entrypoint

# ビルド
docker build -t unhandy-for-happiness:latest .
```

#### 7. SECRET_KEY_BASEを生成
```bash
docker run --rm unhandy-for-happiness:latest bin/rails secret
# 出力された文字列をコピー
```

#### 8. コンテナを起動
```bash
docker run -d \
  --name unhandy-for-happiness \
  --network host \
  --restart always \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=<生成した文字列> \
  -e UNHANDY_FOR_HAPPINESS_DATABASE_PASSWORD='YourSecurePassword123!' \
  unhandy-for-happiness:latest
```

#### 9. 動作確認
```bash
# コンテナの状態確認
docker ps

# ログ確認
docker logs unhandy-for-happiness

# ブラウザでアクセス
# http://<EC2-IP>:3000
```

---

## 🔧 運用方法

### EC2インスタンスを停止→再起動した場合

1. AWSマネジメントコンソールにログイン
2. EC2ダッシュボードでインスタンスを選択
3. 「インスタンスの状態」→「インスタンスを開始」
4. 数分待つ
5. ブラウザでアクセス（自動的にアプリが起動しています）

> **注意:** `--restart always`を設定しているため、手動でDockerコンテナを起動する必要はありません。

---

### Wi-Fiを変更した場合（IPアドレスが変わった）

**アプリへのアクセス:**
- 何も設定変更不要。そのままアクセス可能です。

**SSH接続が必要な場合:**

1. **新しいIPアドレスを確認**
```bash
curl ifconfig.me
```

2. **AWSセキュリティグループを更新**
   - EC2ダッシュボード → セキュリティグループ
   - 該当のセキュリティグループを選択
   - 「インバウンドルール」→「インバウンドルールを編集」
   - SSHルール（ポート22）のソースを新しいIPに変更
   - または「マイIP」を選択（自動で現在のIPが入力される）

3. **SSH接続**
```bash
ssh -i ~/.ssh/your-key.pem ubuntu@<EC2-IP>
```

---

### コンテナの再起動が必要な場合

```bash
# SSH接続後
docker restart unhandy-for-happiness

# ログ確認
docker logs -f unhandy-for-happiness
```

---

### 最新のコードをデプロイする場合

```bash
# SSH接続後
cd ~/apps/unhandy_for_happiness

# 最新のコードを取得
git pull origin main

# 実行権限を確認
chmod +x bin/docker-entrypoint

# 既存のコンテナを削除
docker rm -f unhandy-for-happiness

# イメージを再ビルド
docker build -t unhandy-for-happiness:latest .

# コンテナを起動
docker run -d \
  --name unhandy-for-happiness \
  --network host \
  --restart always \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=<SECRET_KEY_BASE> \
  -e UNHANDY_FOR_HAPPINESS_DATABASE_PASSWORD='<PASSWORD>' \
  unhandy-for-happiness:latest
```

---

## 🔍 トラブルシューティング

### ブラウザで「接続が拒否されました」と表示される

**原因1: EC2インスタンスが停止している**
- AWSコンソールでインスタンスの状態を確認
- 停止している場合は起動

**原因2: Dockerコンテナが停止している**
```bash
# SSH接続後
docker ps  # 起動中のコンテナを確認

# もし表示されない場合
docker ps -a  # すべてのコンテナを確認
docker start unhandy-for-happiness  # コンテナを起動
```

**原因3: セキュリティグループでポート3000が開いていない**
- AWSコンソールでセキュリティグループを確認
- HTTPポート3000を`0.0.0.0/0`に開放

---

### SSH接続で「Connection timed out」が発生する

**原因: IPアドレスが変わっている**

1. 現在のIPアドレスを確認
```bash
curl ifconfig.me
```

2. AWSコンソールでセキュリティグループのSSHルールを更新
   - ソースを新しいIPアドレスに変更

---

### データベース接続エラーが発生する

**エラーメッセージ例:**
```
Access denied for user 'unhandy_for_happiness'@'localhost'
```

**対処法:**

1. MySQLが起動しているか確認
```bash
sudo systemctl status mysql
```

2. データベースユーザーと権限を確認
```bash
sudo mysql
SELECT user, host FROM mysql.user WHERE user='unhandy_for_happiness';
SHOW GRANTS FOR 'unhandy_for_happiness'@'localhost';
EXIT;
```

3. 必要に応じてユーザーを再作成
```sql
DROP USER IF EXISTS 'unhandy_for_happiness'@'localhost';
CREATE USER 'unhandy_for_happiness'@'localhost' IDENTIFIED WITH mysql_native_password BY 'YourPassword123!';
GRANT ALL PRIVILEGES ON unhandy_for_happiness_production.* TO 'unhandy_for_happiness'@'localhost';
FLUSH PRIVILEGES;
```

4. Dockerコンテナを正しいパスワードで再起動

---

### SECRET_KEY_BASEエラーが発生する

**エラーメッセージ:**
```
Missing `secret_key_base` for 'production' environment
```

**対処法:**

1. SECRET_KEY_BASEを生成
```bash
docker run --rm unhandy-for-happiness:latest bin/rails secret
```

2. コンテナ起動時に環境変数として渡す
```bash
-e SECRET_KEY_BASE=<生成された文字列>
```

---

### ファイルの実行権限エラー

**エラーメッセージ:**
```
permission denied: /rails/bin/docker-entrypoint
```

**対処法:**
```bash
chmod +x bin/docker-entrypoint
# 再ビルドが必要
docker build -t unhandy-for-happiness:latest .
```

---

## 📞 お問い合わせ

プロジェクトに関するご質問やフィードバックは、GitHubのIssueでお願いします。

---

## 📄 ライセンス

このプロジェクトはMITライセンスのもとで公開されています。

---

## 👤 作成者

**あなたの名前** 🔧 [要変更: 実際の名前に変更]
- GitHub: [@your-username](https://github.com/your-username) 🔧 [要変更: your-usernameを実際のGitHubユーザー名に変更]
- Email: your-email@example.com 🔧 [要変更: 実際のメールアドレスに変更]

---

**最終更新日:** 2025年12月19日

