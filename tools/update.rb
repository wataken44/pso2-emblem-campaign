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
        url = get_latest_url()
    else
        url = argv[0]
    end

    start, goals = get_data(url)
    render_html(start, goals, auto, url)
end

def get_latest_url()
    fp = open('http://pso2.jp/players/news/event/')
    body = fp.read()
    fp.close()

    ptn = Regexp.compile('<a href="([^"]+)">.*王者の紋章[^<]*キャンペーン</span>')
    links = body.scan(ptn)

    if links.size > 0
        return links[0][0]
    end

    return nil
end

def get_data(url)
    fp = open(url)
    body = fp.read()
    fp.close

    start_ptn = Regexp.compile('<span class="period-start"><span class="year">(\d+)</span>[^<]*<span class="mouth">(\d+)</span>[^<]*<span class="day">(\d+)</span>')
    goal_ptn = Regexp.compile("<tr><th>([^<]*)</th><th class=\"sub\">(.*)</th><td>([^<]*)</td></tr>")
    starts = body.scan(start_ptn)

    start = ""
    if starts.size > 0
        start = "%04d-%02d-%02d" % [starts[0][0].to_i, starts[0][1].to_i, starts[0][2].to_i]
    end
        
    goals = body.scan(goal_ptn)
    
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

    now = DateTime.now.to_s
    
    ofp1 = open(base_dir + "index.html", "w")
    ofp1.write(template.result(binding))
    ofp1.close

    ofp2 = open(base_dir + ("archive/%s.html" % start), "w")
    ofp2.write(template.result(binding))
    ofp2.close

end

if __FILE__ == $0 then
    main()
end
