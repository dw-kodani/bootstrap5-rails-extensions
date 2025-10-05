# Bootstrap5 Rails Extensions（Rails Engine）

Railsアプリ向けに、Bootstrap 5のUIをRailsと相性よく使うための拡張を提供するエンジンです。Stimulus/Turboにフレンドリーな`render_modal`ヘルパー（共有パーシャル）などを含みます。

## インストール（path gem）

Gemfile（ホストアプリ）:

```ruby
gem "bootstrap5-rails-extensions", path: "vendor/engines/bootstrap5_rails_extensions"
```

その後 `bundle install` を実行します。

## 使い方（Modal）

まず、アプリ側でBootstrapのJSを読み込み、`modal`というStimulusコントローラ（本エンジン同梱）を有効化してください。

モーダルの器を置く:

```erb
<%= render_modal id: "settingsModal", title: "設定", dialog: { size: :lg, centered: true } do |modal| %>
  <% modal.body do %>
    <turbo-frame id="modal-settings-frame">
      <div class="text-center text-muted py-4">読み込み中...</div>
    </turbo-frame>
  <% end %>
<% end %>
```

フォームを含めたい場合:

```erb
<%= render_modal id: "userModal", title: "ユーザー追加",
    form: { model: User.new, url: users_path } do |modal| %>
  <% modal.body do |f| %>
    <%= f.text_field :name, class: "form-control" %>
  <% end %>
  <% modal.footer do |f| %>
    <%= f.submit "保存", class: "btn btn-primary" %>
  <% end %>
<% end %>
```

トリガー（クリックで開いてTurbo Frameに読み込む）:

```erb
<%= link_to settings_path,
      class: "btn btn-primary btn-sm",
      data: { modal_target: "#settingsModal", turbo_frame: "modal-settings-frame" } do %>
  設定を開く
<% end %>
```

属性（トリガー側）:

- `data-modal-target`: 開くモーダルのセレクタ（例: `#settingsModal`）
- `data-turbo-frame`: 読み込む先のTurbo Frame ID（例: `modal-settings-frame`）
- `href`: 読み込むURL（Turbo Frameへ流し込むURL）

`modal.body`で定義した内容は自動的に`<div class="modal-body">`でラップされます。Turbo Frameを設置する場合はブロック内にそのまま記述してください。

注意:

- Bootstrapの`data-bs-toggle`とは併用しません。内部で`Modal.show()`とFrame読み込みを順序制御します。
- モーダルを閉じたとき、内包の`turbo-frame`の`src`はクリアされ、次回は再読み込みされます。

## 使い方（Offcanvas）

オフキャンバスの器を置く:

```erb
<%= render_offcanvas id: "previewOffcanvas", title: "プレビュー", placement: :end do %>
  <turbo-frame id="offcanvas-form-template-preview">
    読み込み中...
  </turbo-frame>
<% end %>
```

トリガー（クリックで開いてTurbo Frameに読み込む）:

```erb
<%= link_to preview_path,
      class: "btn btn-outline-primary btn-sm",
      data: { offcanvas_target: "#previewOffcanvas", turbo_frame: "offcanvas-form-template-preview" } do %>
  プレビュー
<% end %>

属性（トリガー側）:

- `data-offcanvas-target`: 開くOffcanvasのセレクタ（例: `#previewOffcanvas`）
- `data-turbo-frame`: 読み込む先のTurbo Frame ID（例: `offcanvas-form-template-preview`）
- `href`: 読み込むURL（Turbo Frameへ流し込むURL）

Offcanvas本体の`offcanvas-body`直下にも、必要に応じて手動で`<turbo-frame>`を配置してください。
```

## オプション

- `dialog: { size: :sm|:lg|:xl|:fullscreen, centered: true, scrollable: true }`
- `form:` `form_with`に渡すHash。指定時は`modal.body`/`modal.footer`ブロックにフォームビルダーが渡される。
- `data:` 追加のdata属性（`controller: "modal"` は自動付与）

## CSSユーティリティ

- `dropdown-caret-none`: Bootstrapのドロップダウンの山形（caret）を非表示にするユーティリティ
  - 適用例:

    ```erb
    <!-- トグルに直接適用 -->
    <button class="btn btn-sm btn-outline-secondary dropdown-toggle dropdown-caret-none" data-bs-toggle="dropdown">Actions</button>

    <!-- 親要素に適用 -->
    <div class="dropdown dropdown-caret-none">
      <button class="btn btn-sm btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown">Actions</button>
    </div>
    ```

  - normal/dropup/dropend（`::after`）とdropstart（`::before`）に対応
  - 取り込み例（例: `application.bootstrap.scss`）:

    ```scss
    @import "bootstrap/scss/bootstrap";
    @import "bootstrap5_rails_extensions/utilities"; // .dropdown-caret-none を提供
    ```
