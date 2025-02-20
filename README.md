# EduConnect-frontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## サブモジュール管理手順

<details>
<summary>Cloudflare Worker サブモジュール管理手順</summary>

このプロジェクトでは、Cloudflare Worker を **Git Submodule** として管理しています。  
以下の手順で `cloudflare` フォルダを独立したリポジトリとして管理し、メインプロジェクトと連携しています。

## **🛠 1. Cloudflare Worker 用リポジトリを作成**
Cloudflare Worker のコードを独立したリポジトリに管理する場合、以下の手順で作成します。

```sh
# cloudflare フォルダ内で Git リポジトリを初期化
cd cloudflare
git init

# GitHub または GitLab にリモートリポジトリを作成し、登録
git remote add origin https://github.com/your-org/cloudflare-worker.git

# 初回コミットとプッシュ
git add .
git commit -m "Initial commit for Cloudflare Worker"
git push -u origin main
```

---

## **💌 2. メインプロジェクトにサブモジュールとして追加**
メインプロジェクトに `cloudflare` を **サブモジュール** として登録するには、以下を実行します。

```sh
cd your-main-project

# サブモジュールとして Cloudflare Worker リポジトリを追加
git submodule add https://github.com/your-org/cloudflare-worker.git cloudflare

# 変更をコミット
git commit -m "Added Cloudflare Worker as submodule"
```

---

## **🔄 3. サブモジュールのクローン方法**
メインプロジェクトを **最初にクローン** する際、以下のコマンドでサブモジュールも同時に取得できます。

```sh
git clone --recurse-submodules https://github.com/your-org/main-project.git
```

もし、通常の `git clone` を実行してしまった場合は、以下のコマンドでサブモジュールを取得できます。

```sh
git submodule update --init --recursive
```

---

## **🚀 4. サブモジュールの更新**
### **Cloudflare Worker 側の変更をメインプロジェクトに反映**
Cloudflare Worker 側のリポジトリに **更新があった場合**、メインプロジェクトで以下を実行します。

```sh
cd cloudflare

# 最新の変更を取得
git pull origin main

cd ..

# メインプロジェクトに変更を反映
git add cloudflare
git commit -m "Update Cloudflare Worker submodule"
git push origin main
```

---

## **📄 5. Cloudflare Worker 側の変更をプッシュ**
Cloudflare Worker に **直接変更を加えた場合** は、通常の Git コマンドで push できます。

```sh
cd cloudflare

# 変更をコミット & プッシュ
git add .
git commit -m "Updated Cloudflare Worker"
git push origin main
```

</details>
