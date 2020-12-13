InlineSvg.configure do |config|
  config.asset_file = InlineSvg::CachedAssetFile.new(
    paths: [
      "#{Rails.root}/public/feather/",
    ],
    filters: /\.svg/
  )
end
