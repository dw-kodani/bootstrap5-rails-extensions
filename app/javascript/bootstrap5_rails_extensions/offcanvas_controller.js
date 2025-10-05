import { Controller } from "@hotwired/stimulus"
import { Offcanvas } from "bootstrap"

// Stimulusコントローラー（Bootstrap.Offcanvasの薄いラッパー）
//
// 目的:
// - 任意のトリガークリックで「オフキャンバスを開く + Turbo FrameへURLを読み込む」を同時に行う
// 契約:
// - トリガー属性：
//     data-offcanvas-target="#offcanvasId"  // 開きたいOffcanvasのセレクタ（必須）
//     data-turbo-frame="frameId"            // Turbo FrameのID（指定時はTurboに任せて読み込み）
//     href                                   // 読み込むURL（任意。未指定ならフレーム読み込みはスキップ）
// 備考:
// - Bootstrapのdata APIと競合させないため、documentのcapture段階で先取りして手動でshow()する

export default class extends Controller {

  connect() {
    this.offcanvas = Offcanvas.getOrCreateInstance(this.element)

    // 委譲クリックでオープン＋Frame読み込み
    this.handleDelegatedClick = (event) => {
      const trigger = event.target?.closest?.('[data-offcanvas-target]')
      if (!trigger) return

      // 修飾クリック等はスキップ
      if (event.defaultPrevented || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return

      const targetSelector = trigger.getAttribute('data-offcanvas-target')
      if (!targetSelector) return

      const targetEl = document.querySelector(targetSelector)
      if (!targetEl) return
      // 自分のOffcanvas以外宛は無視
      if (targetEl !== this.element) return

      // 開く
      this.offcanvas.show()
    }
    document.addEventListener('click', this.handleDelegatedClick, true)

  }

  disconnect() {
    document.removeEventListener('click', this.handleDelegatedClick, true)
    if (this.offcanvas) {
      this.offcanvas.hide()
      this.offcanvas.dispose()
      this.offcanvas = null
    }
  }

  open() { this.offcanvas?.show() }
  hide(event) { 
    // Turboイベント以外（クリックなど detail が number）のケースはそのまま閉じる
    if (!event?.detail || typeof event.detail === 'number') {
      this.modal?.hide()
      return
    }
  }
  toggle() { this.offcanvas?.toggle() }
}
