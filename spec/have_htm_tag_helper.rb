String.class_eval do
  #  <b>==DOCUMENTATION==</b>
  #  <b>returns true if incoming string contains html selector</b>
  #
  #  <b>Usage</b>
  #    string.has_html_tag?('div',:class=>'class',:id=>'id',:src=>'src',:content=>'hello world')
  #
  #  <b>output</b> -->
  #    tru or false
  def has_html_tag?(tag, options = {})
    tag_search = options[:content].nil? ? Regexp.new('< ?'+tag.to_s+'[^<>]*>') : Regexp.new('< ?'+tag.to_s+'[^<>]*>.*</ ?'+tag.to_s+' ?>')
    content = options[:content].nil? ? '' : options[:content]
    print = (!options[:print].nil? && options[:print])
    options.delete(:content)
    options.delete(:print)
    matches = self.scan(tag_search)
    total_result = false
    matches.each do |match|
      result = true
      options.each_pair do |key, value|
        pat = Regexp.new(' ' + key.to_s + '=("|\')'+value+'("|\')')
        result &= (pat === match)
        break unless result
      end
      result &= (Regexp.new(content) === match) if result
      if result
        total_result = true
        break
      end
    end
    puts matches.join("\n") if print
    total_result
  end
end