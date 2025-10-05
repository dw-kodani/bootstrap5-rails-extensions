import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

// Stimulusコントローラー（Bootstrap.Modalの薄いラッパー）
//
// 目的:
// - 画面上の任意のトリガーで、モーダルのオープンとTurbo Frameの読み込みを同時に制御する
// 契約:
// - トリガー属性：
//     data-modal-target="#modalId"         // 開きたいモーダルのセレクタ（必須）
//     data-turbo-frame="frameId"           // Turbo FrameのID（指定時はTurboに任せて読み込み）
//     href                                 // 読み込むURL（任意。未指定ならフレーム読み込みはスキップ）
// 備考:
// - Bootstrapのdata APIと競合させないため、documentのcapture段階で先取りして手動でshow()する
export default class extends Controller {
  static targets = ["form"]

  connect() {
    // この要素自身のモーダルインスタンスを確保
    this.modal = Modal.getOrCreateInstance(this.element)

    // 委譲クリックでモーダルを開き、必要ならFrameへ読み込み
    // data-modal-target が付いた要素のクリックをフック
    this.handleDelegatedClick = (event) => {
      const trigger = event.target?.closest?.('[data-modal-target]')
      if (!trigger) return

      // 修飾クリックや既に処理済みはスキップ
      if (event.defaultPrevented || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return

      const targetSelector = trigger.getAttribute('data-modal-target')
      if (!targetSelector) return

      const targetEl = document.querySelector(targetSelector)
      if (!targetEl) return
      // 自身が対象モーダルでなければ無視（複数モーダルが同時に存在する場合の重複実行を防止）
      if (targetEl !== this.element) return

      // モーダルをプログラムで開く
      this.modal.show()
    }
    // captureでBootstrapのdata APIより先に処理する
    document.addEventListener('click', this.handleDelegatedClick, true)

  }

  disconnect() {
    document.removeEventListener('click', this.handleDelegatedClick, true)
    if (this.modal) {
      this.modal.hide()
      this.modal.dispose()
      this.modal = null
    }
  }

  // 手動制御用のアクション
  open() { this.modal?.show() }
  hide(event) {
    // Turboイベント以外（クリックなど detail が number）のケースはそのまま閉じる
    if (!event?.detail || typeof event.detail === 'number') {
      this.modal?.hide()
      return
    }

    // Turbo submit で失敗 (422) した場合のみ閉じない
    if (event.detail.success === false) return

    this.modal?.hide()
  }
  toggle() { this.modal?.toggle() }

  formSubmit(event) {
    event?.preventDefault()

    const form = this.hasFormTarget ? this.formTarget : this.element.querySelector("form")

    if (!form) {
      console.warn("[modal] フォームが見つかりませんでした。")
      return
    }

    if (typeof form.requestSubmit === "function") {
      form.requestSubmit()
    } else {
      form.submit()
    }
  }
}
