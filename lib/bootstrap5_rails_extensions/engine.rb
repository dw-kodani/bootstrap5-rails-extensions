module Bootstrap5RailsExtensions
  class Engine < ::Rails::Engine
    isolate_namespace Bootstrap5RailsExtensions

    initializer "bootstrap5_rails_extensions.helper" do
      ActiveSupport.on_load(:action_view) do
        require_relative "../../app/helpers/bootstrap5_rails_extensions/modal_helper"
        require_relative "../../app/helpers/bootstrap5_rails_extensions/card_helper"
        require_relative "../../app/helpers/bootstrap5_rails_extensions/offcanvas_helper"
        require_relative "../../app/helpers/bootstrap5_rails_extensions/toast_helper"
        require_relative "../../app/helpers/bootstrap5_rails_extensions/table_helper"
        include Bootstrap5RailsExtensions::ModalHelper
        include Bootstrap5RailsExtensions::CardHelper
        include Bootstrap5RailsExtensions::OffcanvasHelper
        include Bootstrap5RailsExtensions::ToastHelper
        include Bootstrap5RailsExtensions::TableHelper
        # turbo_stream.toast(...) を追加
        begin
          require "turbo/streams/tag_builder"
        rescue LoadError
        end
        if defined?(Turbo::Streams::TagBuilder)
          require_relative "turbo_stream_toast"
          Turbo::Streams::TagBuilder.include Bootstrap5RailsExtensions::TurboStreamToast
        end
      end
      ActiveSupport.on_load(:action_controller_base) do
        include Bootstrap5RailsExtensions::ToastHelper
      end
    end
  end
end
