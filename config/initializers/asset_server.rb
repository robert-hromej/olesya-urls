class AssetServer < Sprockets::Environment
  include Singleton

  def initialize
    super Rails.public_path
    append_path 'javascripts'
    append_path 'stylesheets'
    if Rails.env.production?
      self.js_compressor = YUI::JavaScriptCompressor.new :munge => true, :optimize => true
      self.css_compressor = YUI::CssCompressor.new
    end
  end

end