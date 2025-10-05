# Bootstrap5 Rails Extensions（Rails Engine）

RailsアプリケーションでBootstrap 5をTurbo/Stimulusと併用しやすくするための拡張を提供します。モーダルやオフキャンバス、カード、テーブル、トースト向けのDSLヘルパーと、対応するStimulusコントローラを同梱しています。

## インストール

Gemfile（ホストアプリ）:

```ruby
gem "bootstrap5-rails-extensions"
```

`bundle install` を実行してください。

## セットアップ

### Stimulusコントローラの登録

Importmapをご利用の場合は、エンジンが提供するコントローラ群をpinしてください。

```ruby
# config/importmap.rb
pin_all_from "bootstrap5_rails_extensions", under: "bootstrap5_rails_extensions"
```

Stimulusアプリケーションへの登録例です。

```javascript
// app/javascript/controllers/index.js
import { application } from "./application"
import { registerBootstrap5Controllers } from "bootstrap5_rails_extensions"

registerBootstrap5Controllers(application)
```

オプションで`registerBootstrap5Controllers`の第2引数に`{ modal: CustomModalController }`のようなハッシュを渡すと、任意のコントローラーで上書きを行えます。ESBuildやViteなどのバンドラをご利用の場合も同様に読み込んでください。

個別に登録したい場合は、従来どおり各コントローラーをインポートした上で`application.register`を呼び出してください。

### トースト用コンテナの設置

レイアウトなど、常に描画されるテンプレートに以下を追加しておくと、Turbo Stream経由でトーストを流し込めます。

```erb
<%= render_toast %>
```

フラッシュメッセージを初期表示したい場合は `render_toast(flash_messages: flash)` のように渡してください。

## ビューヘルパー

### render_modal

Stripeダッシュボード風のモーダルDSLです。`render_modal` にIDとタイトルを渡し、ブロックで本文・フッターを組み立てます。

```erb
<%= render_modal id: "settingsModal", title: "設定", dialog: { size: :lg, centered: true } do |modal| %>
  <% modal.body do %>
    <turbo-frame id="modal-settings-frame">
      <div class="text-center text-muted py-4">読み込み中...</div>
    </turbo-frame>
  <% end %>
<% end %>
```

フォームを扱う場合は `form:` に `form_with` のオプションをそのまま渡してください。`modal.body` / `modal.footer` のブロックにはフォームビルダーが渡されます。

```erb
<%= render_modal id: "userModal", title: "ユーザー追加", form: { model: User.new, url: users_path } do |modal| %>
  <% modal.body do |f| %>
    <%= f.text_field :name, class: "form-control" %>
  <% end %>
  <% modal.footer do |f| %>
    <%= f.submit "保存", class: "btn btn-primary" %>
  <% end %>
<% end %>
```

モーダルを開くトリガー要素には、Stimulusコントローラが参照する属性を付与します。

```erb
<%= link_to settings_path,
      class: "btn btn-primary btn-sm",
      data: { modal_target: "#settingsModal", turbo_frame: "modal-settings-frame" } do %>
  設定を開く
<% end %>
```

主なオプションです。

- `dialog: { size: :sm|:lg|:xl|:fullscreen, centered: true, scrollable: true }`
- `form:` `form_with` に渡すHash。指定時はブロックにフォームビルダーが渡されます。
- `data:` モーダル要素に付与するdata属性（`controller: "modal"` は自動付与されます）。

### render_offcanvas

Bootstrap 5.3のオフキャンバスをDSLで構築します。タイトルは第1引数またはキーワード引数で指定できます。

```erb
<%= render_offcanvas id: "previewOffcanvas", title: "プレビュー", placement: :end do %>
  <turbo-frame id="offcanvas-form-template-preview">
    読み込み中...
  </turbo-frame>
<% end %>
```

トリガー例:

```erb
<%= link_to preview_path,
      class: "btn btn-outline-primary btn-sm",
      data: { offcanvas_target: "#previewOffcanvas", turbo_frame: "offcanvas-form-template-preview" } do %>
  プレビュー
<% end %>
```

- `placement:` は `:start|:end|:top|:bottom` を受け付けます（既定は`:end`）。
- `footer:` に文字列またはブロックを渡すと、フッター領域を描画します。
- `data:` で追加のdata属性を渡せます（`controller: "offcanvas"` を自動付与します）。

### render_card

カードを簡潔に定義できるDSLです。ヘッダー、本文、フッターを1度ずつ定義できます。

```erb
<%= render_card class: "mb-4" do |card| %>
  <% card.header class: "d-flex align-items-center" do %>
    設定
  <% end %>
  <% card.body class: "p-4" do %>
    本文...
  <% end %>
  <% card.footer class: "text-end" do %>
    <%= link_to "閉じる", "#", class: "btn btn-outline-secondary" %>
  <% end %>
<% end %>
```

`data:` オプションで親要素にdata属性を追加できます。

### render_table

`table-responsive` ラッパー付きでBootstrapのテーブルを出力します。

```erb
<%= render_table class: "table-striped" do |table| %>
  <% table.thead class: "table-light" do %>
    <tr><th>名前</th><th>状態</th></tr>
  <% end %>
  <% table.tbody do %>
    <% @users.each do |user| %>
      <tr>
        <td><%= user.name %></td>
        <td><%= user.status %></td>
      </tr>
    <% end %>
  <% end %>
<% end %>
```

`wrapper_class` や `wrapper_html` を渡すことでラッパー要素のカスタマイズも可能です。

### render_toast

トーストコンテナを描画し、フラッシュメッセージを初期表示できます。

```erb
<%= render_toast id: "toast-root", position: "top-0 end-0", flash_messages: flash %>
```

`position:` にはBootstrapのユーティリティクラスをそのまま渡してください。

## Turbo Streams拡張

`Turbo::Streams::TagBuilder` を拡張し、`turbo_stream.toast` を利用できるようにしています。トーストコンテナ（既定ID: `toast-root`）にメッセージを積み上げます。

```ruby
# コントローラまたはビュー
render turbo_stream: turbo_stream.toast(:notice, "保存しました")

# 追加オプション
render turbo_stream: turbo_stream.toast(:alert, @user, target: "custom-toast", autohide: false, delay: 8000)
```

`message_or_record` にActiveModelを渡すと、エラー内容をリスト表示します。

---

ご不明点があればIssueやPull Requestでお気軽にお知らせください。
