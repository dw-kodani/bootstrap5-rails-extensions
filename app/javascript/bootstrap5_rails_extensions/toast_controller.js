import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

// 単一トースト要素用のシンプルなコントローラー
// 要素自体（.toast）がターゲット。接続時に即showする。
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 4000 },
    autohide: { type: Boolean, default: true },
  }

  connect() {
    this.toast = Toast.getOrCreateInstance(this.element, {
      autohide: this.autohideValue,
      delay: this.delayValue,
    })
    this.toast.show()

    // Turboキャッシュ前に破棄
    this.beforeCache = () => {
      try { this.toast?.hide(); this.toast?.dispose() } catch (_) {}
    }
    document.addEventListener("turbo:before-cache", this.beforeCache)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.beforeCache)
    try { this.toast?.hide(); this.toast?.dispose() } catch (_) {}
    this.toast = null
  }
}
