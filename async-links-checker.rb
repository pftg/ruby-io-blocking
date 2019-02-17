require 'async/http/faraday'
require 'async/http/response'
require 'async/http/server'
require 'async/http/url_endpoint'
require 'async/reactor'

require 'uri/http'

# Make it the global default:
Faraday.default_adapter = :async_http

require 'async'
require 'async/http/internet'

TEST_LINKS = %w[http://google.com http://youtube.com http://facebook.com http://baidu.com http://wikipedia.org http://qq.com http://yahoo.com http://taobao.com http://twitter.com http://amazon.com http://vk.com http://sohu.com http://tmall.com http://instagram.com http://live.com http://jd.com http://weibo.com http://reddit.com http://blogspot.com http://linkedin.com http://netflix.com http://livejasmin.com http://porn555.com http://twitch.tv http://360.cn http://yahoo.co.jp http://pornhub.com http://csdn.net http://instructure.com http://xnxx.com http://xinhuanet.com http://bbc.com http://youku.com http://ettoday.net http://roblox.com http://1688.com http://nytimes.com http://google.es http://booking.com http://quora.com http://onlinesbi.com http://spotify.com http://ifeng.com http://soundcloud.com http://bbc.co.uk http://stackexchange.com http://aliyun.com http://bongacams.com http://popads.net http://nih.gov http://google.com.mx http://chase.com http://45eijvhgj2.com http://49oa3o49b6.com http://vimeo.com http://ebay.de http://researchgate.net http://soso.com http://craigslist.org http://eastday.com http://daum.net http://openload.co http://indiatimes.com http://bukalapak.com http://espn.com http://discordapp.com http://dailymotion.com http://google.com.tr http://txxx.com http://theguardian.com http://dolohen.com http://indeed.com http://google.com.tw http://hupu.com http://mediafire.com http://w3schools.com http://globo.com http://fc2.com http://ebay.co.uk http://youdao.com http://mercadolivre.com.br http://so.com http://mozilla.org http://uol.com.br http://steamcommunity.com http://trello.com http://vice.com http://wetransfer.com http://google.ca http://panda.tv http://godaddy.com http://bet9ja.com http://etsy.com http://yts.am http://slack.com http://slideshare.net http://smzdm.com http://atabencot.net http://softonic.com http://alibaba.com http://babytree.com http://cobalten.com http://spankbang.com http://flipkart.com http://zoom.us http://shutterstock.com http://duckduckgo.com http://amazon.it http://chaturbate.com http://zhanqi.tv http://canva.com http://intuit.com http://tokopedia.com http://toutiao.com http://blogger.com http://weather.com http://bankofamerica.com http://yelp.com http://otvfoco.com.br http://kakaku.com http://foxnews.com http://sciencedirect.com http://deviantart.com http://amazon.fr http://zillow.com http://3dmgame.com http://google.pl http://ea.com http://mega.nz http://youm7.com http://steampowered.com http://myshopify.com http://freepik.com http://cnet.com http://google.com.eg http://amazon.cn http://twimg.com http://savefrom.net http://messenger.com http://walmart.com http://kompas.com http://google.com.ar http://digikala.com http://dailymail.co.uk http://onlinevideoconverter.com http://google.com.sa http://huanqiu.com http://wellsfargo.com http://medium.com http://patria.org.ve http://google.co.th http://hantinlethemsed.info http://abs-cbn.com http://google.co.id http://ladbible.com http://google.co.kr http://youporn.com http://hulu.com http://speedtest.net http://gamersky.com http://tantiterhalac.info http://wikihow.com http://quizlet.com http://scribd.com http://shopify.com http://epicgames.com http://udemy.com http://livejournal.com http://doublepimp.com http://google.com.au http://primevideo.com http://liputan6.com http://breitbart.com http://varzesh3.com http://amazon.es http://ebay-kleinanzeigen.de http://sindonews.com http://thepiratebay.org http://doubleclick.net http://line.me http://gearbest.com http://bodelen.com http://archive.org http://egy.best http://1337x.to http://news-speaker.com http://genius.com http://gamepedia.com http://pinimg.com http://gfycat.com http://zendesk.com http://rutracker.org http://zoho.com http://tripadvisor.com http://9gag.com http://allegro.pl http://amazon.ca http://youth.cn http://okta.com http://livedoor.com http://office365.com http://wikimedia.org http://sarkariresult.com http://mailchimp.com http://redd.it http://myway.com http://forbes.com http://cloudfront.net http://momoshop.com.tw http://ndtv.com http://cnki.net http://usps.com http://washingtonpost.com http://reverso.net http://tistory.com http://weebly.com http://namnak.com http://dmm.co.jp http://58.com http://behance.net http://rt.com http://ameblo.jp http://taboola.com http://ikea.com http://chinaz.com http://list.tmall.com http://wordpress.org http://cdninstagram.com http://tencent.com http://pixiv.net http://box.com http://ltn.com.tw http://buzzfeed.com http://hp.com http://ctrip.com http://uptodown.com http://thesaurus.com http://rephartertonelin.info http://google.com.ua http://v2ex.com http://crunchyroll.com http://fiverr.com http://airbnb.com http://redtube.com http://ouo.io http://hotstar.com http://blackboard.com http://academia.edu http://xfinity.com http://getawesome1.com http://livedoor.jp http://zippyshare.com http://pixabay.com http://ask.com http://segmentfault.com http://capitalone.com http://orange.fr http://googlevideo.com http://k618.cn http://nga.cn http://wordreference.com http://atlassian.net http://oracle.com http://bestbuy.com http://yy.com http://mercadolibre.com.ar http://patreon.com http://gamespot.com http://sex.com http://okdiario.com http://exoclick.com http://bp.blogspot.com http://americanexpress.com http://samsung.com http://hola.com http://dytt8.net http://wix.com http://aol.com http://360doc.com http://2345.com http://cambridge.org http://hclips.com http://skype.com http://evernote.com http://ign.com http://siteadvisor.com http://rarbg.to http://namu.wiki http://dell.com http://google.gr http://baike.com http://op.gg http://dianping.com http://bitly.com http://rednet.cn http://sourceforge.net http://hdfcbank.com http://ups.com http://wease.im http://hotnewhiphop.com http://grid.id http://fedex.com http://52pojie.cn http://setn.com http://droom.in http://grammarly.com http://dkn.tv http://friv.com http://ali213.net http://irctc.co.in http://flickr.com http://kaskus.co.id http://indoxxi.bz http://browsergames2018.com http://pulzo.com http://userapi.com http://olx.ua http://sci-hub.tw http://nownews.com http://elmundo.es http://58pic.com http://asana.com http://ieee.org http://flvto.biz http://rarbgprx.org http://japanpost.jp http://ithome.com http://canalrcn.com http://asahi.com http://americanas.com.br http://kapanlagi.com http://torrentz2.eu http://google.co.ao http://google.nl http://visualstudio.com http://playjunkie.com http://bitbucket.org http://viva.co.id http://suning.com http://tomshardware.com http://pconline.com.cn http://rbc.ru http://vnexpress.net http://yespornplease.com http://hotmovs.com http://paytm.com http://fb.ru http://newstrend.news http://thispersondoesnotexist.com http://yandex.com.tr http://gmanetwork.com http://spotscenered.info http://archiveofourown.org http://zimuzu.io http://techradar.com http://arxiv.org http://docin.com http://thehill.com http://lordfilms.tv http://uptobox.com http://n11.com http://codepen.io http://drudgereport.com http://wondershare.com http://mileroticos.com http://myanmarload.com http://android.com http://duolingo.com http://hdlava.me http://gmarket.co.kr http://internetdownloadmanager.com http://gyazo.com http://udn.com http://impress.co.jp http://nintendo.com http://dribbble.com http://doorblog.jp http://hotels.com http://dafont.com http://milliyet.com.tr http://hepsiburada.com http://elwatannews.com http://investopedia.com http://kaoyan.com http://filehippo.com http://interia.pl http://justdial.com http://utorrent.com http://yaplakal.com http://coursera.org http://hdzog.com http://google.sk http://liepin.com http://rotumal.com http://envato.com http://namasha.com http://nutaku.net http://livescore.com http://blog.me http://lifo.gr http://nvidia.com http://groupon.com http://elmogaz.com http://t-online.de http://4399.com http://xda-developers.com http://cima4u.tv http://huffingtonpost.com http://marial.pro http://firefoxchina.cn http://marriott.com http://google.at http://google.se http://hh.ru http://avast.com http://hamariweb.com http://33sk.tv http://hatena.ne.jp http://cnnindonesia.com http://bicentenariobu.com http://cloudflare.com http://tarafdari.com http://creditkarma.com http://teamviewer.com http://film2movie.ws http://uzone.id http://state.gov http://tube8.com http://wowhead.com http://chip.de http://bhphotovideo.com http://reclameaqui.com.br http://flaticon.com http://news18.com http://dcard.tw http://yandex.com http://google.com.ph http://indiamart.com http://xiaohongshu.com http://socialblade.com http://vanguardngr.com http://ticketmaster.com http://issuu.com http://3c.tmall.com http://getpocket.com http://caixa.gov.br http://clien.net http://realtor.com http://keyrolan.com http://cdiscount.com http://yandex.by http://canada.ca http://eztv.io http://book118.com http://python.org http://kijiji.ca http://zing.vn http://newsmth.net http://kakao.com http://naver.jp http://mercadolibre.com.ve http://torrentwal.com http://weather.com.cn http://southwest.com http://auction.co.kr http://lianjia.com http://qualtrics.com http://gotporn.com http://brilio.net http://timeanddate.com http://ruliweb.com http://wargaming.net http://telegraph.co.uk http://vidio.com http://dailycaller.com http://hltv.org http://hm.com http://shopee.tw http://costco.com http://lolesports.com http://vesti.ru http://google.hu http://superuser.com http://subito.it http://mtime.com http://ebay.fr http://dawn.com http://pngtree.com http://weibo.cn http://thingiverse.com http://lefigaro.fr http://imooc.com http://battle.net http://ivi.ru http://unblocked.cx http://gome.com.cn http://turbobit.net http://ninisite.com http://tabelog.com http://polygon.com http://ozon.ru http://sonyliv.com http://qidian.com http://www.gov.uk http://amazon.com.mx http://guancha.cn http://usaa.com http://google.ae http://nnu.ng http://uploaded.net http://indianexpress.com http://11st.co.kr http://coursehero.com http://futbin.com http://mydiba.xyz http://xueqiu.com http://inven.co.kr http://blibli.com http://stanford.edu http://xiaomi.com http://royalbank.com http://verizonwireless.com http://pirateproxy.bet http://4pda.ru http://corriere.it http://6.cn http://yenisafak.com http://zougla.gr http://redfin.com http://uigruwtql.com http://provincial.com http://shimo.im http://tamilrockerss.ch http://indiatoday.in http://ytimg.com http://lifewire.com http://macys.com http://goal.com http://marketwatch.com http://harvard.edu http://wildberries.ru http://huffpost.com http://nasa.gov http://addroplet.com http://pku.edu.cn http://mathworks.com http://infobae.com http://tsinghua.edu.cn http://biblegateway.com http://upornia.com http://familydoctor.com.cn http://ssc.nic.in http://znanija.com http://vmall.com http://mobile.de http://getlnk2.com http://eporner.com http://17track.net http://wikiwand.com http://shein.com http://nordstrom.com http://secureserver.net http://narcity.com http://atlassian.com http://labanquepostale.fr http://ruten.com.tw http://depositphotos.com http://bookmyshow.com http://express.co.uk http://lemonde.fr http://prom.ua http://adme.ru http://vy4e3jw46l.com http://2ch.net http://apache.org http://kayak.com http://storm.mg http://nypost.com http://ubisoft.com http://a9vg.com http://delta.com http://britannica.com http://addthis.com http://cqnews.net http://donga.com http://rutube.ru http://msi.com http://pornpics.com http://andhrajyothy.com http://service-now.com http://href.li http://tandfonline.com http://dnevnik.ru http://norton.com http://kinozal.tv http://189.cn http://google.cz http://xhamsterlive.com http://media.tumblr.com http://tamasha.com http://2movierulz.gs http://abola.pt http://perfectgirls.net http://hootsuite.com http://yifysubtitles.com http://qichacha.com http://4chan.org http://ebates.com http://sportbible.com http://myfreecams.com http://el-nacional.com http://jooble.org http://study.com http://4shared.com http://12306.cn http://ancestry.com].shuffle!.freeze

def faraday_example
  Async::Reactor.run do |task|

    TEST_LINKS[0..100].each do |link|
      task.async do |subtask|
        response = Faraday.get link
        response.status
      end
    end
  end
end

def async_process_http
  Async::Reactor.run do |task|

    TEST_LINKS[100..200].each do |link|
      task.async do |subtask|
        uri = Async::HTTP::URLEndpoint.parse(link)
        client = Async::HTTP::Client.new(uri)
        response = client.get('/')
        response.status
      end
    end
  end
end

require 'concurrent'

def concurrent_ruby_example
  pool = Concurrent::FixedThreadPool.new(100) # 5 threads
  TEST_LINKS[200..300].each do |link|
    pool.post do
      uri = Async::HTTP::URLEndpoint.parse(link)
      client = Async::HTTP::Client.new(uri)
      response = client.get('/')
      response.status
    end
  end
end


require 'benchmark/ips'

Benchmark.ips do |benchmark|
  # benchmark.time = 10
  benchmark.warmup = 0

  benchmark.report('faraday') do |count|
    faraday_example
  end

  benchmark.report('async_http') do |count|
    async_process_http
  end

  benchmark.report('thread_pool') do |count|
    concurrent_ruby_example
  end

   benchmark.compare!
end

