#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# update.rb

require 'date'
require 'erb'
require 'json'
require 'open-uri'
require 'optparse'

BASE_DIR = File.absolute_path(File.dirname($0) + "/../") + "/"

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
    if is_updated(start, goals, url)
        render_html(start, goals, auto, url)
    end
end

def get_latest_url()
    fp = open('http://pso2.jp/players/news/event/')
    body = fp.read()
    fp.close()

    ptn = Regexp.compile('<a href="([^"]+)">.*の紋章[^<]*キャンペーン[^<]*</span>')
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
    goal_ptn = Regexp.compile("<tr><th[^>]*>([^<]*)</th><th class=\"sub\">(.*)</th><td[^>]*>([^<]*)</td></tr>")
    starts = body.scan(start_ptn)

    start = ""
    if starts.size > 0
        start = "%04d-%02d-%02d" % [starts[0][0].to_i, starts[0][1].to_i, starts[0][2].to_i]
    end
        
    goals = body.scan(goal_ptn)

    if goals.size > 0 then
        return [start, goals]
    end

    goal_ptn = Regexp.compile("<span[^>]*>([^<]*)</span><span[^>]*>([^<]*)</span></td><td>(.*)</td>")
    goals = body.scan(goal_ptn)
    goals = goals.map{|g|
        next [g[0].force_encoding("utf-8"),
              g[1].force_encoding("utf-8"),
              g[2].force_encoding("utf-8").gsub(/<[^>]*>/,"")]
    }
    return [start, goals]
    
end

def is_updated(start, goals, url)
    ret = false
    fn = BASE_DIR + "/cache.json"

    if !File.exists?(fn)
        ret = true
    else
        fp = open(fn)
        js = JSON.parse(fp.read)
        fp.close
        if start != js["start"] || goals != js["goals"] || url != js["url"]
            ret = true
        end
    end

    data = {
        "start" => start,
        "goals" => goals,
        "url" => url,
    }
    
    fp = open(fn, "w")
    fp.write(JSON.pretty_generate(data))
    fp.close
    
    return ret
end
    
def render_html(start, goals, auto, url)

    tfn = BASE_DIR + "tools/index.html.erb"
    tfp = open(tfn)
    template_str = tfp.read()
    tfp.close

    template = ERB.new(template_str, nil, "-")
    template.filename = tfn

    now = DateTime.now.to_s
    
    ofp1 = open(BASE_DIR + "index.html", "w")
    ofp1.write(template.result(binding))
    ofp1.close

    ofp2 = open(BASE_DIR + ("archive/%s.html" % start), "w")
    ofp2.write(template.result(binding))
    ofp2.close
end

if __FILE__ == $0 then
    main()
end
