namespace :telegram do
  task :webhook, [ :name, :url ] => [ :environment ] do |t, args|
    name = args[:name]
    url = args[:url]

    fail ArgumentError, "Need to specify which bot to modify" unless name

    if url
      puts "Set webhook for #{ name } to #{ url }"
      AutumnMoon.bots[ name ].client.set_webhook url: url
    else
      puts "Clearing webhook for #{ name }"
      AutumnMoon.bots[ name ].client.delete_webhook
    end
  end
end
