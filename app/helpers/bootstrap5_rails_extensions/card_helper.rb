# frozen_string_literal: true

module Bootstrap5RailsExtensions
  module CardHelper
    # Bootstrapのcardコンポーネントを簡潔に記述できるDSL。
    #
    # 使い方:
    #   <%= render_card class: "mb-4" do |card| %>
    #     <% card.header class: "d-flex align-items-center" do %>
    #       タイトル
    #     <% end %>
    #     <% card.body class: "p-4" do %>
    #       本文...
    #     <% end %>
    #     <% card.footer class: "text-end" do %>
    #       フッター
    #     <% end %>
    #   <% end %>
    #
    # オプション:
    #   class: 親要素に追加するクラス
    #   data:  親要素に付与するdata属性
    def render_card(data: {}, **html_options)
      raise ArgumentError, "カードは本文を定義する必要があります" unless block_given?

      builder = CardBuilder.new(self)
      yield(builder)

      html_options[:class] = class_names("card", html_options[:class])

      if data.present?
        html_options[:data] = (html_options[:data] || {}).merge(data)
      end

      content_tag(:div, **html_options) do
        builder.render
      end
    end

    class CardBuilder
      def initialize(view_context)
        @view = view_context
        @header_html = nil
        @header_options = {}
        @body_fragments = []
        @body_options = {}
        @footer_html = nil
        @footer_options = {}
      end

      def header(content = nil, **options, &block)
        raise ArgumentError, "カードヘッダーは一度だけ定義できます" if @header_html

        @header_html = extract_content(content, &block)
        css_class = extract_css_class!(options)
        @header_options[:class] = css_class if css_class.present?
        self
      end

      def body(content = nil, **options, &block)
        html = extract_content(content, &block)
        raise ArgumentError, "カード本文が空です" if blank_html?(html)

        @body_fragments << html
        css_class = extract_css_class!(options)
        if css_class.present?
          if @body_options[:class].present? && @body_options[:class] != css_class
            raise ArgumentError, "カード本文のクラス指定は一度だけ行ってください"
          end
          @body_options[:class] = css_class
        end
        self
      end

      def footer(content = nil, **options, &block)
        raise ArgumentError, "カードフッターは一度だけ定義できます" if @footer_html

        html = extract_content(content, &block)
        @footer_html = html unless blank_html?(html)
        css_class = extract_css_class!(options)
        @footer_options[:class] = css_class if css_class.present?
        self
      end

      def render
        raise ArgumentError, "カード本文を定義してください" if @body_fragments.empty?

        fragments = []
        fragments << wrap_section(@header_html, default_header_class, @header_options[:class]) if @header_html
        fragments << wrap_section(@view.safe_join(@body_fragments), default_body_class, @body_options[:class])
        fragments << wrap_section(@footer_html, default_footer_class, @footer_options[:class]) if @footer_html
        @view.safe_join(fragments.compact)
      end

      private

      def extract_content(content, &block)
        if block_given?
          @view.capture(&block)
        else
          content
        end
      end

      def extract_css_class!(options)
        return nil if options.nil? || options.empty?

        css_class = options.delete(:class)
        raise ArgumentError, "サポートされていないオプションです: #{options.keys.join(', ')}" if options.present?

        css_class
      end

      def wrap_section(content, wrapper_class, extra_class = nil)
        return if blank_html?(content)
        if wrapper_class == false && extra_class.blank?
          return content
        end

        combined_class = [wrapper_class == false ? nil : wrapper_class, extra_class.presence].compact.join(" ")
        return content if combined_class.blank?

        @view.content_tag(:div, content, class: combined_class)
      end

      def default_header_class
        "card-header"
      end

      def default_body_class
        "card-body"
      end

      def default_footer_class
        "card-footer"
      end

      def blank_html?(html)
        html.respond_to?(:blank?) ? html.blank? : html.to_s.strip.empty?
      end
    end
  end
end
