require 'active_support/core_ext/string/inflections'
require 'i18n'
require 'ndd/rspec/rails/matchers/model/translation_matcher'

module Ndd
  module RSpec
    module Rails
      module Matchers
        module Model #:nodoc:

          # Ensure that a model has an associated translation.
          #
          # More precisely, ensure that
          #   I18n.t(locale, "activerecord.models.{snake_case_class_name}")
          # returns a value for the default locale (i.e. +I18n.default_locale+)
          # or all the available locales (i.e. +I18n.available_locales+).
          #
          # For example:
          #
          #   RSpec.describe MyModel, type: :model do
          #     # both are equivalent
          #     it { is_expected.to have_a_translated_model }
          #     it { is_expected.to have_a_translated_model.in_available_locales }
          #
          #     it { is_expected.to have_a_translated_model.in_default_locale }
          #   end
          #
          def have_a_translated_model # rubocop:disable Style/PredicateName
            HaveATranslatedModel.new
          end

          # ------------------------------------------------------------------------------------------------------------
          # Implements {#have_a_translated_model}.
          #
          class HaveATranslatedModel < TranslationMatcher

            # @param model [Object] the model being tested.
            # @return [Boolean] true if the model has an associated translation, false otherwise.
            def matches?(model)
              @model = model
              @failed_locales = []
              @tested_locales.each do |tested_locale|
                @failed_locales << tested_locale unless translated?(tested_locale, translation_key)
              end
              @failed_locales.empty?
            end

            # @return [String] a description of this matcher.
            def description
              "have a translated model name in #{locales_as_string(@tested_locales)}"
            end

            # @return [String] details about the failure of this matcher.
            def failure_message
              message = ''
              message << "expected '#{@model.class}' to have a translated model name\n"
              message << "but the '#{translation_key}' key was not found\n"
              message << "for the locales: #{locales_as_string(@failed_locales)}"
              message
            end

            # -------------------------------------------------------------------------------------------- private -----
            private

            # @return [String] the translation key of the model.
            def translation_key
              "activerecord.models.#{@model.class.name.underscore}"
            end

          end

        end
      end
    end
  end
end
