require 'sinatra'
require 'data_mapper'
require 'rouge'

# setup database
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'postgres://rubbypasteuser:rubbypastepass@localhost/rubbypaste')

class Paste
    include DataMapper::Resource

    property :slug, String, :key => true
    property :payload, Text, :required => true
    property :created, DateTime, :required => true
    property :highlight_type, String, :required => true
end

DataMapper.finalize
DataMapper.auto_upgrade!

$base_page = '<!DOCTYPE html><html><head><title>RUBBYPASTE</title>
<link rel="stylesheet" href="/style.css" type="text/css"></head>
<body><div>
<a href="/">new</a>
<a href="/recent">recent</a>
</div>%{body}</body></html>'
$input_form = '<form method="POST" action="/new">
<div><textarea name="payload" rows="24" cols="80"></textarea></div>
<div>Highlight Type: <select name="lexer">
<option value="">Auto</option>%{options}
</select></div>
<div><input type="submit" value="Create" /></div>
</form>'

$lexers = Rouge::Lexer::all.map { |k| { :name => k.name.split('::')[-1], :tag => k.tag } }.
    sort { |a, b| a[:name] <=> b[:name] }
$formatter = Rouge::Formatters::HTML.new(:css_class => 'highlight')
$chars = ("a"..."z").map { |x| x } + ("A"..."Z").map { |x| x } + ("0"..."9").map { |x| x }

get '/' do
    optiontext = $lexers.map{|lexer| '<option value="%{tag}">%{name}</option>' % lexer}.join
    $base_page % {:body => $input_form % {:options => optiontext}}
end

get '/style.css' do
    content_type :css
    Rouge::Themes::ThankfulEyes.render(:scope => '.highlight')
end

post '/new' do
     payload = params[:payload]
     lexer_tag = params[:lexer]
     lexer = Rouge::Lexer::find(lexer_tag)
     unless lexer
         lexer = Rouge::Lexer::guess_by_source(payload)
     end
     slug = (0...8).map { $chars[rand($chars.length)] }.join
     paste = Paste.create(
        :slug => slug,
        :payload => payload,
        :created => Time.now,
        :highlight_type => lexer.tag
    )
    redirect to('/' + slug)
end

get '/recent' do
    recent_pastes = Paste.all(:order => [:created.desc], :limit => 20)
    recent_html = '<ul>%s</ul>' % (recent_pastes.
        map {|paste| '<li><a href="/%{slug}">%{slug}</a></li>' % {:slug => paste.slug}}).join
    $base_page % {:body => recent_html}
end

get '/:slug' do
    slug = params[:slug]
    paste = Paste.get(slug)
    if paste
        lexer = Rouge::Lexer::find(paste.highlight_type)
        body = $formatter.format(lexer.lex(paste.payload)) +
            ("<div>Highlight Type: %s</div>" % lexer.to_s.split('::')[-1])
        $base_page % {:body => body}
    else
        status 404
        $base_page % {:body => "Paste Not Found"}
    end
end