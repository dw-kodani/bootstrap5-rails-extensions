module Bootstrap5RailsExtensions
  # Turbo::Streams::TagBuilder へ toast(level, text, ...) を追加する拡張
  #
  # 使い方（コントローラ/ビュー共通）:
  #   render turbo_stream: turbo_stream.toast(:notice, "保存しました")
  #   render turbo_stream: [ turbo_stream.replace(@record), turbo_stream.toast(:alert, "エラー", autohide: false) ]
  module TurboStreamToast
    # トーストを右上コンテナに積む
    # level: :notice | :alert | :error | :warning | :info
    def toast(level, message_or_record, target: "toast-root", autohide: true, delay: 4000)
      color = case level.to_sym
              when :notice then :success
              when :alert, :error then :danger
              when :warning then :warning
              when :info then :info
              else :secondary
              end
      text = normalize_toast_text(message_or_record)
      html = @view_context.render(partial: "bootstrap5_rails_extensions/toast",
                                  locals: { msg: { text: text, color: color }, autohide: autohide, delay: delay })
      append(target, html)
    end

    private

    def normalize_toast_text(value)
      return value if value.is_a?(ActiveSupport::SafeBuffer)
      return value if value.is_a?(String) || value.nil?

      if value.respond_to?(:errors)
        errors = value.errors
        if errors.respond_to?(:any?) && errors.any?
          items = errors.full_messages.map { |message| @view_context.content_tag(:li, message) }
          return @view_context.content_tag(:ul, @view_context.safe_join(items), class: "mb-0 ps-4")
        end
      end

      value
    end
  end
end

