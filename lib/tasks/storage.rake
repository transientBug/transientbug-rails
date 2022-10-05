namespace :storage do
  # https://stackoverflow.com/a/69827183/3877528
  desc "Ensures all files are mirrored"
  task mirror_all: [:environment] do
    ActiveStorage::Blob.all.each do |blob|
      ActiveStorage::Blob.service.try(:mirror, blob.key, checksum: blob.checksum)
    rescue ActiveStorage::FileNotFoundError
      # Add some message or warning here if you fancy
      puts "Missing file for blob #{ blob.key }!"
    end

    Rails.logger.info "Mirroring done!"
  end

  desc "Change each blob service name to DO"
  task switch: [:environment] do
    service_name = :digitalocean

    ActiveStorage::Blob.update_all(service_name:)

    Rails.logger.info "All blobs will now be served from #{ service_name }!"
  end

  task cleanup: :environment do
    ActiveStorage::Blob.unattached.each(&:purge)
  end
end
