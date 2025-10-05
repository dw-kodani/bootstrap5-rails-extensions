module Bootstrap5RailsExtensions
  module OffcanvasHelper
    # Renders a Bootstrap 5.3 Offcanvas using a shared partial. Works with Stimulus/Turbo.
    #
    # TODO: The host app currently coordinates opening Offcanvas + Turbo Frame
    # loads via custom `data-offcanvas-*` attributes handled in a Stimulus controller.
    # Consider standardizing this interface (e.g., provide a helper to render trigger
    # links that play nicely with Turbo without introducing custom attributes) or
    # embracing Bootstrap's data API by adding a reliable integration layer.
    # This is a compromise and should be revisited.
    #
    # Example:
    #   <%= render_offcanvas id: "exampleOffcanvas", title: "プレビュー" do %>
    #     <turbo-frame id="offcanvas-frame">...</turbo-frame>
    #   <% end %>
    #   # もしくはタイトルを第1引数で指定（render_modalと同様のインタフェース）
    #   <%= render_offcanvas "プレビュー", id: "exampleOffcanvas" do %>
    #     ...
    #   <% end %>
    #
    # Options:
    #   placement: :start|:end|:top|:bottom (default: :end)
    #   footer: String/HTML or -> { ... } (Proc)
    #   data:   additional data-* for the offcanvas root (controller "offcanvas" added by default)
    #
    # 引数:
    #   - render_offcanvas id: "...", title: "..." do ... end
    #   - render_offcanvas "タイトル", id: "..." do ... end
    def render_offcanvas(title_or_nil = nil, id: nil, title: nil, placement: :end, footer: nil, data: {}, &block)
      # ブロック必須
      raise ArgumentError, "block required for offcanvas body" unless block_given?

      # 2つの呼び出しシグネチャに対応
      title ||= title_or_nil if title.nil? && title_or_nil.is_a?(String)
      raise ArgumentError, "id is required" if id.nil? || id.to_s.empty?
      raise ArgumentError, "title is required" if title.nil? || title.to_s.empty?

      placement_class = case placement.to_s
      when "start" then "offcanvas-start"
      when "end" then "offcanvas-end"
      when "top" then "offcanvas-top"
      when "bottom" then "offcanvas-bottom"
      else "offcanvas-end"
      end

      # Stimulusコントローラをデフォルト付与（上書きも許可）
      offcanvas_data = { controller: "offcanvas" }.merge(data || {})

      body_html = capture(&block)
      footer_html = if footer.respond_to?(:call)
        capture(&footer)
      else
        footer
      end

      render partial: "bootstrap5_rails_extensions/offcanvas",
             locals: {
               id: id,
               title: title,
               placement_class: placement_class,
               body: body_html,
               footer: footer_html,
               data: offcanvas_data
             }
    end
  end
end
