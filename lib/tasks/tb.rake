namespace :tb do
  desc "Transitions the Webpage URI to bookmarks, and adds the Bookmark ID to Offline Caches"
  task remove_webpages: :environment do
    conn = ActiveRecord::Base.connection_pool.checkout
    raw  = conn.raw_connection

    puts "Updating Bookmarks.uri from Webpages.uri ..."
    res = raw.exec <<~SQL
      UPDATE bookmarks SET uri = webpages.uri
      FROM webpages
      WHERE bookmarks.webpage_id = webpages.id AND bookmarks.uri = '';
    SQL
    puts "Done, #{res.cmd_status}"

    res = raw.exec <<~SQL
      SELECT count(bookmark_id), offline_cache_id
      FROM bookmarks_offline_caches
      GROUP BY offline_cache_id
      HAVING count(bookmark_id) > 1;
    SQL

    count = res.to_a.length
    raise "Oh no! #{count} Offline Caches are shared between bookmarks!" if count > 0

    puts "Updating OfflineCaches.bookmark_id from BookmarksOfflineCaches ..."
    res = raw.exec <<~SQL
      UPDATE offline_caches SET bookmark_id = bookmarks_offline_caches.bookmark_id
      FROM bookmarks_offline_caches, bookmarks
      WHERE bookmarks_offline_caches.offline_cache_id = offline_caches.id
        AND bookmarks.id = bookmarks_offline_caches.bookmark_id
        AND offline_caches.bookmark_id is null;
    SQL
    puts "Done, #{res.cmd_status}"
  end
end
