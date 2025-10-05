# frozen_string_literal: true

module Bootstrap5RailsExtensions
  module TableHelper
    # Bootstrapのtableコンポーネント向け簡易DSL。
    #
    # 使い方:
    #   <%= render_table class: "table-striped" do |table| %>
    #     <%= table.thead class: "table-light" do %>
    #       <tr><th>見出し</th></tr>
    #     <% end %>
    #     <%= table.tbody do %>
    #       <tr><td>内容</td></tr>
    #     <% end %>
    #   <% end %>
    def render_table(data: {}, wrapper_class: nil, wrapper_html: {}, **html_options)
      raise ArgumentError, "theadかtbodyを定義してください" unless block_given?

      builder = TableBuilder.new(self)
      yield(builder)

      raise ArgumentError, "theadかtbodyを最低1つは定義してください" if builder.empty?

      html_options[:class] = build_table_class(html_options[:class])
      html_options[:data] = merge_data_attributes(html_options[:data], data) if data.present?

      wrapper_options = build_wrapper_options(wrapper_html, wrapper_class)

      content_tag(:div, **wrapper_options) do
        content_tag(:table, builder.render, **html_options)
      end
    end

    private

    def build_wrapper_options(wrapper_html, wrapper_class)
      options = wrapper_html.present? ? wrapper_html.deep_dup : {}
      options[:class] = build_wrapper_class(options[:class], wrapper_class)
      options
    end

    def build_table_class(custom_class)
      classes = ["table", "text-nowrap"]
      classes << custom_class if custom_class.present?
      classes.join(" ")
    end

    def build_wrapper_class(custom_class, additional_class)
      classes = ["table-responsive"]
      classes << additional_class if additional_class.present?
      classes << custom_class if custom_class.present?
      classes.join(" ")
    end

    def merge_data_attributes(existing, additional)
      (existing || {}).merge(additional)
    end

    class TableBuilder
      def initialize(view_context)
        @view = view_context
        @sections = []
      end

      def thead(**options, &block)
        append_section(:thead, options, block)
        self
      end

      def tbody(**options, &block)
        append_section(:tbody, options, block)
        self
      end

      def render
        @view.safe_join(@sections)
      end

      def empty?
        @sections.empty?
      end

      private

      def append_section(tag_name, options, block)
        raise ArgumentError, "#{tag_name}にはブロックを渡してください" unless block

        content = @view.capture(&block)
        @sections << @view.content_tag(tag_name, content, **options)
      end
    end
  end
end
