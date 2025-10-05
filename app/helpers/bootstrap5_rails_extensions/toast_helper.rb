module Bootstrap5RailsExtensions
  module ToastHelper
    # コンテナだけを描画（右上固定）。この時点ではStimulusは起動しない。
    # レイアウトで <%= render_toast %> を配置しておき、表示時は turbo_stream.toast で要素を差し込む。
    FLASH_TOAST_COLORS = {
      notice: :success,
      alert: :danger,
      error: :danger,
      warning: :warning,
      info: :info,
      success: :success
    }.freeze

    def render_toast(id: "toast-root", position: "top-0 end-0", flash_messages: nil)
      flash_nodes = build_flash_toasts(flash_messages)
      content_tag(:div, safe_join(flash_nodes), id: id, class: "toast-container position-fixed #{position} p-3")
    end

    private

    def build_flash_toasts(flash_messages)
      return [] unless flash_messages.respond_to?(:each)

      flash_messages.each_with_object([]) do |(type, messages), nodes|
        color = FLASH_TOAST_COLORS[type.to_sym] || :secondary
        Array(messages).each do |message|
          nodes << render(partial: "bootstrap5_rails_extensions/toast",
                          locals: { msg: { text: message, color: color } })
        end
      end
    end
  end
end
