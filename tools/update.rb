#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# update.rb

require 'date'
require 'erb'
require 'open-uri'
require 'optparse'

def main()

    auto = false
    url = nil
    
    opt = OptionParser.new

    opt.on('-a'){|v| auto = v}

    argv = opt.parse(ARGV)
    
    if auto
        # implement later
        # url = hogehoge
    else
        url = argv[0]
    end

    start, goals = get_data(url)
    render_html(start, goals, auto, url)
end

def get_data(url)
    fp = open(url)

    start_ptn = Regexp.compile('<span class="period-start"><span class="year">(\d+)</span>[^<]*<span class="mouth">(\d+)</span>[^<]*<span class="day">(\d+)</span>')
    goal_ptn = Regexp.compile("<tr><th>([^<]*)</th><th class=\"sub\">(.*)</th><td>([^<]*)</td></tr>")
    body = fp.read()
    starts = body.scan(start_ptn)

    start = ""
    if starts.size > 0
        start = "%04d-%02d-%02d" % [starts[0][0].to_i, starts[0][1].to_i, starts[0][2].to_i]
    end
        
    goals = body.scan(goal_ptn)
    
    fp.close

    return [start, goals]
end

def render_html(start, goals, auto, url)
    base_dir = File.absolute_path(File.dirname($0) + "/../") + "/"

    tfn = base_dir + "tools/index.html.erb"
    tfp = open(tfn)
    template_str = tfp.read()
    tfp.close

    template = ERB.new(template_str, nil, "-")
    template.filename = tfn
    
    ofp1 = open(base_dir + "index.html", "w")
    ofp1.write(template.result(binding))
    ofp1.close
end

if __FILE__ == $0 then
    main()
end
