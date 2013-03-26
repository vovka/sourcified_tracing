require 'sourcify'

module SourcifiedTracing
  class << self
#    def included(base)
#      puts "#{__FILE__}:#{__LINE__}: base: #{base.inspect}"
#      base.class_eval do
#        puts "#{__FILE__}:#{__LINE__}: self: #{self.inspect}"
#        self.alias_method_chain :it, :source_tracing
#      end
#    end

    def it_with_source_tracing(desc, &block)
      code = block.to_source strip_enclosure: true

      # code modifications go here
      modified_code = []
      modified_code << <<-EOC
        delta = ->{
          r = if @prev_moment
            Time.now - @prev_moment
          else
            0
          end
          @prev_moment = Time.now
          r.to_s
        }
      EOC
      code.each_line do |l|
        modified_code << (%q{ puts "#{__FILE__}:#{__LINE__}:\t#{Time.now.strftime("%H:%M:%S:%L")}\t#{delta.()}\t} + l.gsub(/\n$/, '').gsub("\"", "\\\"") + %q{"})
        modified_code << l
      end

      block = eval("->{ #{modified_code} }")
      it_without_source_tracing desc, &block
    end
  end
end