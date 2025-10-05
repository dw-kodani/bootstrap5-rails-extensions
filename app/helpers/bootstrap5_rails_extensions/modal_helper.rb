# typed: false
# frozen_string_literal: true

module Bootstrap5RailsExtensions
  module ModalHelper
    # Stripeダッシュボードを意識したBootstrap 5.3モーダルのDSLを提供するヘルパー。
    #
    # 使い方:
    #   <%= render_modal id: "exampleModal", title: "タイトル" do |modal| %>
    #     <% modal.body do %>
    #       本文...
    #     <% end %>
    #   <% end %>
    #
    # フォームを1枚で扱う場合:
    #   <%= render_modal id: "userModal", title: "ユーザー追加",
    #       form: { model: User.new, url: users_path } do |modal| %>
    #     <% modal.body do |f| %>
    #       <%= f.text_field :name %>
    #     <% end %>
    #     <% modal.footer do |f| %>
    #       <%= f.submit "保存" %>
    #     <% end %>
    #   <% end %>
    #
    # オプション:
    #   dialog: { size: :sm|:lg|:xl|:fullscreen, centered: true/false, scrollable: true/false }
    #   data:   data-*属性をマージ（controller: "modal" をデフォルト付与）
    #   form:   form_withにそのまま渡すオプション(Hash)。指定時はブロックにフォームビルダーを渡す。
    def render_modal(title_or_nil = nil, id: nil, title: nil, dialog: {}, data: {}, form: nil, &block)
      raise ArgumentError, _("モーダルにはブロックが必要です") unless block_given?

      title ||= title_or_nil if title.nil? && title_or_nil.is_a?(String)
      raise ArgumentError, _("モーダルIDを指定してください") if id.nil? || id.to_s.empty?
      raise ArgumentError, _("モーダルタイトルを指定してください") if title.nil? || title.to_s.empty?

      dialog_classes = ["modal-dialog"]
      case dialog[:size]&.to_sym
      when :sm then dialog_classes << "modal-sm"
      when :lg then dialog_classes << "modal-lg"
      when :xl then dialog_classes << "modal-xl"
      when :fullscreen then dialog_classes << "modal-fullscreen"
      end
      dialog_classes << "modal-dialog-centered" if dialog[:centered]
      dialog_classes << "modal-dialog-scrollable" if dialog[:scrollable]

      modal_data = { controller: "modal" }.merge(data || {})

      builder = ModalBuilder.new(self, modal_id: id, default_title: title)

      content_markup = if form.present?
        form_options = form.to_h.symbolize_keys
        capture do
          form_with(**form_options) do |form_builder|
            builder.with_form(form_builder) { yield(builder) }
            concat(builder.render_modal_content)
          end
        end
      else
        builder.with_form(nil) { yield(builder) }
        builder.render_modal_content
      end

      render(
        partial: "bootstrap5_rails_extensions/modal",
        locals: {
          id: id,
          dialog_class: dialog_classes.join(" "),
          data: modal_data,
          content: content_markup,
        },
      )
    end

    # モーダルの各セクションを構築する小さなDSL用ビルダー。
    class ModalBuilder
      def initialize(view_context, modal_id:, default_title:)
        @view = view_context
        @modal_id = modal_id
        @default_title = default_title
        @header_html = nil
        @header_full = false
        @body_fragments = []
        @body_full = nil
        @footer_fragments = []
        @footer_full = nil
        @current_form_builder = nil
      end

      def with_form(form_builder)
        previous = @current_form_builder
        @current_form_builder = form_builder
        yield(self)
      ensure
        @current_form_builder = previous
      end

      def header(content = nil, full: false, &block)
        raise ArgumentError, _("モーダルヘッダーは一度だけ定義できます") if @header_html

        html = extract_content(content, &block)
        @header_full = full
        @header_html = html
        self
      end

      def body(content = nil, full: false, &block)
        html = extract_content(content, &block)

        if full
          raise ArgumentError, _("モーダル本文はfull: trueでは一度だけ設定できます") if @body_full || @body_fragments.any?

          @body_full = html
        else
          @body_fragments << html
        end
        self
      end

      def footer(content = nil, full: false, &block)
        html = extract_content(content, &block)

        if full
          raise ArgumentError, _("モーダルフッターはfull: trueでは一度だけ設定できます") if @footer_full || @footer_fragments.any?

          @footer_full = html
        else
          @footer_fragments << html
        end
        self
      end

      def render_modal_content
        body_markup = build_body_markup

        header_markup = build_header_markup
        footer_markup = build_footer_markup

        @view.content_tag(:div, class: "modal-content") do
          @view.concat(header_markup) if header_markup
          @view.concat(body_markup)
          @view.concat(footer_markup) if footer_markup
        end
      end

      private

      def extract_content(content, &block)
        if block_given?
          if block.arity.positive?
            raise ArgumentError, _("form_withオプションを指定した場合のみフォームビルダーを利用できます") if @current_form_builder.nil?

            @view.capture(@current_form_builder, &block)
          else
            @view.capture(&block)
          end
        else
          content
        end
      end

      def build_header_markup
        if @header_html
          return @header_html if @header_full

          @view.content_tag(:div, class: "modal-header") do
            @view.concat(@header_html)
            @view.concat(default_close_button)
          end
        else
          default_header_markup
        end
      end

      def build_body_markup
        if @body_full
          raise ArgumentError, _("モーダル本文が空です") if blank_html?(@body_full)

          @body_full
        else
          raise ArgumentError, _("モーダル本文を定義してください") if @body_fragments.empty? || blank_html?(@view.safe_join(@body_fragments))

          @view.content_tag(:div, @view.safe_join(@body_fragments), class: "modal-body")
        end
      end

      def build_footer_markup
        if @footer_full
          return if blank_html?(@footer_full)

          @footer_full
        elsif @footer_fragments.present?
          fragment_html = @view.safe_join(@footer_fragments)
          return if blank_html?(fragment_html)

          @view.content_tag(:div, fragment_html, class: "modal-footer")
        end
      end

      def default_header_markup
        @view.content_tag(:div, class: "modal-header") do
          @view.concat(
            @view.content_tag(
              :h5,
              @default_title,
              class: "modal-title",
              id: header_label_id,
            ),
          )
          @view.concat(default_close_button)
        end
      end

      def default_close_button
        @view.button_tag("", type: "button", class: "btn-close", data: { action: "click->modal#hide" }, aria: { label: "閉じる" })
      end

      def header_label_id
        "#{@modal_id}Label"
      end

      def blank_html?(html)
        html.respond_to?(:blank?) ? html.blank? : html.to_s.strip.empty?
      end
    end
  end
end
